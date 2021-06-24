import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'sensor_base.dart';

typedef IntegerMetricProcessingFunction = Function(int measurement);

abstract class IntegerSensor extends SensorBase {
  int metric = 0;

  IntegerSensor(serviceId, characteristicsId, device) : super(serviceId, characteristicsId, device);

  Stream<int> get _listenToMetric async* {
    if (!attached || characteristic == null) return;

    await for (var byteString in characteristic!.value.throttleTime(Duration(milliseconds: 950))) {
      if (!canMeasurementProcessed(byteString)) continue;

      metric = processMeasurement(byteString);
      yield metric;
    }
  }

  void pumpData(IntegerMetricProcessingFunction metricProcessingFunction) {
    subscription = _listenToMetric.listen((newValue) {
      metric = newValue;
      metricProcessingFunction(newValue);
    });
  }

  int processMeasurement(List<int> data);
}
