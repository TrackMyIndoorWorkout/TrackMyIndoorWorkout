import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:rxdart/rxdart.dart';
import '../../persistence/database.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../preferences/app_debug_mode.dart';
import '../../preferences/athlete_age.dart';
import '../../preferences/athlete_body_weight.dart';
import '../../preferences/athlete_gender.dart';
import '../../preferences/athlete_vo2max.dart';
import '../../preferences/cadence_data_gap_workaround.dart';
import '../../preferences/extend_tuning.dart';
import '../../preferences/heart_rate_gap_workaround.dart';
import '../../preferences/heart_rate_limiting.dart';
import '../../preferences/use_heart_rate_based_calorie_counting.dart';
import '../../preferences/use_hr_monitor_reported_calories.dart';
import '../../utils/constants.dart';
import '../../utils/delays.dart';
import '../../utils/guid_ex.dart';
import '../../utils/hr_based_calories.dart';
import '../device_descriptors/device_descriptor.dart';
import '../bluetooth_device_ex.dart';
import '../gatt_constants.dart';
import 'device_base.dart';
import 'heart_rate_monitor.dart';
import 'running_cadence_sensor.dart';

typedef RecordHandlerFunction = Function(Record data);

class FitnessEquipment extends DeviceBase {
  static const testing = bool.fromEnvironment('testing_mode', defaultValue: false);

  DeviceDescriptor? descriptor;
  String? manufacturerName;
  double _residueCalories = 0.0;
  int _lastPositiveCadence = 0; // #101
  bool _cadenceGapWorkaround = cadenceGapWorkaroundDefault;
  double _lastPositiveCalories = 0.0; // #111
  bool startingValues; // #197
  double _startingCalories = 0.0;
  double _startingDistance = 0.0;
  int _startingElapsed = 0;
  bool hasTotalCalorieCounting = false;
  Timer? _timer;
  late Record lastRecord;
  HeartRateMonitor? heartRateMonitor;
  RunningCadenceSensor? _runningCadenceSensor;
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
  bool reallyStarted = false;
  bool calibrating = false;
  final Random _random = Random();
  double? slowPace;
  bool _equipmentDiscovery = false;
  bool _extendTuning = false;

  FitnessEquipment({this.descriptor, device, this.startingValues = true})
      : super(
          serviceId: descriptor?.dataServiceId ?? fitnessMachineUuid,
          characteristicsId: descriptor?.dataCharacteristicId,
          device: device,
        ) {
    readConfiguration();
    lastRecord = RecordWithSport.getBlank(sport, uxDebug, _random);
  }

  String get sport => _activity?.sport ?? (descriptor?.defaultSport ?? ActivityType.ride);
  double get residueCalories => _residueCalories;
  double get lastPositiveCalories => _lastPositiveCalories;

  Stream<RecordWithSport> get _listenToData async* {
    if (!attached || characteristic == null || descriptor == null) return;

    await for (var byteString
        in characteristic!.value.throttleTime(const Duration(milliseconds: ftmsDataThreshold))) {
      if (!descriptor!.canDataProcessed(byteString)) continue;
      if (!measuring && !calibrating) continue;

      final record = descriptor!.stubRecord(byteString);
      if (record == null) continue;
      yield record;
    }
  }

  void pumpData(RecordHandlerFunction recordHandlerFunction) {
    if (uxDebug) {
      _timer = Timer(
        const Duration(seconds: 1),
        () {
          final record = processRecord(RecordWithSport.getRandom(sport, _random));
          recordHandlerFunction(record);
          pumpData(recordHandlerFunction);
        },
      );
    } else {
      _runningCadenceSensor?.pumpData(null);
      subscription = _listenToData.listen((recordStub) {
        final record = processRecord(recordStub);
        recordHandlerFunction(record);
      });
    }
  }

  void setHeartRateMonitor(HeartRateMonitor heartRateMonitor) {
    this.heartRateMonitor = heartRateMonitor;
  }

  Future<void> additionalSensorsOnDemand() async {
    await refreshFactors();

    if (_runningCadenceSensor != null && _runningCadenceSensor?.device?.id.id != device?.id.id) {
      await _runningCadenceSensor?.detach();
      _runningCadenceSensor = null;
    }
    if (sport == ActivityType.run) {
      if (services.firstWhereOrNull(
              (service) => service.uuid.uuidString() == runningCadenceServiceUuid) !=
          null) {
        _runningCadenceSensor = RunningCadenceSensor(device, powerFactor);
        _runningCadenceSensor?.services = services;
        _runningCadenceSensor?.discoverCore();
        await _runningCadenceSensor?.attach();
      }
    }
  }

  void setActivity(Activity activity) {
    _activity = activity;
    lastRecord = RecordWithSport.getBlank(sport, uxDebug, _random);
    reallyStarted = false;
    readConfiguration();
  }

  Future<bool> connectOnDemand({identify = false}) async {
    await connect();

    return await discover(identify: identify);
  }

