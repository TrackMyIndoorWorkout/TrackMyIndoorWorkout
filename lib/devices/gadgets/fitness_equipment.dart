import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:preferences/preference_service.dart';
import 'package:rxdart/rxdart.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../../utils/preferences.dart';
import '../device_descriptors/device_descriptor.dart';
import '../bluetooth_device_ex.dart';
import '../gatt_constants.dart';
import 'device_base.dart';
import 'heart_rate_monitor.dart';

typedef RecordHandlerFunction = Function(Record data);

class FitnessEquipment extends DeviceBase {
  DeviceDescriptor descriptor;
  String manufacturerName;
  double _residueCalories;
  int _lastPositiveCadence; // #101
  bool _cadenceGapWorkaround = CADENCE_GAP_WORKAROUND_DEFAULT;
  double _lastPositiveCalories; // #111
  bool hasTotalCalorieCounting;
  Timer _timer;
  Record lastRecord;
  HeartRateMonitor heartRateMonitor;
  String _heartRateGapWorkaround = HEART_RATE_GAP_WORKAROUND_DEFAULT;
  int _heartRateUpperLimit = HEART_RATE_UPPER_LIMIT_DEFAULT_INT;
  String _heartRateLimitingMethod = HEART_RATE_LIMITING_NO_LIMIT;
  Activity _activity;
  bool measuring;
  bool calibrating;
  Random _random;
  double slowPace;
  bool equipmentDiscovery;

  FitnessEquipment({this.descriptor, device})
      : assert(descriptor != null),
        super(
          serviceId: descriptor.dataServiceId,
          characteristicsId: descriptor.dataCharacteristicId,
          device: device,
        ) {
    _residueCalories = 0.0;
    _lastPositiveCadence = 0;
    _cadenceGapWorkaround =
        PrefService.getBool(CADENCE_GAP_WORKAROUND_TAG) ?? CADENCE_GAP_WORKAROUND_DEFAULT;
    _lastPositiveCalories = 0.0;
    hasTotalCalorieCounting = false;
    measuring = false;
    calibrating = false;
    _random = Random();
    uxDebug = PrefService.getBool(APP_DEBUG_MODE_TAG) ?? APP_DEBUG_MODE_DEFAULT;
    lastRecord = RecordWithSport.getBlank(sport, uxDebug, _random);
    _heartRateGapWorkaround =
        PrefService.getString(HEART_RATE_GAP_WORKAROUND_TAG) ?? HEART_RATE_GAP_WORKAROUND_DEFAULT;
    _heartRateUpperLimit = getStringIntegerPreference(
      HEART_RATE_UPPER_LIMIT_TAG,
      HEART_RATE_UPPER_LIMIT_DEFAULT,
      HEART_RATE_UPPER_LIMIT_DEFAULT_INT,
    );
    _heartRateLimitingMethod =
        PrefService.getString(HEART_RATE_LIMITING_METHOD_TAG) ?? HEART_RATE_LIMITING_NO_LIMIT;
    equipmentDiscovery = false;
  }

  String get sport => _activity?.sport ?? descriptor.defaultSport;
  double get powerFactor => _activity?.powerFactor ?? descriptor.powerFactor;
  double get calorieFactor => _activity?.calorieFactor ?? descriptor.calorieFactor;
  double get residueCalories => _residueCalories;
  double get lastPositiveCalories => _lastPositiveCalories;

  Stream<Record> get _listenToData async* {
    if (!attached) return;
    await for (var byteString in characteristic.value.throttleTime(Duration(milliseconds: 450))) {
      if (!descriptor.canDataProcessed(byteString)) continue;
      if (!measuring && !calibrating) continue;

      final record = descriptor.stubRecord(byteString);
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
      subscription = _listenToData.listen((recordStub) {
        final record = processRecord(recordStub);
        recordHandlerFunction(record);
      });
    }
  }

  void setHeartRateMonitor(HeartRateMonitor heartRateMonitor) {
    this.heartRateMonitor = heartRateMonitor;
  }

  void setActivity(Activity activity) {
    this._activity = activity;
    uxDebug = PrefService.getBool(APP_DEBUG_MODE_TAG) ?? APP_DEBUG_MODE_DEFAULT;
  }

  Future<bool> connectOnDemand(BluetoothDeviceState deviceState) async {
    if (deviceState == BluetoothDeviceState.disconnected ||
        deviceState == BluetoothDeviceState.disconnecting) {
      await connect();
    }

    if (deviceState == BluetoothDeviceState.connected && !discovering || connected) {
      return await discover();
    }

    return false;
  }

