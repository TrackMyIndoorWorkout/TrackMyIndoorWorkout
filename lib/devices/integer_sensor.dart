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
    if (!attached || characteristic == null) return;

    await for (var byteString in characteristic.value.throttleTime(Duration(milliseconds: 500))) {
      if (!canMeasurementProcessed(byteString)) continue;

      metric = processMeasurement(byteString);
      yield metric;
    }
  }

  pumpMetric(MetricProcessingFunction metricProcessingFunction) {
    subscription = _listenToMetric.listen((newValue) {
      metric = newValue;
      if (metricProcessingFunction != null) {
        metricProcessingFunction(newValue);
      }
    });
  }

  bool canMeasurementProcessed(List<int> data);

  int processMeasurement(List<int> data);

  clearMetrics();
}
