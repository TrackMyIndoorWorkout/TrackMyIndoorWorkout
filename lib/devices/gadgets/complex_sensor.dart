import 'dart:async';

import 'package:rxdart/rxdart.dart';
import '../../persistence/models/record.dart';
import '../../utils/delays.dart';
import 'sensor_base.dart';

typedef ComplexMetricProcessingFunction = Function(RecordWithSport record);

abstract class ComplexSensor extends SensorBase {
  RecordWithSport? record;

  ComplexSensor(serviceId, characteristicId, device) : super(serviceId, characteristicId, device);

  Stream<RecordWithSport> get _listenToData async* {
    if (!attached || characteristic == null) return;

    await for (var byteList in characteristic!.value.throttleTime(
      const Duration(milliseconds: sensorDataThreshold),
      leading: false,
      trailing: true,
    )) {
      logData(byteList, "ComplexSensor");
      if (!canMeasurementProcessed(byteList)) continue;

      record = processMeasurement(byteList);
      yield record!;
    }
  }

  void pumpData(ComplexMetricProcessingFunction? metricProcessingFunction) {
    subscription = _listenToData.listen((newValue) {
      record = newValue;
      if (metricProcessingFunction != null) {
        metricProcessingFunction(newValue);
      }
    });
  }

  RecordWithSport processMeasurement(List<int> data);
}
