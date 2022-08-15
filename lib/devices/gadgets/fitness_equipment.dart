// ignore_for_file: unused_field
import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/athlete_age.dart';
import '../../preferences/athlete_body_weight.dart';
import '../../preferences/athlete_gender.dart';
import '../../preferences/athlete_vo2max.dart';
import '../../preferences/block_signal_start_stop.dart';
import '../../preferences/cadence_data_gap_workaround.dart';
import '../../persistence/database.dart';
import '../../preferences/extend_tuning.dart';
import '../../preferences/heart_rate_gap_workaround.dart';
import '../../preferences/heart_rate_limiting.dart';
import '../../preferences/log_level.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../preferences/use_heart_rate_based_calorie_counting.dart';
import '../../preferences/use_hr_monitor_reported_calories.dart';
import '../../utils/constants.dart';
import '../../utils/delays.dart';
import '../../utils/hr_based_calories.dart';
import '../../utils/logging.dart';
import '../bluetooth_device_ex.dart';
import '../device_descriptors/data_handler.dart';
import '../device_descriptors/device_descriptor.dart';
import '../device_fourcc.dart';
import '../gadgets/complex_sensor.dart';
import '../gatt_constants.dart';
import 'device_base.dart';
import 'heart_rate_monitor.dart';
import 'write_support_parameters.dart';

typedef RecordHandlerFunction = Function(RecordWithSport data);

// State Machine for #231 and #235
// (intelligent start and moving / elapsed time tracking)
enum WorkoutState {
  waitingForFirstMove,
  startedMoving,
  moving,
  justStopped,
  stopped,
}

class FitnessEquipment extends DeviceBase {
  static const badKey = -1;

  DeviceDescriptor? descriptor;
  Map<int, DataHandler> dataHandlers = {};
  String? manufacturerName;
  double _residueCalories = 0.0;
  int _lastPositiveCadence = 0; // #101
  bool _cadenceGapWorkaround = cadenceGapWorkaroundDefault;
  double _lastPositiveCalories = 0.0; // #111
  bool firstCalories; // #197 #234 #259
  double _startingCalories = 0.0;
  bool firstDistance; // #197 #234 #259
  double _startingDistance = 0.0;
  bool deviceHasTotalCalorieReporting = false;
  bool hrmHasTotalCalorieReporting = false;
  bool hasTotalDistanceReporting = false;
  Timer? _timer;
  late RecordWithSport lastRecord;
  late Record continuationRecord;
  bool continuation = false;
  HeartRateMonitor? heartRateMonitor;
  ComplexSensor? _extraSensor;
  String _heartRateGapWorkaround = heartRateGapWorkaroundDefault;
  int _heartRateUpperLimit = heartRateUpperLimitDefault;
  String _heartRateLimitingMethod = heartRateLimitingMethodDefault;
  double powerFactor = 1.0;
  double calorieFactor = 1.0;
  double hrCalorieFactor = 1.0;
  double hrmCalorieFactor = 1.0;
  bool _useHrmReportedCalories = useHrMonitorReportedCaloriesDefault;
  bool _useHrBasedCalorieCounting = useHeartRateBasedCalorieCountingDefault;
  int _weight = athleteBodyWeightDefault;
  int _age = athleteAgeDefault;
  bool _isMale = true;
  int _vo2Max = athleteVO2MaxDefault;
  Activity? _activity;
  bool measuring = false;
  WorkoutState workoutState = WorkoutState.waitingForFirstMove;
  bool calibrating = false;
  final Random _random = Random();
  double? slowPace;
  bool _equipmentDiscovery = false;
  bool _extendTuning = false;

  int readFeatures = 0;
  int writeFeatures = 0;
  WriteSupportParameters? _speedLevels; // km/h
  WriteSupportParameters? _inclinationLevels; // percent
  WriteSupportParameters? _resistanceLevels;
  WriteSupportParameters? _heartRateLevels;
  WriteSupportParameters? _powerLevels;
  bool supportsSpinDown = false;
  bool _blockSignalStartStop = blockSignalStartStopDefault;

  // For Throttling + deduplication #234
  final Duration _throttleDuration = const Duration(milliseconds: ftmsDataThreshold);
  Map<int, List<int>> _listDeduplicationMap = {};
  Timer? _throttleTimer;
  RecordHandlerFunction? _recordHandlerFunction;

