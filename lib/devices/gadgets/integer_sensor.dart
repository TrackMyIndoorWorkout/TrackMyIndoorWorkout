import 'dart:async';

import 'package:rxdart/rxdart.dart';
import '../../utils/delays.dart';
import 'sensor_base.dart';

typedef IntegerMetricProcessingFunction = Function(int measurement);

abstract class IntegerSensor extends SensorBase {
  int metric = 0;

  IntegerSensor(serviceId, characteristicId, device) : super(serviceId, characteristicId, device);

  Stream<int> get _listenToData async* {
    if (!attached || characteristic == null) return;

    await for (var byteList in characteristic!.value.throttleTime(
      const Duration(milliseconds: sensorDataThreshold),
      leading: false,
      trailing: true,
    )) {
      logData(byteList, "IntegerSensor");
      if (!canMeasurementProcessed(byteList)) continue;

      metric = processMeasurement(byteList);
      yield metric;
    }
  }

  void pumpData(IntegerMetricProcessingFunction? metricProcessingFunction) {
    subscription = _listenToData.listen((newValue) {
      if (metricProcessingFunction != null) {
        metricProcessingFunction(newValue);
      }
    });
  }

  int processMeasurement(List<int> data);
}
