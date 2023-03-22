import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import '../../preferences/athlete_age.dart';
import '../../preferences/athlete_body_weight.dart';
import '../../preferences/athlete_gender.dart';
import '../../preferences/athlete_vo2max.dart';
import '../../preferences/block_signal_start_stop.dart';
import '../../preferences/cadence_data_gap_workaround.dart';
import '../../persistence/database.dart';
import '../../preferences/extend_tuning.dart';
import '../../preferences/enable_asserts.dart';
import '../../preferences/heart_rate_gap_workaround.dart';
import '../../preferences/heart_rate_limiting.dart';
import '../../preferences/heart_rate_monitor_priority.dart';
import '../../preferences/log_level.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../preferences/use_heart_rate_based_calorie_counting.dart';
import '../../preferences/use_hr_monitor_reported_calories.dart';
import '../../utils/constants.dart';
import '../../utils/delays.dart';
import '../../utils/hr_based_calories.dart';
import '../../utils/logging.dart';
import '../../utils/power_speed_mixin.dart';
import '../bluetooth_device_ex.dart';
import '../device_descriptors/data_handler.dart';
import '../device_descriptors/device_descriptor.dart';
import '../device_descriptors/kaya_first_descriptor.dart';
import '../device_fourcc.dart';
import '../gadgets/complex_sensor.dart';
import '../gatt/ftms.dart';
import '../gatt/generic.dart';
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
  justPaused,
  paused,
}

class DataEntry {
  final List<int> byteList;
  late final DateTime timeStamp;

  DataEntry(this.byteList) {
    timeStamp = DateTime.now();
  }
}

class FitnessEquipment extends DeviceBase with PowerSpeedMixin {
  static const badKey = -1;

  DeviceDescriptor? descriptor;
  Map<int, DataHandler> dataHandlers = {};
  String? manufacturerName;
  double _residueCalories = 0.0;
  int _lastPositiveCadence = 0; // #101
  bool _cadenceGapWorkaround = cadenceGapWorkaroundDefault;
  double _lastPositiveCalories = 0.0; // #111
  bool _firstCalories = true; // #197 #234 #259
  double _startingCalories = 0.0;
  bool _firstDistance = true; // #197 #234 #259
  double _startingDistance = 0.0;
  bool deviceHasTotalCalorieReporting = false;
  bool hrmHasTotalCalorieReporting = false;
  bool hasTotalDistanceReporting = false;
  bool hasPowerReporting = false;
  bool hasSpeedReporting = false;
  Timer? _timer;
  late RecordWithSport lastRecord;
  late Record continuationRecord;
  bool continuation = false;
  HeartRateMonitor? heartRateMonitor;
  ComplexSensor? _companionSensor;
  DeviceDescriptor? _companionDescriptor;
  List<ComplexSensor> _additionalSensors = [];
  String _heartRateGapWorkaround = heartRateGapWorkaroundDefault;
  int _heartRateUpperLimit = heartRateUpperLimitDefault;
  String _heartRateLimitingMethod = heartRateLimitingMethodDefault;
  double _powerFactor = 1.0;
  double _calorieFactor = 1.0;
  double _hrCalorieFactor = 1.0;
  double _hrmCalorieFactor = 1.0;
  bool _useHrmReportedCalories = useHrMonitorReportedCaloriesDefault;
  bool useHrBasedCalorieCounting = useHeartRateBasedCalorieCountingDefault;
  bool _heartRateMonitorPriority = heartRateMonitorPriorityDefault;
  int weight = athleteBodyWeightDefault;
  int age = athleteAgeDefault;
  bool isMale = true;
  int vo2Max = athleteVO2MaxDefault;
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
  bool _enableAsserts = enableAssertsDefault;

  // For Throttling + deduplication #234
  final Duration _throttleDuration = const Duration(milliseconds: ftmsDataThreshold);
  final Map<int, DataEntry> _listDeduplicationMap = {};
  Timer? _throttleTimer;
  RecordHandlerFunction? _recordHandlerFunction;

  FitnessEquipment({this.descriptor, device})
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

