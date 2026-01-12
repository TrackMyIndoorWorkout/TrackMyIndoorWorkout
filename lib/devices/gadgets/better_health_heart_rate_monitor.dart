import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../persistence/record.dart';
import '../../utils/constants.dart';
import 'complex_sensor.dart';
import 'heart_rate_monitor.dart';

class BetterHealthHeartRateMonitor extends HeartRateMonitor {
  static const MethodChannel _methodChannel = MethodChannel('com.trackmyindoorworkout/bht');
  static const EventChannel _eventChannel = EventChannel('com.trackmyindoorworkout/bht/stream');

  StreamSubscription<dynamic>? _hrSubscription;
  final String sport;

  BetterHealthHeartRateMonitor({this.sport = ActivityType.workout})
    : super(BluetoothDevice(remoteId: const DeviceIdentifier("BHT_HRM")));

  @override
  Future<bool> connect() async {
    connecting = true;
    try {
      await _methodChannel.invokeMethod('start');
    } catch (e) {
      // ignore
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
    attached = true;
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
    _hrSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is int && event > 0) {
        final record = RecordWithSport(timeStamp: DateTime.now(), heartRate: event, sport: sport);
        metricProcessingFunction(record);
      }
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
    try {
      await _methodChannel.invokeMethod('stop');
    } catch (e) {
      // ignore
    }
    connected = false;
  }
}
