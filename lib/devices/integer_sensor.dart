import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'device_base.dart';

typedef MetricProcessingFunction = Function(int heartRate);

abstract class IntegerSensor extends DeviceBase {
  int featureFlag;
  int metric;

  IntegerSensor(
    serviceId,
    characteristicsId,
    device,
  ) : super(
          serviceId: serviceId,
          characteristicsId: characteristicsId,
          device: device,
        ) {
    featureFlag = 0;
    metric = 0;
  }

  Stream<int> get _listenToMetric async* {
    if (!attached) return;
    await for (var byteString in characteristic.value) {
      if (!canMeasurementProcessed(byteString)) continue;

      metric = processMeasurement(byteString);
      yield metric;
    }
  }

  StreamSubscription pumpMetric(MetricProcessingFunction metricProcessingFunction) {
    if (broadcastStream == null) {
      broadcastStream =
          _listenToMetric.throttleTime(Duration(milliseconds: 500)).asBroadcastStream();
    }
    final subscription = broadcastStream.listen((newValue) {
      metric = newValue;
      if (metricProcessingFunction != null) {
        metricProcessingFunction(newValue);
      }
    });
    addSubscription(subscription);
    return subscription;
  }

  bool canMeasurementProcessed(List<int> data);

  int processMeasurement(List<int> data);

  clearMetrics();
}