  String get sport => _activity?.sport ?? (descriptor?.sport ?? ActivityType.ride);
  double get residueCalories => _residueCalories;
  double get lastPositiveCalories => _lastPositiveCalories;
  bool get isMoving =>
      workoutState == WorkoutState.moving || workoutState == WorkoutState.startedMoving;
  double get powerFactor => _powerFactor;
  double get calorieFactor => _calorieFactor;
  double get hrCalorieFactor => _hrCalorieFactor;
  double get hrmCalorieFactor => _hrmCalorieFactor;

  int keySelector(List<int> l) {
    if (l.isEmpty) {
      return badKey;
    }

    if (descriptor?.isPolling ?? false) {
      return l[0] + (descriptor! as KayakFirstDescriptor).separatorCount(l) * 256;
    }

    if (l.length == 1 || descriptor?.flagByteSize == 1) {
      return l[0];
    }

    if (l.length >= 3 && (descriptor?.flagByteSize ?? 2) == 3) {
      return l[2] * 65536 + l[1] * 256 + l[0];
    }

    // Default flagByteSize is 2
    return l[1] * 256 + l[0];
  }

  RecordWithSport? _mergedForYield() {
    // Only look at data entries not older than 2 seconds
    final now = DateTime.now();
    final values = _listDeduplicationMap.entries
        .where((entry1) => now.difference(entry1.value.timeStamp).inMilliseconds <= dataMapExpiry)
        .map((entry2) => dataHandlers[entry2.key]?.wrappedStubRecord(entry2.value.byteList))
        .whereNotNull()
        .toList(growable: false);

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

    final merged = values.length == 1
        ? values.first
        : values.skip(1).fold<RecordWithSport>(
              values.first,
              (prev, element) => prev.merge(element),
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

      if (workoutState == WorkoutState.justPaused || workoutState == WorkoutState.paused) {
        if (merged == null) {
          pumpDataCore(pausedRecord(RecordWithSport(sport: sport)), true);
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
  /// * Stages SB20 has three packet types: 1. speed, 2. distance, 3.
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
      debugPrint("KayakFirst: ${utf8.decode(byteList)}");
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
      if (key >= 0 && descriptor!.isFlagValid(key)) {
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
          _listDeduplicationMap[key] = DataEntry(byteList);
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
      _companionSensor?.pumpData(null);
      for (final sensor in _additionalSensors) {
        sensor.pumpData(null);
      }

      subscription = _listenToData.listen((recordStub) {
        pumpDataCore(recordStub, false);
      });
    }
  }

  void setHeartRateMonitor(HeartRateMonitor heartRateMonitor) {
    this.heartRateMonitor = heartRateMonitor;
    final hrmId = heartRateMonitor.device?.id.id;
    if (hrmId == null) {
      return;
    }

    if (_companionSensor?.device?.id.id == hrmId) {
      // Remove companion because external initiated HRM's lifecycle
      // spans beyond the FitnessMachine (so we should prevent detach)
      _companionSensor = null;
    }

    if (_additionalSensors.where((sensor) => sensor.device?.id.id == hrmId).isNotEmpty) {
      // Present as an additional sensor
      // Remove from additional sensor list, because the lifecycle
      // spans beyond the FitnessMachine (so we should prevent detach)
      _additionalSensors =
          _additionalSensors.where((sensor) => sensor.device?.id.id != hrmId).toList();
    }
  }

  Future<void> additionalSensorsOnDemand() async {
    await refreshFactors();

    bool hadDetach = false;
    for (final sensor in _additionalSensors) {
      if (sensor.device?.id.id != device?.id.id) {
        await sensor.detach();
        hadDetach = true;
      }
    }

    if (hadDetach) {
      _additionalSensors =
          _additionalSensors.where((sensor) => sensor.device?.id.id == device?.id.id).toList();
    }

    if (descriptor != null && device != null) {
      _additionalSensors = descriptor!.getAdditionalSensors(device!, services);
      for (final sensor in _additionalSensors) {
        await sensor.discoverCore();
        await sensor.attach();
      }
    } else {
      _additionalSensors = [];
    }
  }

  Future<void> addCompanionSensor(
    DeviceDescriptor companionDescriptor,
    BluetoothDevice companionDevice,
  ) async {
    if (heartRateMonitor?.device?.id.id == companionDevice.id.id) {
      // It's a HRM and already set
      return;
    }

    _companionDescriptor = companionDescriptor;
    _companionSensor = _companionDescriptor?.getSensor(companionDevice);
    await _companionSensor?.connect();
    await _companionSensor?.discover();
    await _companionSensor?.attach();
  }

  Future<void> addIdentifiedCompanionSensor(
      DeviceDescriptor identifiedDescriptor, ComplexSensor identifiedSensor) async {
    // TODO: what if we are overwriting another one?
    _companionDescriptor = identifiedDescriptor;
    _companionSensor = identifiedSensor;
    await _companionSensor?.attach();
  }

  void trimQueues() {
    descriptor?.trimQueues();
    _companionSensor?.trimQueues();
    for (final sensor in _additionalSensors) {
      sensor.trimQueues();
    }
  }

  Future<void> setActivity(Activity activity) async {
    _activity = activity;
    lastRecord = RecordWithSport.getZero(sport);
    if (Get.isRegistered<AppDatabase>()) {
      final database = Get.find<AppDatabase>();
      final lastRecord = activity.id != null
          ? await database.recordDao.findLastRecordOfActivity(activity.id!)
          : null;
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

    final success = await discover(identify: identify);
    if (success) {
      descriptor?.setDevice(device!, services);
    }

    return success;
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

      if (logLevel >= logLevelInfo) {
        Logging.log(
          logLevel,
          logLevelInfo,
          "FITNESS_EQUIPMENT",
          "_fitnessMachineFeature",
          "readFeatures $readFeatures writeFeatures $writeFeatures "
              "_speedLevels $_speedLevels _inclinationLevels $_inclinationLevels "
              "_resistanceLevels $_resistanceLevels _heartRateLevels $_heartRateLevels "
              "_powerLevels $_powerLevels supportsSpinDown $supportsSpinDown",
        );
      }
    } on PlatformException catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }
  }

  BluetoothCharacteristic? getControlPoint() {
    return descriptor?.fourCC == kayakFirstFourCC ? characteristic : controlPoint;
  }

  @override
  Future<void> connectToControlPoint(bool obtainControl) async {
    if (controlCharacteristicId.isEmpty) {
      return;
    }

    await super.connectToControlPoint(obtainControl);
    if (obtainControl && !_blockSignalStartStop && descriptor != null) {
      await descriptor!.executeControlOperation(
        getControlPoint(),
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
        "ensuring that manufacturer name ($manufacturerName) contains manufacturer name part ${descriptor!.manufacturerNamePart}",
      );
    }

    if (descriptor!.manufacturerNamePart == "Unknown") {
      return true;
    }

    return manufacturerName
            ?.toLowerCase()
            .contains(descriptor!.manufacturerNamePart.toLowerCase()) ??
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
    _powerFactor = powerFactor;
    _calorieFactor = calorieFactor;
    _hrCalorieFactor = hrCalorieFactor;
    _hrmCalorieFactor = hrmCalorieFactor;
    _extendTuning = extendTuning;
  }

  @visibleForTesting
  void setFirstDistance(bool firstDistance) {
    _firstDistance = firstDistance;
  }

  @visibleForTesting
  void setFirstCalories(bool firstCalories) {
    _firstCalories = firstCalories;
  }

  @visibleForTesting
  void setStartingValues(double startingDistance, double startingCalories) {
    _startingDistance = startingDistance;
    _firstDistance = false;
    _startingCalories = startingCalories;
    _firstCalories = false;
  }

  RecordWithSport pausedRecord(RecordWithSport record) {
    trimQueues();

    if (record.calories != null) {
      record.calories = max(record.calories! - _startingCalories.round(), 0);
    }

    if (record.distance != null) {
      record.distance = max(record.distance! - _startingDistance, 0.0);
    }

    record.cumulativeMetricsEnforcements(
      lastRecord,
      logLevel,
      _enableAsserts,
      forDistance: !_firstDistance,
      forCalories: !_firstCalories,
      force: true,
    );

    if ((heartRateMonitor?.record.heartRate ?? 0) > 0 &&
        (record.heartRate == null || record.heartRate == 0 || _heartRateMonitorPriority)) {
      record.heartRate = heartRateMonitor?.record.heartRate;
    }

    return record;
  }

  RecordWithSport processRecord(RecordWithSport stub, [bool idle = false]) {
    final now = DateTime.now();
    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "processRecord",
        "stub at $now $stub",
      );
    }

    if (_companionSensor != null && _companionSensor!.attached) {
      if (logLevel >= logLevelInfo) {
        Logging.log(
          logLevel,
          logLevelInfo,
          "FITNESS_EQUIPMENT",
          "processRecord",
          "merging companion sensor ${_companionSensor!.record}",
        );
      }

      stub.merge(_companionSensor!.record);
    }

    for (final sensor in _additionalSensors) {
      if (sensor.attached) {
        if (logLevel >= logLevelInfo) {
          Logging.log(
            logLevel,
            logLevelInfo,
            "FITNESS_EQUIPMENT",
            "processRecord",
            "merging additional sensor ${sensor.record}",
          );
        }

        stub.merge(sensor.record);
      }
    }

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
          stub.adjustTime(elapsedMillis ~/ 1000, elapsedMillis);
          lastRecord.adjustTime(elapsedMillis ~/ 1000, elapsedMillis);
          return pausedRecord(stub);
        }

