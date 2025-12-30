import 'dart:async';

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:heart_rate_flutter/heart_rate_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../persistence/record.dart';
import '../../utils/constants.dart';
import 'complex_sensor.dart';
import 'heart_rate_monitor.dart';

class PermissionHandlerWrapper {
  Future<bool> requestSensors() async {
    return await Permission.sensors.request().isGranted;
  }
}

class DeviceInternalHeartRate extends HeartRateMonitor {
  StreamSubscription<double>? _hrSubscription;
  final HeartRateFlutter _heartRateFlutter;
  final PermissionHandlerWrapper _permissionHandler;

  final String sport;

  DeviceInternalHeartRate({
    HeartRateFlutter? heartRateFlutter,
    PermissionHandlerWrapper? permissionHandler,
    this.sport = ActivityType.workout,
  }) : _heartRateFlutter = heartRateFlutter ?? HeartRateFlutter(),
       _permissionHandler = permissionHandler ?? PermissionHandlerWrapper(),
       super(BluetoothDevice(remoteId: const DeviceIdentifier("INTERNAL_HRM")));

  static Future<bool> hasHeartRateSensor() async {
    if (!Platform.isAndroid) return false;
    // We create an instance here just for checking, or use a static helper if available.
    // DeviceInfoPlugin is designed to be instantiated.
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.systemFeatures.contains('android.hardware.sensor.heartrate');
  }

  @override
  Future<bool> connect() async {
    connecting = true;
    try {
      await _heartRateFlutter.init();
    } catch (e) {
      // init might fail if sensor not available
    }
    connecting = false;
    connected = true;
    return true;
  }

  @override
  Future<bool> discover() async {
    discovering = true;
    discovered = true;
    discovering = false;
    return true;
  }

  @override
  Future<void> attach() async {
    if (attached) return;

    if (await _permissionHandler.requestSensors()) {
      try {
        // Just verify we can listen?
        // We generally don't start listening until pumpData is called for metrics.
        // But parent implementation might expect attached=true.
        attached = true;
      } catch (e) {
        attached = false;
      }
    }
  }

  @override
  void pumpData(ComplexMetricProcessingFunction? metricProcessingFunction) {
    if (metricProcessingFunction == null) return;

    if (!attached) {
      attach().then((_) {
        if (attached) {
          _subscribe(metricProcessingFunction);
        }
      });
    } else {
      _subscribe(metricProcessingFunction);
    }
  }

  void _subscribe(ComplexMetricProcessingFunction metricProcessingFunction) {
    _hrSubscription?.cancel();
    _hrSubscription = _heartRateFlutter.heartBeatStream.listen((hr) {
      final record = RecordWithSport(
        timeStamp: DateTime.now(),
        heartRate: hr.toInt(),
        sport: sport,
      );
      metricProcessingFunction(record);
    });
  }

  @override
  Future<void> detach() async {
    _hrSubscription?.cancel();
    _hrSubscription = null;
    attached = false;
  }

  @override
  Future<void> disconnect() async {
    await detach();
    connected = false;
  }
}
