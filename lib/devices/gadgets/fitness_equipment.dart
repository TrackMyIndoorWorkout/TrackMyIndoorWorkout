import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:rxdart/rxdart.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../../utils/delays.dart';
import '../../utils/guid_ex.dart';
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
  bool _startingValues = true; // #197
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
  int _weight = ATHLETE_BODY_WEIGHT_DEFAULT;
  int _age = ATHLETE_AGE_DEFAULT;
  bool _isMale = true;
  int _vo2Max = ATHLETE_VO2MAX_DEFAULT;
  Activity? _activity;
  bool measuring = false;
  bool calibrating = false;
  Random _random = Random();
  double? slowPace;
  bool equipmentDiscovery = false;

  FitnessEquipment({this.descriptor, device})
      : super(
          serviceId: descriptor?.dataServiceId ?? FITNESS_MACHINE_ID,
          characteristicsId: descriptor?.dataCharacteristicId,
          device: device,
        ) {
    readConfiguration();
    lastRecord = RecordWithSport.getBlank(sport, uxDebug, _random);
  }

  String get sport => _activity?.sport ?? (descriptor?.defaultSport ?? ActivityType.Ride);
  double get powerFactor => _activity?.powerFactor ?? (descriptor?.powerFactor ?? 1.0);
  double get calorieFactor => _activity?.calorieFactor ?? (descriptor?.calorieFactor ?? 1.0);
  double get residueCalories => _residueCalories;
  double get lastPositiveCalories => _lastPositiveCalories;

  Stream<Record> get _listenToData async* {
    if (!attached || characteristic == null || descriptor == null) return;

    await for (var byteString
        in characteristic!.value.throttleTime(Duration(milliseconds: FTMS_DATA_THRESHOLD))) {
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
        Duration(seconds: 1),
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
    if (sport == ActivityType.Run) {
      if (services.firstWhereOrNull(
              (service) => service.uuid.uuidString() == RUNNING_CADENCE_SERVICE_ID) !=
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

  Future<bool> discover({bool identify = false, bool retry = false}) async {
    if (uxDebug) return true;

    final success = await super.discover(retry: retry);
    if (identify || !success) return success;

    if (equipmentDiscovery || descriptor == null) return false;

    equipmentDiscovery = true;
    // Check manufacturer name
    if (manufacturerName == null) {
      final deviceInfo = BluetoothDeviceEx.filterService(services, DEVICE_INFORMATION_ID);
      final nameCharacteristic =
          BluetoothDeviceEx.filterCharacteristic(deviceInfo?.characteristics, MANUFACTURER_NAME_ID);
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

  // Based on https://www.braydenwm.com/calburn.htm
  double _caloriesPerMinute(int heartRate) {
    if (_vo2Max > ATHLETE_VO2MAX_MIN) {
      if (_isMale) {
        return (-59.3954 +
                (-36.3781 + 0.271 * _age + 0.394 * _weight + 0.404 * _vo2Max + 0.634 * heartRate)) /
            4.184;
      } else {
        return (-59.3954 + (0.274 * _age + 0.103 * _weight + 0.380 * _vo2Max + 0.450 * heartRate)) /
            4.184;
      }
    } else {
      if (_isMale) {
        return (-55.0969 + 0.6309 * heartRate + 0.1988 * _weight + 0.2017 * _age) / 4.184;
      } else {
        return (-20.4022 + 0.4472 * heartRate - 0.1263 * _weight + 0.074 * _age) / 4.184;
      }
    }
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
    if (_startingValues) {
      if (stub.elapsed! > 2) {
        _startingElapsed = stub.elapsed!;
        stub.elapsed = 0;
      }
    } else if (_startingElapsed > 0) {
      stub.elapsed = stub.elapsed! - _startingElapsed;
    }

    if (sport == ActivityType.Run &&
        _runningCadenceSensor != null &&
        (_runningCadenceSensor?.attached ?? false)) {
      if ((stub.cadence == null || stub.cadence == 0) &&
          (_runningCadenceSensor?.record?.cadence ?? 0) > 0) {
        stub.cadence = _runningCadenceSensor!.record!.cadence;
      }

      if ((stub.speed == null || stub.speed == 0) &&
          (_runningCadenceSensor?.record?.speed ?? 0.0) > EPS) {
        stub.speed = _runningCadenceSensor!.record!.speed;
      }

      if ((stub.distance == null || stub.distance == 0) &&
          (_runningCadenceSensor?.record?.distance ?? 0.0) > EPS) {
        stub.distance = _runningCadenceSensor!.record!.distance;
      }
    }

    final dT = (elapsedMillis - lastRecord.elapsedMillis!) / 1000.0;
    if ((stub.distance ?? 0.0) < EPS) {
      stub.distance = (lastRecord.distance ?? 0);
      if ((stub.speed ?? 0.0) > 0 && dT > EPS) {
        // Speed possibly already has powerFactor effect
        double dD = (stub.speed ?? 0.0) * DeviceDescriptor.KMH2MS * dT;
        stub.distance = stub.distance! + dD;
      }
    }

    // #197
    if (stub.distance == null) {
      stub.distance = 0.0;
    }
    if (_startingValues) {
      if (stub.distance! > 50.0) {
        _startingDistance = stub.distance!;
        stub.distance = 0.0;
      }
    } else if (_startingDistance > EPS) {
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
    if (calories1 > EPS &&
        (!_useHrmReportedCalories || calories2 < EPS) &&
        (!_useHrBasedCalorieCounting || stub.heartRate == null || stub.heartRate == 0)) {
      calories = calories1;
    } else if (calories2 > EPS &&
        (_useHrmReportedCalories || calories1 < EPS) &&
        (!_useHrBasedCalorieCounting || stub.heartRate == null || stub.heartRate == 0)) {
      calories = calories2;
    } else {
      var deltaCalories = 0.0;
      if (_useHrBasedCalorieCounting && stub.heartRate != null && stub.heartRate! > 0) {
        stub.caloriesPerMinute = _caloriesPerMinute(stub.heartRate!) * calorieFactor;
      }

      if (deltaCalories < EPS && stub.caloriesPerHour != null && stub.caloriesPerHour! > EPS) {
        deltaCalories = stub.caloriesPerHour! / (60 * 60) * dT;
      }

      if (deltaCalories < EPS && stub.caloriesPerMinute != null && stub.caloriesPerMinute! > EPS) {
        deltaCalories = stub.caloriesPerMinute! / 60 * dT;
      }

      // Supplement power from calories https://www.braydenwm.com/calburn.htm
      if (stub.power == null || stub.power! < EPS) {
        if (stub.caloriesPerMinute != null && stub.caloriesPerMinute! > EPS) {
          stub.power = (stub.caloriesPerMinute! * 50.0 / 3.0).round(); // 60 * 1000 / 3600
        } else if (stub.caloriesPerHour != null && stub.caloriesPerHour! > EPS) {
          stub.power = (stub.caloriesPerHour! * 5.0 / 18.0).round(); // 1000 / 3600
        }

        if (stub.power != null) {
          stub.power = (stub.power! * powerFactor).round();
        }
      }

      if (deltaCalories < EPS && stub.power != null && stub.power! > EPS) {
        deltaCalories = stub.power! * dT * J_TO_KCAL * calorieFactor;
      }

      _residueCalories += deltaCalories;
      final lastCalories = lastRecord.calories ?? 0.0;
      calories = lastCalories + _residueCalories;
      if (calories.floor() > lastCalories) {
        _residueCalories = calories - calories.floor();
      }
    }

    if (stub.pace != null && stub.pace! > 0 && slowPace != null && stub.pace! < slowPace! ||
        stub.speed != null && stub.speed! > EPS) {
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
    if (calories < EPS && _lastPositiveCalories > 0) {
      calories = _lastPositiveCalories;
    } else {
      _lastPositiveCalories = calories;
    }

    // #197
    if (_startingValues) {
      if (calories >= 2.0) {
        _startingCalories = calories;
        calories = 0.0;
      }
    } else if (_startingCalories > EPS) {
      calories -= _startingCalories;
    }

    stub.calories = calories.floor();

    stub.activityId = _activity?.id ?? 0;
    stub.sport = descriptor?.defaultSport ?? ActivityType.Ride;

    _startingValues = false;

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
    _weight = prefService.get<int>(ATHLETE_BODY_WEIGHT_INT_TAG) ?? ATHLETE_BODY_WEIGHT_DEFAULT;
    _age = prefService.get<int>(ATHLETE_AGE_TAG) ?? ATHLETE_AGE_DEFAULT;
    _isMale = (prefService.get<String>(ATHLETE_GENDER_TAG) ?? ATHLETE_GENDER_DEFAULT) ==
        ATHLETE_GENDER_MALE;
    _vo2Max = prefService.get<int>(ATHLETE_VO2MAX_TAG) ?? ATHLETE_VO2MAX_DEFAULT;
    _useHrBasedCalorieCounting &= (_weight > ATHLETE_BODY_WEIGHT_MIN && _age > ATHLETE_AGE_MIN);
    _runningCadenceSensor?.refreshFactors();
  }

  void startWorkout() {
    readConfiguration();
    _runningCadenceSensor?.refreshFactors();
    _residueCalories = 0.0;
    _lastPositiveCalories = 0.0;
    _startingValues = true;
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