        return pausedRecord(stub);
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
        if (isMoving) {
          workoutState = WorkoutState.justPaused;
        } else {
          workoutState = WorkoutState.paused;
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
      stub.adjustByFactors(_powerFactor, _calorieFactor, _extendTuning);
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
            "_firstCalories $_firstCalories, "
            "_startingCalories $_startingCalories, "
            "_firstDistance $_firstDistance, "
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
    hrmRecord?.adjustByFactors(_powerFactor, _hrmCalorieFactor, _extendTuning);
    final hrmReportsCalories = !idle && hrmRecord?.calories != null;
    hrmHasTotalCalorieReporting |= hrmReportsCalories;
    // All of these starting* and hasTotal* codes have to come before the (optional) merge
    // and after tuning / factoring adjustments #197
    if (_firstCalories) {
      if (_useHrmReportedCalories) {
        if (hrmHasTotalCalorieReporting && (hrmRecord?.calories ?? 0) > 0) {
          _startingCalories = hrmRecord!.calories!.toDouble();
          _firstCalories = false;
        }
      } else if (deviceHasTotalCalorieReporting && (stub.calories ?? 0) > 0) {
        _startingCalories = stub.calories!.toDouble();
        _firstCalories = false;
      }
    }

    hasTotalDistanceReporting |= stub.distance != null;
    if (hasTotalDistanceReporting && _firstDistance && (stub.distance ?? 0.0) >= 50.0) {
      _startingDistance = stub.distance!;
      _firstDistance = false;
    }

    hasPowerReporting |= (stub.power ?? 0) > 0;
    hasSpeedReporting |= (stub.speed ?? 0.0) > 0.0;

    stub.elapsed = elapsed.round();
    stub.elapsedMillis = elapsedMillis;

    if (workoutState == WorkoutState.paused) {
      // We have to track the time ticking even when the workout paused #235
      lastRecord.adjustTime(stub.elapsed!, elapsedMillis);
      return pausedRecord(stub);
    }

    if (!hasSpeedReporting &&
        isMoving &&
        sport == ActivityType.ride &&
        stub.speed == null &&
        (stub.power ?? 0) > eps) {
      // When cycling supplement speed from power if missing
      // via https://www.gribble.org/cycling/power_v_speed.html
      stub.speed = velocityForPowerCardano(stub.power!) * DeviceDescriptor.ms2kmh;
    }

    final dTMillis = elapsedMillis - (lastRecord.elapsedMillis ?? 0);
    final dT = dTMillis / 1000.0;
    if ((stub.distance ?? 0.0) < eps) {
      stub.distance = (lastRecord.distance ?? 0.0);
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
      _firstDistance = false;
      _firstCalories = false;
    }

    // #197
    stub.distance ??= 0.0;
    if (_startingDistance > eps) {
      if (kDebugMode && _enableAsserts) {
        assert(stub.distance! >= _startingDistance);
      }

      if (logLevel >= logLevelInfo) {
        Logging.log(
          logLevel,
          logLevelInfo,
          "FITNESS_EQUIPMENT",
          "processRecord",
          "starting distance adj ${stub.distance!} - $_startingDistance",
        );
      }

      stub.distance = max(stub.distance! - _startingDistance, 0.0);
    }

    // #376
    if ((hrmRecord?.heartRate ?? 0) > 0 &&
        (stub.heartRate == null || stub.heartRate == 0 || _heartRateMonitorPriority)) {
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
        (!useHrBasedCalorieCounting || stub.heartRate == null || stub.heartRate == 0)) {
      calories = calories1;
    } else if (hrmHasTotalCalorieReporting &&
        calories2 > eps &&
        (_useHrmReportedCalories || calories1 < eps) &&
        (!useHrBasedCalorieCounting || stub.heartRate == null || stub.heartRate == 0)) {
      calories = calories2;
    } else {
      var deltaCalories = 0.0;
      if (useHrBasedCalorieCounting && (stub.heartRate ?? 0) > 0) {
        stub.caloriesPerMinute =
            hrBasedCaloriesPerMinute(stub.heartRate!, weight, age, isMale, vo2Max) *
                _hrCalorieFactor;
      }

      if (deltaCalories < eps && stub.caloriesPerHour != null && stub.caloriesPerHour! > eps) {
        deltaCalories = stub.caloriesPerHour! / (60 * 60) * dT;
      }

      if (deltaCalories < eps && stub.caloriesPerMinute != null && stub.caloriesPerMinute! > eps) {
        deltaCalories = stub.caloriesPerMinute! / 60 * dT;
      }

      // Only do supplementation when moving #
      if (isMoving && (stub.power ?? 0) < eps) {
        // Supplement power from calories https://www.braydenwm.com/calburn.htm
        if ((stub.caloriesPerMinute ?? 0.0) > eps) {
          stub.power = (stub.caloriesPerMinute! * 50.0 / 3.0).round(); // 60 * 1000 / 3600
        } else if ((stub.caloriesPerHour ?? 0.0) > eps) {
          stub.power = (stub.caloriesPerHour! * 5.0 / 18.0).round(); // 1000 / 3600
        } else if (!hasPowerReporting && (stub.speed ?? 0) > displayEps) {
          // When cycling supplement power from speed if missing
          // via https://www.gribble.org/cycling/power_v_speed.html
          stub.power = powerForVelocity(stub.speed! * DeviceDescriptor.kmh2ms, sport).toInt();
        }

        if (stub.power != null) {
          stub.power = (stub.power! * _powerFactor).round();
        }
      }

      // Should we only use power based calorie integration if sport == ActivityType.ride?
      if (deltaCalories < eps && (stub.power ?? 0) > eps) {
        deltaCalories = stub.power! *
            dT *
            jToKCal *
            _calorieFactor *
            DeviceDescriptor.powerCalorieFactorDefault;
      }

      _residueCalories += deltaCalories;
      final lastCalories = lastRecord.calories ?? 0.0;
      calories = lastCalories + _residueCalories;
      if (calories.floor() > lastCalories) {
        _residueCalories = calories - calories.floor();
      }
    }

    if (isMoving &&
        !hasPowerReporting &&
        sport == ActivityType.ride &&
        (stub.power ?? 0) < eps &&
        stub.speed != null &&
        stub.speed! > displayEps) {
      // When cycling supplement power from speed if missing
      // via https://www.gribble.org/cycling/power_v_speed.html
      stub.power =
          (powerForVelocity(stub.speed! * DeviceDescriptor.kmh2ms, sport) * _powerFactor).round();
    }

    if (stub.pace != null && stub.pace! > 0.0 && slowPace != null && stub.pace! < slowPace! ||
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
      if (kDebugMode && _enableAsserts) {
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

      calories = max(calories - _startingCalories, 0.0);
    }

    stub.calories = calories.floor();
    stub.activityId = _activity?.id ?? 0;
    stub.sport = descriptor?.sport ?? ActivityType.ride;

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
        _enableAsserts,
        forDistance: !_firstDistance,
        forCalories: !_firstCalories,
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
            "_firstCalories $_firstCalories, "
            "_startingCalories $_startingCalories, "
            "_firstDistance $_firstDistance, "
            "_startingDistance $_startingDistance, "
            "deviceHasTotalCalorieReporting $deviceHasTotalCalorieReporting, "
            "hrmHasTotalCalorieReporting $hrmHasTotalCalorieReporting, "
            "hasTotalDistanceReporting $hasTotalDistanceReporting",
      );
    }

