import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:rxdart/rxdart.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import '../../preferences/athlete_age.dart';
import '../../preferences/athlete_body_weight.dart';
import '../../preferences/athlete_gender.dart';
import '../../preferences/athlete_vo2max.dart';
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
  DeviceDescriptor? descriptor;
  String? manufacturerName;
  double _residueCalories = 0.0;
  int _lastPositiveCadence = 0; // #101
  bool _cadenceGapWorkaround = CADENCE_GAP_WORKAROUND_DEFAULT;
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
  String _heartRateGapWorkaround = HEART_RATE_GAP_WORKAROUND_DEFAULT;
  int _heartRateUpperLimit = HEART_RATE_UPPER_LIMIT_DEFAULT;
  String _heartRateLimitingMethod = HEART_RATE_LIMITING_NO_LIMIT;
  bool _useHrmReportedCalories = USE_HR_MONITOR_REPORTED_CALORIES_DEFAULT;
  bool _useHrBasedCalorieCounting = USE_HEART_RATE_BASED_CALORIE_COUNTING_DEFAULT;
  int _weight = athleteBodyWeightDefault;
  int _age = athleteAgeDefault;
  bool _isMale = true;
  int _vo2Max = athleteVO2MaxDefault;
  Activity? _activity;
  bool measuring = false;
  bool calibrating = false;
  final Random _random = Random();
  double? slowPace;
  bool equipmentDiscovery = false;

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
  double get powerFactor => _activity?.powerFactor ?? (descriptor?.powerFactor ?? 1.0);
  double get calorieFactor => _activity?.calorieFactor ?? (descriptor?.calorieFactor ?? 1.0);
  double get hrCalorieFactor => _activity?.hrCalorieFactor ?? (descriptor?.hrCalorieFactor ?? 1.0);
  double get residueCalories => _residueCalories;
  double get lastPositiveCalories => _lastPositiveCalories;

  Stream<Record> get _listenToData async* {
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

    if (equipmentDiscovery || descriptor == null) return false;

    equipmentDiscovery = true;
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

    equipmentDiscovery = false;
    return manufacturerName!.contains(descriptor!.manufacturerPrefix) ||
        descriptor!.manufacturerPrefix == "Unknown";
  }

  Record processRecord(Record stub) {
    final now = DateTime.now();
    int elapsedMillis = now.difference(_activity?.startDateTime ?? now).inMilliseconds;
    double elapsed = elapsedMillis / 1000.0;
    // When the equipment supplied multiple data read per second but the Fitness Machine
    // standard only supplies second resolution elapsed time the delta time becomes zero
    // Therefore the FTMS elapsed time reading is kinda useless, causes problems.
    // With this fix the calorie zeroing bug is revealed. Calorie preserving workaround can be
    // toggled in the settings now. Only the distance perseverance could pose a glitch. #94
    hasTotalCalorieCounting = hasTotalCalorieCounting ||
        (stub.calories != null && stub.calories! > 0) ||
        (heartRateMonitor != null && (heartRateMonitor?.record?.calories ?? 0) > 0);
    if (hasTotalCalorieCounting &&
        stub.elapsed != null &&
        ((stub.calories != null && stub.calories! > 0) ||
            (heartRateMonitor != null && (heartRateMonitor?.record?.calories ?? 0) > 0))) {
      elapsed = stub.elapsed!.toDouble();
    }

    if (stub.elapsed == null || stub.elapsed == 0) {
      stub.elapsed = elapsed.round();
    }

    if (stub.elapsedMillis == null || stub.elapsedMillis == 0) {
      stub.elapsedMillis = elapsedMillis;
    }

    // #197
    if (startingValues) {
      if (stub.elapsed! > 2) {
        _startingElapsed = stub.elapsed!;
        stub.elapsed = 0;
      }
    } else if (_startingElapsed > 0) {
      stub.elapsed = stub.elapsed! - _startingElapsed;
    }

    if (sport == ActivityType.run &&
        _runningCadenceSensor != null &&
        (_runningCadenceSensor?.attached ?? false)) {
      if ((stub.cadence == null || stub.cadence == 0) &&
          (_runningCadenceSensor?.record?.cadence ?? 0) > 0) {
        stub.cadence = _runningCadenceSensor!.record!.cadence;
      }

      if ((stub.speed == null || stub.speed == 0) &&
          (_runningCadenceSensor?.record?.speed ?? 0.0) > eps) {
        stub.speed = _runningCadenceSensor!.record!.speed;
      }

      if ((stub.distance == null || stub.distance == 0) &&
          (_runningCadenceSensor?.record?.distance ?? 0.0) > eps) {
        stub.distance = _runningCadenceSensor!.record!.distance;
      }
    }

    final dT = (elapsedMillis - lastRecord.elapsedMillis!) / 1000.0;
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
    if (startingValues) {
      if (stub.distance! > 50.0) {
        _startingDistance = stub.distance!;
        stub.distance = 0.0;
      }
    } else if (_startingDistance > eps) {
      stub.distance = stub.distance! - _startingDistance;
    }

    if ((stub.heartRate == null || stub.heartRate == 0) &&
        (heartRateMonitor?.record?.heartRate ?? 0) > 0) {
      stub.heartRate = heartRateMonitor!.record!.heartRate;
    }

    // #93, #113
    if ((stub.heartRate == null || stub.heartRate == 0) &&
        lastRecord.heartRate != null &&
        lastRecord.heartRate! > 0 &&
        _heartRateGapWorkaround == DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE) {
      stub.heartRate = lastRecord.heartRate;
    }

    // #114
    if (_heartRateUpperLimit > 0 &&
        (stub.heartRate ?? 0) > _heartRateUpperLimit &&
        _heartRateLimitingMethod != HEART_RATE_LIMITING_NO_LIMIT) {
      if (_heartRateLimitingMethod == HEART_RATE_LIMITING_CAP_AT_LIMIT) {
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
    if (heartRateMonitor != null && (heartRateMonitor?.record?.calories ?? 0) > 0) {
      calories2 = heartRateMonitor?.record?.calories?.toDouble() ?? 0.0;
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
        deltaCalories = stub.power! * dT * jToKCal * calorieFactor;
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
    if (startingValues) {
      if (calories >= 2.0) {
        _startingCalories = calories;
        calories = 0.0;
      }
    } else if (_startingCalories > eps) {
      calories -= _startingCalories;
    }

    stub.calories = calories.floor();

    stub.activityId = _activity?.id ?? 0;
    stub.sport = descriptor?.defaultSport ?? ActivityType.ride;

    startingValues = false;

    // TODO: write tests
    // Make sure that cumulative fields cannot decrease over time
    if (stub.distance != null &&
        lastRecord.distance != null &&
        stub.distance! < lastRecord.distance!) {
      stub.distance = lastRecord.distance;
    }

    if (stub.elapsed != null && lastRecord.elapsed != null && stub.elapsed! < lastRecord.elapsed!) {
      stub.elapsed = lastRecord.elapsed;
    }

    if (stub.calories != null &&
        lastRecord.calories != null &&
        stub.calories! < lastRecord.calories!) {
      stub.calories = lastRecord.calories;
    }

    return stub;
  }

  void readConfiguration() {
    final prefService = Get.find<BasePrefService>();
    _cadenceGapWorkaround =
        prefService.get<bool>(CADENCE_GAP_WORKAROUND_TAG) ?? CADENCE_GAP_WORKAROUND_DEFAULT;
    uxDebug = prefService.get<bool>(APP_DEBUG_MODE_TAG) ?? APP_DEBUG_MODE_DEFAULT;
    _heartRateGapWorkaround =
        prefService.get<String>(HEART_RATE_GAP_WORKAROUND_TAG) ?? HEART_RATE_GAP_WORKAROUND_DEFAULT;
    _heartRateUpperLimit =
        prefService.get<int>(HEART_RATE_UPPER_LIMIT_INT_TAG) ?? HEART_RATE_UPPER_LIMIT_DEFAULT;
    _heartRateLimitingMethod =
        prefService.get<String>(HEART_RATE_LIMITING_METHOD_TAG) ?? HEART_RATE_LIMITING_NO_LIMIT;
    _useHrmReportedCalories = prefService.get<bool>(USE_HR_MONITOR_REPORTED_CALORIES_TAG) ??
        USE_HR_MONITOR_REPORTED_CALORIES_DEFAULT;
    _useHrBasedCalorieCounting = prefService.get<bool>(USE_HEART_RATE_BASED_CALORIE_COUNTING_TAG) ??
        USE_HEART_RATE_BASED_CALORIE_COUNTING_DEFAULT;
    _weight = prefService.get<int>(athleteBodyWeightIntTag) ?? athleteBodyWeightDefault;
    _age = prefService.get<int>(athleteAgeTag) ?? athleteAgeDefault;
    _isMale =
        (prefService.get<String>(athleteGenderTag) ?? athleteGenderDefault) == athleteGenderMale;
    _vo2Max = prefService.get<int>(athleteVO2MaxTag) ?? athleteVO2MaxDefault;
    _useHrBasedCalorieCounting &= (_weight > athleteBodyWeightMin && _age > athleteAgeMin);
    _runningCadenceSensor?.refreshFactors();
  }

  void startWorkout() {
    readConfiguration();
    _runningCadenceSensor?.refreshFactors();
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
