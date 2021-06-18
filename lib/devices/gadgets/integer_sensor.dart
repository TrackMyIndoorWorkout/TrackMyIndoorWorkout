import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'device_base.dart';

typedef IntegerMetricProcessingFunction = Function(int measurement);

abstract class IntegerSensor extends DeviceBase {
  int featureFlag = -1;
  int expectedLength = 0;
  int metric = 0;

  IntegerSensor(
    serviceId,
    characteristicsId,
    device,
  ) : super(
          serviceId: serviceId,
          characteristicsId: characteristicsId,
          device: device,
        );

  Stream<int> get _listenToMetric async* {
    if (!attached || characteristic == null) return;

    await for (var byteString in characteristic!.value.throttleTime(Duration(milliseconds: 950))) {
      if (!canMeasurementProcessed(byteString)) continue;

      metric = processMeasurement(byteString);
      yield metric;
    }
  }

  void pumpMetric(IntegerMetricProcessingFunction metricProcessingFunction) {
    subscription = _listenToMetric.listen((newValue) {
      metric = newValue;
      metricProcessingFunction(newValue);
    });
  }

  bool canMeasurementProcessed(List<int> data);

  int processMeasurement(List<int> data);

  void clearMetrics();
}