  @override
  Future<bool> discover({bool identify = false, bool retry = false}) async {
    if (uxDebug) return true;

    final success = await super.discover(retry: retry);
    if (identify || !success) return success;

    if (_equipmentDiscovery || descriptor == null) return false;

    _equipmentDiscovery = true;
    // Check manufacturer name
    if (manufacturerName == null) {
      final deviceInfo = BluetoothDeviceEx.filterService(services, deviceInformationUuid);
      final nameCharacteristic =
          BluetoothDeviceEx.filterCharacteristic(deviceInfo?.characteristics, manufacturerNameUuid);
      if (nameCharacteristic == null) {
        return false;
      }

      try {
        final nameBytes = await nameCharacteristic.read();
        manufacturerName = String.fromCharCodes(nameBytes);
      } on PlatformException catch (e, stack) {
        debugPrint("$e");
        debugPrintStack(stackTrace: stack, label: "trace:");
        // 2nd try
        try {
          final nameBytes = await nameCharacteristic.read();
          manufacturerName = String.fromCharCodes(nameBytes);
        } on PlatformException catch (e, stack) {
          debugPrint("$e");
          debugPrintStack(stackTrace: stack, label: "trace:");
        }
      }
    }

    _equipmentDiscovery = false;
    return manufacturerName!.contains(descriptor!.manufacturerPrefix) ||
        descriptor!.manufacturerPrefix == "Unknown";
  }

  @visibleForTesting
  void setFactors(powerFactor, calorieFactor, hrCalorieFactor, hrmCalorieFactor, extendTuning) {
    this.powerFactor = powerFactor;
    this.calorieFactor = calorieFactor;
    this.hrCalorieFactor = hrCalorieFactor;
    this.hrmCalorieFactor = hrmCalorieFactor;
    _extendTuning = extendTuning;
  }

