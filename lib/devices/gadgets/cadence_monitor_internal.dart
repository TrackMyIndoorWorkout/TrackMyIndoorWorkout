import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../persistence/record.dart';
import '../../preferences/log_level.dart';
import '../../utils/cadence_processing.dart';
import '../../utils/constants.dart';
import '../../utils/logging.dart';
import 'complex_sensor.dart';

class DeviceInternalMotion extends ComplexSensor {
  static const String logTag = "INTERNAL_MOTION";
  final String targetSport;
  final CadenceProcessor _processor = CadenceProcessor(windowSize: 200); // 4s @ 50Hz
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  // Throttle processing
  DateTime _lastProcessTime = DateTime.now();
  final Duration _processInterval = const Duration(milliseconds: 1000); // Update every 1s

  DeviceInternalMotion({this.targetSport = ActivityType.workout})
    : super("", "", BluetoothDevice(remoteId: const DeviceIdentifier("INTERNAL_MOTION")));

  @override
  void clearMetrics() {
    // No specific metrics to clear internally for now
  }

  @override
  Future<bool> connect() async {
    // Mimic successful connection
    if (connected) return true;
    connecting = true;
    // We could check permission/availability here, but usually done in UI.
    connecting = false;
    connected = true;
    return true;
  }

  @override
  Future<bool> discover() async {
    // Mimic successful discovery
    if (discovered) return true;
    discovering = true;
    discovered = true;
    discovering = false;
    // We don't populate services/characteristics since we are not using BLE
    return true;
  }

  @override
  Future<void> attach() async {
    // Mimic successful attach
    attached = true;
  }

  @override
  void pumpData(ComplexMetricProcessingFunction? metricProcessingFunction) {
    if (metricProcessingFunction == null) return;

    // Start listening to internal sensors
    if (_sensorSubscription == null) {
      _startListening(metricProcessingFunction);
    }
  }

  void _startListening(ComplexMetricProcessingFunction metricProcessingFunction) {
    try {
      _sensorSubscription = accelerometerEventStream().listen((event) {
        final now = DateTime.now();

        _processor.addData(event.x, event.y, event.z, now.millisecondsSinceEpoch);

        if (now.difference(_lastProcessTime) > _processInterval) {
          _lastProcessTime = now;
          final rpm = _processor.estimateCadence();

          if (rpm != null && rpm > 0) {
            metricProcessingFunction(_createRecord(rpm));
          }
        }
      });
    } on Exception catch (e, stack) {
      // Handle sensor error or permission issues silently or log
      Logging().logException(
        logLevelError,
        logTag,
        "_startListening",
        "accelerometerEventStream.listen",
        e,
        stack,
      );
    }
  }

  RecordWithSport _createRecord(double rpm) {
    final int val = rpm.round();

    return RecordWithSport(
      timeStamp: DateTime.now(),
      sport: targetSport,
      cadence: val,
      preciseCadence: rpm,
    );
  }

  @override
  Future<void> detach() async {
    await _sensorSubscription?.cancel();
    _sensorSubscription = null;
    attached = false;
  }

  @override
  Future<void> disconnect() async {
    await detach();
    connected = false;
    discovered = false;
  }

  // Abstract implementations required by ComplexSensor/SensorBase
  @override
  bool canMeasurementProcessed(List<int> data) {
    return false; // Not used
  }

  @override
  void processFlag(int flag) {
    // Not used
  }

  @override
  RecordWithSport processMeasurement(List<int> data) {
    // Not used, as pumpData is overridden
    return RecordWithSport(sport: targetSport);
  }

  @override
  Future<int> readBatteryLevel() async {
    return 100; // Fake battery
  }
}