  FitnessEquipment({this.descriptor, device, this.firstCalories = true, this.firstDistance = true})
      : super(
          serviceId: descriptor?.dataServiceId ?? fitnessMachineUuid,
          characteristicId: descriptor?.dataCharacteristicId ?? "",
          controlCharacteristicId: descriptor?.controlCharacteristicId ?? "",
          listenOnControl: descriptor?.listenOnControl ?? true,
          statusCharacteristicId: descriptor?.statusCharacteristicId ?? "",
          device: device,
        ) {
    readConfiguration();
    lastRecord = RecordWithSport(sport: sport);
  }

  String get sport => _activity?.sport ?? (descriptor?.defaultSport ?? ActivityType.ride);
  double get residueCalories => _residueCalories;
  double get lastPositiveCalories => _lastPositiveCalories;
  bool get shouldMerge => dataHandlers.length > 1;

  int keySelector(List<int> l) {
    if (l.isEmpty) {
      return badKey;
    }

    if (l.length == 1) {
      return l[0];
    }

    return l[1] * 256 + l[0];
  }

  RecordWithSport? _mergedForYield() {
    final values = _listDeduplicationMap.entries
        .map((entry) => dataHandlers[entry.key]!.wrappedStubRecord(entry.value))
        .whereNotNull();

    _listDeduplicationMap = {};
    if (values.isEmpty) {
      if (logLevel >= logLevelInfo) {
        Logging.log(
          logLevel,
          logLevelInfo,
          "FITNESS_EQUIPMENT",
          "mergedToYield",
          "Skipping!!",
        );
      }
      return null;
    }

    final merged = values.skip(1).fold<RecordWithSport>(
          values.first,
          (prev, element) => prev.merge(element, true, true),
        );
    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "mergedToYield",
        "merged $merged",
      );
    }
    return merged;
  }

  void _throttlingTimerCallback() {
    _throttleTimer = null;
    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "listenToData",
        "Timer expire induced handling",
      );
    }
    if (_recordHandlerFunction != null) {
      final merged = _mergedForYield();
      if (merged != null) {
        // Since we processed this should also count against throttle
        _startThrottlingTimer();
        // No way to yield from here so imperatively pump
        pumpDataCore(merged, false);
      }

      if (workoutState == WorkoutState.justStopped || workoutState == WorkoutState.stopped) {
        if (merged == null) {
          pumpDataCore(lastRecord, true);
        }

        _startThrottlingTimer();
      }
    }
  }

  void _startThrottlingTimer() {
    _throttleTimer ??= Timer(_throttleDuration, _throttlingTimerCallback);
  }

  /// Data streaming with custom multi-type packet aware throttling logic
  ///
  /// Stages SB20, Yesoul S3 and several other machines don't gather up
  /// all the relevant feature data into one packet, but instead supply
  /// various packets with distinct features. For example:
  /// * Stages has three packet types: 1. speed, 2. distance, 3.
  ///   cadence + power
  /// * Yesoul has two: 1. speed + elapsed time 2. cadence + distance +
  ///   power + calories
  ///
  /// This behavior is fundamentally different than other machines like
  /// Schwinn IC4 or Precor Spinner Chrono Power.
  /// * With multi-type packets I cannot tell if the workout is stopped
  ///   (like if I ony get a distance packet).
  /// * Creating a stub record from fragments of features results in a
  ///   spotty record. We'd need to fill the gaps from last known positive
  ///   values.
  /// * Since feature flags rotate we'd want to avoid the constant
  ///   re-interpretation of feature bits and construction of metric mapping.
  ///   So instead of having just one DataHandler (part of DeviceBase parent
  ///   class) we'd manage a set of DataHandlers, basically caching the
  ///   feature computation
  /// * With need our own throttling, since the throttle logic should
  ///   distinguish packets by features and should be able to gather the latest
  ///   from each.
  /// * As an extra win the throttling logic can already check the worthy-ness
  ///   of a packet and drop it without disturbing the throttling (timer).
  ///   Apparently Precor Spinner Chrono Power sometimes sprinkles in unworthy
  ///   packets into the comm. If the throttle timing is in interference it could
  ///   only pickup those unworthy packets so the app would be numb. With the
  ///   worthy-ness check before anything else we could just yeet the garbage
  ///   before it'd load or disturb anything.
  /// * When it's time to yield we merge the various feature packets together.
  ///   Merge logic simply sets a value if it's null. There's still extra care
  ///   needed about first positive values and workout start and stop conditions
  ///   in processRecord
  Stream<RecordWithSport> get _listenToData async* {
    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "listenToData",
        "attached $attached characteristic $characteristic descriptor $descriptor",
      );
    }
    if (!attached || characteristic == null || descriptor == null) return;

    await for (final byteList in characteristic!.value) {
      if (logLevel >= logLevelInfo) {
        Logging.log(
          logLevel,
          logLevelInfo,
          "FITNESS_EQUIPMENT",
          "listenToData",
          "measuring $measuring calibrating $calibrating",
        );
      }
      if (!measuring && !calibrating) continue;

      final key = keySelector(byteList);
      if (logLevel >= logLevelInfo) {
        Logging.log(
          logLevel,
          logLevelInfo,
          "FITNESS_EQUIPMENT",
          "listenToData",
          "key $key byteList $byteList",
        );
      }
      bool processable = false;
      if (key >= 0) {
        if (!dataHandlers.containsKey(key)) {
          if (logLevel >= logLevelInfo) {
            Logging.log(
              logLevel,
              logLevelInfo,
              "FITNESS_EQUIPMENT",
              "listenToData",
              "Cloning handler for $key",
            );
          }
          dataHandlers[key] = descriptor!.clone();
        }

        final dataHandler = dataHandlers[key]!;
        processable = dataHandler.isDataProcessable(byteList);
        if (processable) {
          _listDeduplicationMap[key] = byteList;
        }
      }

      bool timerActive = _throttleTimer?.isActive ?? false;
      if (logLevel >= logLevelInfo) {
        Logging.log(
          logLevel,
          logLevelInfo,
          "FITNESS_EQUIPMENT",
          "listenToData",
          "Processable $processable, timerActive $timerActive",
        );
      }
      if (!timerActive) {
        // Bad or useless data packets shouldn't count against rate limit.
        // But now we let the code flow reach here so they can trigger
        // a yield though.
        if (key >= 0 && processable) {
          _startThrottlingTimer();
        }

        final merged = _mergedForYield();
        if (merged != null) {
          yield merged;
        }
      }
    }
  }

  void pumpDataCore(RecordWithSport recordStub, bool idle) {
    if (_recordHandlerFunction != null) {
      final record = processRecord(recordStub, idle);
      _recordHandlerFunction!(record);
    }
  }

  void pumpData(RecordHandlerFunction recordHandlerFunction) {
    _recordHandlerFunction = recordHandlerFunction;
    if (uxDebug) {
      _timer = Timer(
        const Duration(seconds: 1),
        () {
          final record = processRecord(RecordWithSport.getRandom(sport, _random), false);
          recordHandlerFunction(record);
          pumpData(recordHandlerFunction);
        },
      );
    } else {
      _extraSensor?.pumpData(null);
      subscription = _listenToData.listen((recordStub) {
        pumpDataCore(recordStub, false);
      });
    }
  }

  void setHeartRateMonitor(HeartRateMonitor heartRateMonitor) {
    this.heartRateMonitor = heartRateMonitor;
  }

  Future<void> additionalSensorsOnDemand() async {
    await refreshFactors();

    if (_extraSensor != null && _extraSensor?.device?.id.id != device?.id.id) {
      await _extraSensor?.detach();
      _extraSensor = null;
    }

    if (descriptor != null && device != null) {
      _extraSensor = descriptor!.getExtraSensor(device!);
      _extraSensor?.services = services;
      await _extraSensor?.discoverCore();
      await _extraSensor?.attach();
    } else {
      _extraSensor = null;
    }
  }

  Future<void> setActivity(Activity activity) async {
    _activity = activity;
    lastRecord = RecordWithSport.getZero(sport);
    if (Get.isRegistered<AppDatabase>()) {
      final database = Get.find<AppDatabase>();
      final lastRecord = await database.recordDao.findLastRecordOfActivity(activity.id!).first;
      continuationRecord = lastRecord ?? RecordWithSport.getZero(sport);
      continuation = continuationRecord.hasCumulative();
      if (logLevel >= logLevelInfo) {
        Logging.log(
          logLevel,
          logLevelInfo,
          "FITNESS_EQUIPMENT",
          "setActivity",
          "continuation $continuation continuationRecord $continuationRecord",
        );
      }
    }
    workoutState = WorkoutState.waitingForFirstMove;
    dataHandlers = {};
    readConfiguration();
  }

  Future<bool> connectOnDemand({identify = false}) async {
    await connect();

    return await discover(identify: identify);
  }

  /// Needed to check if any of the last seen data stubs for each
  /// combination indicated movement. #234 #259
  bool wasNotMoving() {
    if (dataHandlers.isEmpty) {
      return true;
    }

    return dataHandlers.values.skip(1).fold<bool>(
          dataHandlers.values.first.lastNotMoving,
          (prev, element) => prev && element.lastNotMoving,
        );
  }

  Future<WriteSupportParameters?> getWriteSupportParameters(
    int writeFeaturesFlag,
    int supportBit,
    String supportCharacteristicId,
    String description,
    int division, {
    int numberBytes = 2,
  }) async {
    if (writeFeaturesFlag & supportBit > 0) {
      final writeTargets =
          BluetoothDeviceEx.filterCharacteristic(service!.characteristics, supportCharacteristicId);
      try {
        final writeTargetValues = await writeTargets?.read();
        if (writeTargetValues != null) {
          final params = WriteSupportParameters(
            writeTargetValues,
            division: division,
            numberBytes: numberBytes,
          );
          debugPrint("$description - ${params.minimum} / ${params.maximum} / ${params.increment}");
          return params;
        }
      } on PlatformException catch (e, stack) {
        debugPrint("$e");
        debugPrintStack(stackTrace: stack, label: "trace:");
      }
    }

    return null;
  }

  int _getLongFromBytes(List<int> data, int index) {
    return data[index] + 256 * (data[index + 1] + 256 * (data[index + 2] + 256 * data[index + 3]));
  }

  Future<void> _fitnessMachineFeature() async {
    final machineFeatures =
        BluetoothDeviceEx.filterCharacteristic(service!.characteristics, fitnessMachineFeature);

    try {
      final featureValues = await machineFeatures?.read();
      if (featureValues == null) {
        return;
      }

      readFeatures = _getLongFromBytes(featureValues, 0);
      writeFeatures = _getLongFromBytes(featureValues, 4);
      _speedLevels = await getWriteSupportParameters(
        writeFeatures,
        speedTargetSettingSupported,
        supportedSpeedRange,
        writeFeatureTexts[0],
        100,
      );
      _inclinationLevels = await getWriteSupportParameters(
        writeFeatures,
        inclinationTargetSettingSupported,
        supportedInclinationRange,
        writeFeatureTexts[1],
        10,
      );
      _resistanceLevels = await getWriteSupportParameters(
        writeFeatures,
        resistanceTargetSettingSupported,
        supportedResistanceLevel,
        writeFeatureTexts[2],
        10,
      );
      _heartRateLevels = await getWriteSupportParameters(
        writeFeatures,
        heartRateTargetSettingSupported,
        supportedHeartRateRange,
        writeFeatureTexts[4],
        1,
        numberBytes: 1,
      );
      _powerLevels = await getWriteSupportParameters(
        writeFeatures,
        powerTargetSettingSupported,
        supportedPowerRange,
        writeFeatureTexts[3],
        1,
      );
      supportsSpinDown = (writeFeatures & spinDownControlSupported > 0) ||
          descriptor?.fourCC == kayakProGenesisPortFourCC;
    } on PlatformException catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }
  }

  @override
  Future<void> connectToControlPoint(bool obtainControl) async {
    if (controlCharacteristicId.isEmpty) {
      return;
    }

    await super.connectToControlPoint(obtainControl);
    if (obtainControl && !_blockSignalStartStop && descriptor != null) {
      await descriptor!.executeControlOperation(
        controlPoint,
        _blockSignalStartStop,
        logLevel,
        requestControl,
      );
    }
  }

  @override
  Future<bool> discover({bool identify = false, bool retry = false}) async {
    if (uxDebug) return true;

    final success = await super.discover(retry: retry);
    if (identify || !success) return success;

    if (_equipmentDiscovery || descriptor == null) return false;

    _equipmentDiscovery = true;

    await _fitnessMachineFeature();

    // Check manufacturer name
    if (manufacturerName == null) {
      final deviceInfo = BluetoothDeviceEx.filterService(services, deviceInformationUuid);
      await _getManufacturerName(deviceInfo);
    }

    _equipmentDiscovery = false;
    return _checkManufacturerName();
  }

  bool _checkManufacturerName() {
    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "_checkManufacturerName",
        "ensuring that manufacturer name ($manufacturerName) contains manufacturer prefix ${descriptor!.manufacturerPrefix}",
      );
    }

    if (descriptor!.manufacturerPrefix == "Unknown") {
      return true;
    }

    return manufacturerName?.toLowerCase().contains(descriptor!.manufacturerPrefix.toLowerCase()) ??
        false;
  }

  Future<String?> _getManufacturerName(deviceInfo) async {
    final nameCharacteristic =
        BluetoothDeviceEx.filterCharacteristic(deviceInfo?.characteristics, manufacturerNameUuid);
    if (nameCharacteristic == null) {
      return null;
    }

    return manufacturerName = await _readManufacturerNameFrom(nameCharacteristic) ??
        await _readManufacturerNameFrom(nameCharacteristic, secondTry: true);
  }

  Future<String?> _readManufacturerNameFrom(BluetoothCharacteristic nameCharacteristic,
      {bool secondTry = false}) async {
    try {
      final nameBytes = await nameCharacteristic.read();
      manufacturerName = String.fromCharCodes(nameBytes);
      return manufacturerName;
    } on PlatformException catch (e, stack) {
      if (logLevel > logLevelNone) {
        Logging.logException(
          logLevel,
          "FITNESS_EQUIPMENT",
          "discover",
          "Could not read name${secondTry ? ' 2nd try' : ''}",
          e,
          stack,
        );
      }

      if (kDebugMode) {
        debugPrint("$e");
        debugPrintStack(stackTrace: stack, label: "trace:");
      }
      return null;
    }
  }

  @visibleForTesting
  void setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, extendTuning) {
    this.powerFactor = powerFactor;
    this.calorieFactor = calorieFactor;
    this.hrCalorieFactor = hrCalorieFactor;
    this.hrmCalorieFactor = hrmCalorieFactor;
    _extendTuning = extendTuning;
  }

  RecordWithSport processRecord(RecordWithSport stub, [bool idle = false]) {
    final now = DateTime.now();
    // State Machine for #231 and #235
    // (intelligent start and elapsed time tracking)
    bool isNotMoving = stub.isNotMoving();
    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "processRecord",
        "workoutState $workoutState isNotMoving $isNotMoving",
      );
    }
    if (workoutState == WorkoutState.waitingForFirstMove) {
      if (isNotMoving) {
        if (_activity != null && _activity!.startDateTime != null) {
          int elapsedMillis = now.difference(_activity!.startDateTime!).inMilliseconds;
          lastRecord.adjustTime(elapsedMillis ~/ 1000, elapsedMillis);
        }

        return lastRecord;
      } else {
        dataHandlers = {};
        if (workoutState == WorkoutState.startedMoving) {
          workoutState = WorkoutState.moving;
        } else if (workoutState != WorkoutState.moving) {
          workoutState = WorkoutState.startedMoving;
        }

        // Null activity should only happen in UX simulation mode
        if (_activity != null) {
          _activity!.startDateTime = now;
          _activity!.start = now.millisecondsSinceEpoch;
          if (Get.isRegistered<AppDatabase>()) {
            final database = Get.find<AppDatabase>();
            database.activityDao.updateActivity(_activity!);
          }
        }
      }
    } else {
      // merged stub can be isNotMoving if due to timing interference
      // only such packets gathered which don't contain moving data
      // (such as distance, calories, elapsed time).
      // The only way to be sure in case of multi packet type machines
      // is to check if all of the data handlers report non movement.
      // Once all types of packets indicate non movement we can be sure
      // that the workout is stopped.
      if (isNotMoving && wasNotMoving()) {
        if (workoutState == WorkoutState.moving || workoutState == WorkoutState.startedMoving) {
          workoutState = WorkoutState.justStopped;
        } else {
          workoutState = WorkoutState.stopped;
        }
      } else {
        if (workoutState == WorkoutState.startedMoving) {
          workoutState = WorkoutState.moving;
        } else if (workoutState != WorkoutState.moving) {
          workoutState = WorkoutState.startedMoving;
        }
      }
    }

    if (descriptor != null) {
      stub.adjustByFactors(powerFactor, calorieFactor, _extendTuning);
      if (logLevel >= logLevelInfo) {
        Logging.log(
          logLevel,
          logLevelInfo,
          "FITNESS_EQUIPMENT",
          "processRecord",
          "adjusted stub $stub",
        );
      }
    }

    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "processRecord",
        "#1 _residueCalories $_residueCalories, "
            "_lastPositiveCadence $_lastPositiveCadence, "
            "_lastPositiveCalories $_lastPositiveCalories, "
            "firstCalories $firstCalories, "
            "_startingCalories $_startingCalories, "
            "firstDistance $firstDistance, "
            "_startingDistance $_startingDistance, "
            "deviceHasTotalCalorieReporting $deviceHasTotalCalorieReporting, "
            "hrmHasTotalCalorieReporting $hrmHasTotalCalorieReporting, "
            "hasTotalDistanceReporting $hasTotalDistanceReporting",
      );
    }

    int elapsedMillis = now.difference(_activity?.startDateTime ?? now).inMilliseconds;
    double elapsed = elapsedMillis / 1000.0;
    // When the equipment supplied multiple data read per second but the Fitness Machine
    // standard only supplies second resolution elapsed time the delta time becomes zero
    // Therefore the FTMS elapsed time reading is kinda useless, causes problems.
    // With this fix the calorie zeroing bug is revealed. Calorie preserving workaround can be
    // toggled in the settings now. Only the distance perseverance could pose a glitch. #94
    final deviceReportsTotalCalories = !idle && stub.calories != null;
    deviceHasTotalCalorieReporting |= deviceReportsTotalCalories;
    final hrmRecord = heartRateMonitor?.record;
    hrmRecord?.adjustByFactors(powerFactor, hrmCalorieFactor, _extendTuning);
    final hrmReportsCalories = !idle && hrmRecord?.calories != null;
    hrmHasTotalCalorieReporting |= hrmReportsCalories;
    // All of these starting* and hasTotal* codes have to come before the (optional) merge
    // and after tuning / factoring adjustments #197
    if (firstCalories) {
      if (_useHrmReportedCalories) {
        if (hrmHasTotalCalorieReporting && (hrmRecord?.calories ?? 0) > 0) {
          _startingCalories = hrmRecord!.calories!.toDouble();
          firstCalories = false;
        }
      } else if (deviceHasTotalCalorieReporting && (stub.calories ?? 0) > 0) {
        _startingCalories = stub.calories!.toDouble();
        firstCalories = false;
      }
    }

    hasTotalDistanceReporting |= stub.distance != null;
    if (hasTotalDistanceReporting && firstDistance && (stub.distance ?? 0.0) >= 50.0) {
      _startingDistance = stub.distance!;
      firstDistance = false;
    }

    if (shouldMerge) {
      stub.merge(
        lastRecord,
        _cadenceGapWorkaround,
        _heartRateGapWorkaround == dataGapWorkaroundLastPositiveValue,
      );
    }

    stub.elapsed = elapsed.round();
    stub.elapsedMillis = elapsedMillis;

    if (workoutState == WorkoutState.stopped) {
      // We have to track the time ticking still #235
      lastRecord.adjustTime(stub.elapsed!, stub.elapsedMillis!);
      return lastRecord;
    }

    if (_extraSensor != null && (_extraSensor?.attached ?? false)) {
      RecordWithSport? extraRecord = _extraSensor?.record;
      if (extraRecord != null) {
        extraRecord.adjustByFactors(powerFactor, calorieFactor, _extendTuning);
        stub.merge(extraRecord, true, true);
      }
    }

    final dTMillis = elapsedMillis - (lastRecord.elapsedMillis ?? 0);
    final dT = dTMillis / 1000.0;
    if ((stub.distance ?? 0.0) < eps) {
      stub.distance = (lastRecord.distance ?? 0);
      if ((stub.speed ?? 0.0) > 0 && dT > eps) {
        // Speed possibly already has powerFactor effect
        double dD = (stub.speed ?? 0.0) * DeviceDescriptor.kmh2ms * dT;
        stub.distance = stub.distance! + dD;
      }
    }

    // #235
    stub.movingTime = lastRecord.movingTime + dTMillis;
    // #197 After 2 seconds we assume all types of feature packets showed up
    // and it should have been decided if there's total distance / calories
    // time reporting or not
    if (stub.movingTime >= 2000) {
      firstDistance = false;
      firstCalories = false;
    }

    // #197
    stub.distance ??= 0.0;
    if (_startingDistance > eps) {
      stub.distance = stub.distance! - _startingDistance;
    }

    if ((stub.heartRate == null || stub.heartRate == 0) && (hrmRecord?.heartRate ?? 0) > 0) {
      stub.heartRate = hrmRecord!.heartRate;
    }

    // #93, #113
    if ((stub.heartRate == null || stub.heartRate == 0) &&
        (lastRecord.heartRate ?? 0) > 0 &&
        _heartRateGapWorkaround == dataGapWorkaroundLastPositiveValue) {
      stub.heartRate = lastRecord.heartRate;
    }

    // #114
    if (_heartRateUpperLimit > 0 &&
        (stub.heartRate ?? 0) > _heartRateUpperLimit &&
        _heartRateLimitingMethod != heartRateLimitingNoLimit) {
      if (_heartRateLimitingMethod == heartRateLimitingCapAtLimit) {
        stub.heartRate = _heartRateUpperLimit;
      } else {
        stub.heartRate = 0;
      }
    }

    final calories1 = stub.calories?.toDouble() ?? 0.0;
    final calories2 = hrmRecord?.calories?.toDouble() ?? 0.0;
    var calories = 0.0;
    if (deviceHasTotalCalorieReporting &&
        calories1 > eps &&
        (!_useHrmReportedCalories || calories2 < eps) &&
        (!_useHrBasedCalorieCounting || stub.heartRate == null || stub.heartRate == 0)) {
      calories = calories1;
    } else if (hrmHasTotalCalorieReporting &&
        calories2 > eps &&
        (_useHrmReportedCalories || calories1 < eps) &&
        (!_useHrBasedCalorieCounting || stub.heartRate == null || stub.heartRate == 0)) {
      calories = calories2;
    } else {
      var deltaCalories = 0.0;
      if (_useHrBasedCalorieCounting && (stub.heartRate ?? 0) > 0) {
        stub.caloriesPerMinute =
            hrBasedCaloriesPerMinute(stub.heartRate!, _weight, _age, _isMale, _vo2Max) *
                hrCalorieFactor;
      }

      if (deltaCalories < eps && stub.caloriesPerHour != null && stub.caloriesPerHour! > eps) {
        deltaCalories = stub.caloriesPerHour! / (60 * 60) * dT;
      }

      if (deltaCalories < eps && stub.caloriesPerMinute != null && stub.caloriesPerMinute! > eps) {
        deltaCalories = stub.caloriesPerMinute! / 60 * dT;
      }

      // Supplement power from calories https://www.braydenwm.com/calburn.htm
      if ((stub.power ?? 0) < eps) {
        if ((stub.caloriesPerMinute ?? 0.0) > eps) {
          stub.power = (stub.caloriesPerMinute! * 50.0 / 3.0).round(); // 60 * 1000 / 3600
        } else if ((stub.caloriesPerHour ?? 0.0) > eps) {
          stub.power = (stub.caloriesPerHour! * 5.0 / 18.0).round(); // 1000 / 3600
        }

        if (stub.power != null) {
          stub.power = (stub.power! * powerFactor).round();
        }
      }

      // Should we only use power based calorie integration if sport == ActivityType.ride?
      if (deltaCalories < eps && (stub.power ?? 0) > eps) {
        deltaCalories =
            stub.power! * dT * jToKCal * calorieFactor * DeviceDescriptor.powerCalorieFactorDefault;
      }

      _residueCalories += deltaCalories;
      final lastCalories = lastRecord.calories ?? 0.0;
      calories = lastCalories + _residueCalories;
      if (calories.floor() > lastCalories) {
        _residueCalories = calories - calories.floor();
      }
    }

    if (stub.pace != null && stub.pace! > 0 && slowPace != null && stub.pace! < slowPace! ||
        stub.speed != null && stub.speed! > eps) {
      // #101, #122
      if ((stub.cadence == null || stub.cadence == 0) &&
          _lastPositiveCadence > 0 &&
          _cadenceGapWorkaround) {
        stub.cadence = _lastPositiveCadence;
      } else if (stub.cadence != null && stub.cadence! > 0) {
        _lastPositiveCadence = stub.cadence!;
      }
    }

    // #111
    if (calories < eps && _lastPositiveCalories > eps) {
      calories = _lastPositiveCalories;
    } else if (calories > eps && _lastPositiveCalories < eps) {
      _lastPositiveCalories = calories;
    }

    // #197
    if (_startingCalories > eps) {
      if (kDebugMode) {
        assert(deviceHasTotalCalorieReporting || hrmHasTotalCalorieReporting);
        assert(calories >= _startingCalories);
      }

      if (logLevel >= logLevelInfo) {
        Logging.log(
          logLevel,
          logLevelInfo,
          "FITNESS_EQUIPMENT",
          "processRecord",
          "starting calorie adj $calories - $_startingCalories",
        );
      }

      calories -= _startingCalories;
    }

    stub.calories = calories.floor();
    stub.activityId = _activity?.id ?? 0;
    stub.sport = descriptor?.defaultSport ?? ActivityType.ride;

    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "processRecord",
        "stub before cumulative $stub",
      );
    }

    if (!uxDebug) {
      stub.cumulativeMetricsEnforcements(
        lastRecord,
        logLevel,
        forDistance: !firstDistance,
        forTime: true,
        forCalories: !firstCalories,
      );
    }

    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "processRecord",
        "stub after processable $stub",
      );
    }

    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "processRecord",
        "#2 _residueCalories $_residueCalories, "
            "_lastPositiveCadence $_lastPositiveCadence, "
            "_lastPositiveCalories $_lastPositiveCalories, "
            "firstCalories $firstCalories, "
            "_startingCalories $_startingCalories, "
            "firstDistance $firstDistance, "
            "_startingDistance $_startingDistance, "
            "deviceHasTotalCalorieReporting $deviceHasTotalCalorieReporting, "
            "hrmHasTotalCalorieReporting $hrmHasTotalCalorieReporting, "
            "hasTotalDistanceReporting $hasTotalDistanceReporting",
      );
    }

    lastRecord = stub;
    return continuation ? RecordWithSport.offsetForward(stub, continuationRecord) : stub;
  }

  Future<void> refreshFactors() async {
    if (!Get.isRegistered<AppDatabase>()) {
      return;
    }

    final database = Get.find<AppDatabase>();
    final factors = await database.getFactors(device?.id.id ?? "");
    powerFactor = factors.item1;
    calorieFactor = factors.item2;
    hrCalorieFactor = factors.item3;
    hrmCalorieFactor =
        await database.calorieFactorValue(heartRateMonitor?.device?.id.id ?? "", true);

    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "refreshFactors",
        "powerFactor $powerFactor, "
            "calorieFactor $calorieFactor, "
            "hrCalorieFactor $hrCalorieFactor, "
            "hrmCalorieFactor $hrmCalorieFactor",
      );
    }
  }

  @override
  void readConfiguration() {
    super.readConfiguration();
    final prefService = Get.find<BasePrefService>();
    _cadenceGapWorkaround =
        prefService.get<bool>(cadenceGapWorkaroundTag) ?? cadenceGapWorkaroundDefault;
    _heartRateGapWorkaround =
        prefService.get<String>(heartRateGapWorkaroundTag) ?? heartRateGapWorkaroundDefault;
    _heartRateUpperLimit =
        prefService.get<int>(heartRateUpperLimitIntTag) ?? heartRateUpperLimitDefault;
    _heartRateLimitingMethod =
        prefService.get<String>(heartRateLimitingMethodTag) ?? heartRateLimitingMethodDefault;
    _useHrmReportedCalories = prefService.get<bool>(useHrMonitorReportedCaloriesTag) ??
        useHrMonitorReportedCaloriesDefault;
    _useHrBasedCalorieCounting = prefService.get<bool>(useHeartRateBasedCalorieCountingTag) ??
        useHeartRateBasedCalorieCountingDefault;
    _weight = prefService.get<int>(athleteBodyWeightIntTag) ?? athleteBodyWeightDefault;
    _age = prefService.get<int>(athleteAgeTag) ?? athleteAgeDefault;
    _isMale =
        (prefService.get<String>(athleteGenderTag) ?? athleteGenderDefault) == athleteGenderMale;
    _vo2Max = prefService.get<int>(athleteVO2MaxTag) ?? athleteVO2MaxDefault;
    _useHrBasedCalorieCounting &= (_weight > athleteBodyWeightMin && _age > athleteAgeMin);
    _extendTuning = prefService.get<bool>(extendTuningTag) ?? extendTuningDefault;
    _blockSignalStartStop =
        testing || (prefService.get<bool>(blockSignalStartStopTag) ?? blockSignalStartStopDefault);

    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "readConfiguration",
        "cadenceGapWorkaround $_cadenceGapWorkaround, "
            "uxDebug $uxDebug, "
            "heartRateGapWorkaround $_heartRateGapWorkaround, "
            "heartRateUpperLimit $_heartRateUpperLimit, "
            "heartRateLimitingMethod $_heartRateLimitingMethod, "
            "useHrmReportedCalories $_useHrmReportedCalories, "
            "useHrBasedCalorieCounting $_useHrBasedCalorieCounting, "
            "weight $_weight, "
            "age $_age, "
            "isMale $_isMale, "
            "vo2Max $_vo2Max, "
            "useHrBasedCalorieCounting $_useHrBasedCalorieCounting, "
            "extendTuning $_extendTuning, "
            "logLevel $logLevel",
      );
    }

    refreshFactors();
  }

  Future<void> startWorkout() async {
    readConfiguration();
    _residueCalories = 0.0;
    _lastPositiveCalories = 0.0;
    firstCalories = true;
    firstDistance = true;
    _startingCalories = 0.0;
    _startingDistance = 0.0;
    dataHandlers = {};
    lastRecord = RecordWithSport.getZero(sport);

    if (!_blockSignalStartStop && descriptor != null) {
      await descriptor!.executeControlOperation(
        controlPoint,
        _blockSignalStartStop,
        logLevel,
        startOrResumeControl,
      );
    }
  }

  void stopWorkout() {
    if (!_blockSignalStartStop && descriptor != null) {
      descriptor!.executeControlOperation(
        controlPoint,
        _blockSignalStartStop,
        logLevel,
        stopOrPauseControl,
        controlInfo: stopControlInfo,
      );
    }

    readConfiguration();
    _residueCalories = 0.0;
    _lastPositiveCalories = 0.0;
    _timer?.cancel();
    descriptor?.stopWorkout();
  }

  @override
  Future<void> detach() async {
    await _extraSensor?.detach();
    await super.detach();
  }
}