  Future<bool> discover({bool retry = false}) async {
    if (uxDebug) return true;

    final success = await super.discover(retry: retry);
    if (!success) return false;

    if (equipmentDiscovery) return false;

    equipmentDiscovery = true;
    // Check manufacturer name
    // Will need to elaborate when generic GATT Fitness Machine support is added
    final deviceInfo = BluetoothDeviceEx.filterService(services, DEVICE_INFORMATION_ID);
    final nameCharacteristic =
        BluetoothDeviceEx.filterCharacteristic(deviceInfo?.characteristics, MANUFACTURER_NAME_ID);
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

    equipmentDiscovery = false;
    return manufacturerName == descriptor.manufacturer;
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
    hasTotalCalorieCounting =
        hasTotalCalorieCounting || (stub.calories != null && stub.calories > 0);
    if (hasTotalCalorieCounting && (stub.elapsed ?? 0) > 0) {
      elapsed = stub.elapsed.toDouble();
    }

    if (stub.elapsed == null || stub.elapsed == 0) {
      stub.elapsed = elapsed.round();
    }

    if (stub.elapsedMillis == null || stub.elapsedMillis == 0) {
      stub.elapsedMillis = elapsedMillis;
    }

    final dT = (elapsedMillis - lastRecord.elapsedMillis) / 1000.0;
    if ((stub.distance ?? 0.0) < EPS) {
      stub.distance = (lastRecord.distance ?? 0);
      if ((stub.speed ?? 0.0) > 0 && dT > EPS) {
        // Speed possibly already has powerFactor effect
        double dD = stub.speed * DeviceDescriptor.KMH2MS * dT;
        stub.distance += dD;
      }
    }

    var calories = 0.0;
    if (stub.calories != null && stub.calories > 0) {
      calories = stub.calories.toDouble();
      hasTotalCalorieCounting = true;
    } else {
      var deltaCalories = 0.0;
      if (stub.caloriesPerHour != null && stub.caloriesPerHour > EPS) {
        deltaCalories = stub.caloriesPerHour / (60 * 60) * dT;
      }

      if (deltaCalories < EPS && stub.caloriesPerMinute != null && stub.caloriesPerMinute > EPS) {
        deltaCalories = stub.caloriesPerMinute / 60 * dT;
      }

      if (deltaCalories < EPS && stub.power != null && stub.power > EPS) {
        deltaCalories = stub.power * dT * DeviceDescriptor.J2KCAL * calorieFactor;
      }

      _residueCalories += deltaCalories;
      final lastCalories = lastRecord.calories ?? 0.0;
      calories = lastCalories + _residueCalories;
      if (calories.floor() > lastCalories) {
        _residueCalories = calories - calories.floor();
      }
    }

    if (stub.pace != null && stub.pace > 0 && stub.pace < slowPace ||
        stub.speed != null && stub.speed > EPS) {
      // #101, #122
      if ((stub.cadence == null || stub.cadence == 0) &&
          _lastPositiveCadence > 0 &&
          _cadenceGapWorkaround) {
        stub.cadence = _lastPositiveCadence;
      } else if (stub.cadence != null && stub.cadence > 0) {
        _lastPositiveCadence = stub.cadence;
      }
    }

    // #111
    if ((calories == null || calories < EPS) && _lastPositiveCalories > 0) {
      calories = _lastPositiveCalories;
    } else if (calories != null && calories > EPS) {
      _lastPositiveCalories = calories;
    }

    stub.calories = calories?.floor() ?? 0;

    if (stub.heartRate == 0 && (heartRateMonitor?.metric ?? 0) > 0) {
      stub.heartRate = heartRateMonitor.metric;
    }

    // #93, #113
    if (stub.heartRate == 0 &&
        lastRecord.heartRate > 0 &&
        _heartRateGapWorkaround == DATA_GAP_WORKAROUND_LAST_POSITIVE_VALUE) {
      stub.heartRate = lastRecord.heartRate;
    }
    // #114
    if (_heartRateUpperLimit > 0 &&
        stub.heartRate > _heartRateUpperLimit &&
        _heartRateLimitingMethod != HEART_RATE_LIMITING_NO_LIMIT) {
      if (_heartRateLimitingMethod == HEART_RATE_LIMITING_CAP_AT_LIMIT) {
        stub.heartRate = _heartRateUpperLimit;
      } else {
        stub.heartRate = 0;
      }
    }

    stub.activityId = _activity?.id;
    stub.sport = descriptor.defaultSport;
    return stub;
  }

  void startWorkout() {
    _residueCalories = 0.0;
    _lastPositiveCalories = 0.0;
    lastRecord = RecordWithSport.getBlank(sport, uxDebug, _random);
  }

  void stopWorkout() {
    uxDebug = PrefService.getBool(APP_DEBUG_MODE_TAG) ?? APP_DEBUG_MODE_DEFAULT;
    _residueCalories = 0.0;
    _lastPositiveCalories = 0.0;
    _timer?.cancel();
    descriptor.stopWorkout();
  }
}