  Record processRecord(RecordWithSport stub) {
    final now = DateTime.now();
    if (!reallyStarted) {
      if (stub.isNotMoving()) {
        return stub;
      } else {
        reallyStarted = true;
        if (_activity != null) {
          _activity!.startDateTime = now;
          _activity!.start = now.millisecondsSinceEpoch;
          if (Get.isRegistered<AppDatabase>()) {
            final database = Get.find<AppDatabase>();
            database.activityDao.updateActivity(_activity!);
          }
        }
      }
    }

    if (descriptor != null) {
      stub = descriptor!.adjustRecord(stub, powerFactor, calorieFactor, _extendTuning);
    }

    int elapsedMillis = now.difference(_activity?.startDateTime ?? now).inMilliseconds;
    double elapsed = elapsedMillis / 1000.0;
    // When the equipment supplied multiple data read per second but the Fitness Machine
    // standard only supplies second resolution elapsed time the delta time becomes zero
    // Therefore the FTMS elapsed time reading is kinda useless, causes problems.
    // With this fix the calorie zeroing bug is revealed. Calorie preserving workaround can be
    // toggled in the settings now. Only the distance perseverance could pose a glitch. #94
    final stubHasCalories = stub.calories != null && stub.calories! > 0;
    final hrmRecord = heartRateMonitor?.record != null
        ? descriptor!.adjustRecord(
            heartRateMonitor!.record!,
            powerFactor,
            hrmCalorieFactor,
            _extendTuning,
          )
        : null;
    final hrmHasCalories = (hrmRecord?.calories ?? 0) > 0;
    hasTotalCalorieCounting = hasTotalCalorieCounting || stubHasCalories || hrmHasCalories;
    if (hasTotalCalorieCounting && stub.elapsed != null && (stubHasCalories || hrmHasCalories)) {
      elapsed = stub.elapsed!.toDouble();
    }

    if (stub.elapsed == null || stub.elapsed == 0) {
      stub.elapsed = elapsed.round();
    }

    if (stub.elapsedMillis == null || stub.elapsedMillis == 0) {
      stub.elapsedMillis = elapsedMillis;
    }

    // #197
    if (startingValues && stub.elapsed! > 2) {
      _startingElapsed = stub.elapsed!;
    }
    // #197
    if (_startingElapsed > 0) {
      stub.elapsed = stub.elapsed! - _startingElapsed;
    }

    RecordWithSport? rscRecord;
    if (sport == ActivityType.run &&
        _runningCadenceSensor != null &&
        (_runningCadenceSensor?.attached ?? false)) {
      if (_runningCadenceSensor?.record != null) {
        rscRecord = descriptor!.adjustRecord(
          _runningCadenceSensor!.record!,
          powerFactor,
          calorieFactor,
          _extendTuning,
        );
      }

      if ((stub.cadence == null || stub.cadence == 0) && (rscRecord?.cadence ?? 0) > 0) {
        stub.cadence = rscRecord!.cadence;
      }

      if ((stub.speed == null || stub.speed == 0) && (rscRecord?.speed ?? 0.0) > eps) {
        stub.speed = rscRecord!.speed;
      }

      if ((stub.distance == null || stub.distance == 0) && (rscRecord?.distance ?? 0.0) > eps) {
        stub.distance = rscRecord!.distance;
      }
    }

    final dT = (elapsedMillis - (lastRecord.elapsedMillis ?? 0)) / 1000.0;
    if ((stub.distance ?? 0.0) < eps) {
      stub.distance = (lastRecord.distance ?? 0);
      if ((stub.speed ?? 0.0) > 0 && dT > eps) {
        // Speed possibly already has powerFactor effect
        double dD = (stub.speed ?? 0.0) * DeviceDescriptor.kmh2ms * dT;
        stub.distance = stub.distance! + dD;
      }
    }

    // #197
    stub.distance ??= 0.0;
    if (startingValues && stub.distance! >= 50.0) {
      _startingDistance = stub.distance!;
    }
    // #197
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

    var calories1 = 0.0;
    if (stub.calories != null && stub.calories! > 0) {
      calories1 = stub.calories!.toDouble();
      hasTotalCalorieCounting = true;
    }

    var calories2 = 0.0;
    if ((hrmRecord?.calories ?? 0) > 0) {
      calories2 = hrmRecord?.calories?.toDouble() ?? 0.0;
      hasTotalCalorieCounting = true;
    }

    var calories = 0.0;
    if (calories1 > eps &&
        (!_useHrmReportedCalories || calories2 < eps) &&
        (!_useHrBasedCalorieCounting || stub.heartRate == null || stub.heartRate == 0)) {
      calories = calories1;
    } else if (calories2 > eps &&
        (_useHrmReportedCalories || calories1 < eps) &&
        (!_useHrBasedCalorieCounting || stub.heartRate == null || stub.heartRate == 0)) {
      calories = calories2;
    } else {
      var deltaCalories = 0.0;
      if (_useHrBasedCalorieCounting && stub.heartRate != null && stub.heartRate! > 0) {
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
      if (stub.power == null || stub.power! < eps) {
        if (stub.caloriesPerMinute != null && stub.caloriesPerMinute! > eps) {
          stub.power = (stub.caloriesPerMinute! * 50.0 / 3.0).round(); // 60 * 1000 / 3600
        } else if (stub.caloriesPerHour != null && stub.caloriesPerHour! > eps) {
          stub.power = (stub.caloriesPerHour! * 5.0 / 18.0).round(); // 1000 / 3600
        }

        if (stub.power != null) {
          stub.power = (stub.power! * powerFactor).round();
        }
      }

      if (deltaCalories < eps && stub.power != null && stub.power! > eps) {
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
    if (calories < eps && _lastPositiveCalories > 0) {
      calories = _lastPositiveCalories;
    } else {
      _lastPositiveCalories = calories;
    }

    // #197
    if (startingValues && calories >= 2.0) {
      _startingCalories = calories;
    }
    // #197
    if (_startingCalories > eps) {
      // Only possible with hasTotalCalorieCounting
      assert(hasTotalCalorieCounting);
      calories -= _startingCalories;
    }

    stub.calories = calories.floor();
    stub.activityId = _activity?.id ?? 0;
    stub.sport = descriptor?.defaultSport ?? ActivityType.ride;

    if (!startingValues) {
      // Make sure that cumulative fields cannot decrease over time
      if (stub.distance != null && lastRecord.distance != null) {
        if (!testing) {
          assert(stub.distance! >= lastRecord.distance!);
        }

        if (stub.distance! < lastRecord.distance!) {
          stub.distance = lastRecord.distance;
        }
      }

      if (stub.elapsed != null && lastRecord.elapsed != null) {
        if (!testing) {
          assert(stub.elapsed! >= lastRecord.elapsed!);
        }

        if (stub.elapsed! < lastRecord.elapsed!) {
          stub.elapsed = lastRecord.elapsed;
        }
      }

      if (stub.calories != null && lastRecord.calories != null) {
        if (!testing) {
          assert(stub.calories! >= lastRecord.calories!);
        }

        if (stub.calories! < lastRecord.calories!) {
          stub.calories = lastRecord.calories;
        }
      }
    }

    startingValues = false;

    return stub;
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
  }

  void readConfiguration() {
    final prefService = Get.find<BasePrefService>();
    _cadenceGapWorkaround =
        prefService.get<bool>(cadenceGapWorkaroundTag) ?? cadenceGapWorkaroundDefault;
    uxDebug = prefService.get<bool>(appDebugModeTag) ?? appDebugModeDefault;
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

    refreshFactors();
  }

  void startWorkout() {
    readConfiguration();
    _residueCalories = 0.0;
    _lastPositiveCalories = 0.0;
    startingValues = true;
    _startingCalories = 0.0;
    _startingDistance = 0.0;
    _startingElapsed = 0;
    lastRecord = RecordWithSport.getBlank(sport, uxDebug, _random);
  }

  void stopWorkout() {
    readConfiguration();
    _residueCalories = 0.0;
    _lastPositiveCalories = 0.0;
    _timer?.cancel();
    descriptor?.stopWorkout();
  }

  @override
  Future<void> detach() async {
    await super.detach();
    await _runningCadenceSensor?.detach();
  }
}