    // debugPrint("$stub");
    lastRecord = stub;
    return continuation ? RecordWithSport.offsetForward(stub, continuationRecord) : stub;
  }

  Future<void> refreshFactors() async {
    if (!Get.isRegistered<AppDatabase>()) {
      return;
    }

    final database = Get.find<AppDatabase>();
    final factors = await database.getFactors(device?.id.id ?? "");
    _powerFactor = factors.item1;
    _calorieFactor = factors.item2;
    _hrCalorieFactor = factors.item3;
    _hrmCalorieFactor =
        await database.calorieFactorValue(heartRateMonitor?.device?.id.id ?? "", true);

    initPower2SpeedConstants();

    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "FITNESS_EQUIPMENT",
        "refreshFactors",
        "_powerFactor $_powerFactor, "
            "_calorieFactor $_calorieFactor, "
            "_hrCalorieFactor $_hrCalorieFactor, "
            "_hrmCalorieFactor $_hrmCalorieFactor",
      );
    }
  }

  @override
  void readConfiguration() {
    super.readConfiguration();
    for (final sensor in _additionalSensors) {
      sensor.readConfiguration();
    }

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
    useHrBasedCalorieCounting = prefService.get<bool>(useHeartRateBasedCalorieCountingTag) ??
        useHeartRateBasedCalorieCountingDefault;
    _heartRateMonitorPriority =
        prefService.get<bool>(heartRateMonitorPriorityTag) ?? heartRateMonitorPriorityDefault;
    weight = prefService.get<int>(athleteBodyWeightIntTag) ?? athleteBodyWeightDefault;
    age = prefService.get<int>(athleteAgeTag) ?? athleteAgeDefault;
    isMale =
        (prefService.get<String>(athleteGenderTag) ?? athleteGenderDefault) == athleteGenderMale;
    vo2Max = prefService.get<int>(athleteVO2MaxTag) ?? athleteVO2MaxDefault;
    useHrBasedCalorieCounting &= (weight > athleteBodyWeightMin && age > athleteAgeMin);
    _extendTuning = prefService.get<bool>(extendTuningTag) ?? extendTuningDefault;
    _blockSignalStartStop =
        testing || (prefService.get<bool>(blockSignalStartStopTag) ?? blockSignalStartStopDefault);
    _enableAsserts = prefService.get<bool>(enableAssertsTag) ?? enableAssertsDefault;

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
            "useHrBasedCalorieCounting $useHrBasedCalorieCounting, "
            "weight $weight, "
            "age $age, "
            "isMale $isMale, "
            "vo2Max $vo2Max, "
            "extendTuning $_extendTuning, "
            "logLevel $logLevel",
      );
    }

    refreshFactors();
  }

  void _pollingTimerCallback() {
    if (measuring) {
      _startPollingTimer();
    }
  }

  void _startPollingTimer() {
    _timer = Timer(_throttleDuration, _pollingTimerCallback);
    descriptor?.pollMeasurement(getControlPoint()!, logLevel);
  }

  Future<void> startWorkout() async {
    readConfiguration();
    _residueCalories = 0.0;
    _lastPositiveCalories = 0.0;
    _firstCalories = true;
    _firstDistance = true;
    _startingCalories = 0.0;
    _startingDistance = 0.0;
    dataHandlers = {};
    lastRecord = RecordWithSport.getZero(sport);

    if ((!_blockSignalStartStop || (descriptor?.isPolling ?? false)) && descriptor != null) {
      await descriptor!.executeControlOperation(
        getControlPoint(),
        _blockSignalStartStop,
        logLevel,
        startOrResumeControl,
      );

      if (descriptor?.isPolling ?? false) {
        _startPollingTimer();
      }
    }
  }

  void stopWorkout() {
    if ((!_blockSignalStartStop || (descriptor?.isPolling ?? false)) && descriptor != null) {
      descriptor!.executeControlOperation(
        getControlPoint(),
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
    for (final sensor in _additionalSensors) {
      await sensor.detach();
    }

    await _companionSensor?.detach();
    await super.detach();
  }
}
