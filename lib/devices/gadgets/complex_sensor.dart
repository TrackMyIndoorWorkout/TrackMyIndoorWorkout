import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../persistence/record.dart';
import '../../utils/constants.dart';
import '../../utils/delays.dart';
import 'sensor_base.dart';

typedef ComplexMetricProcessingFunction = Function(RecordWithSport record);

abstract class ComplexSensor extends SensorBase {
  late RecordWithSport record;

  ComplexSensor(super.serviceId, super.characteristicId, super.device) {
    record = RecordWithSport(sport: ActivityType.workout);
  }

  Stream<RecordWithSport> get _listenToData async* {
    if (!attached || characteristic == null) return;

    await for (var byteList in characteristic!.lastValueStream.throttleTime(
      const Duration(milliseconds: sensorDataThreshold),
      leading: false,
      trailing: true,
    )) {
      logData(byteList, "ComplexSensor");
      if (!canMeasurementProcessed(byteList)) continue;

      record = processMeasurement(byteList);
      yield record;
    }
  }

  void pumpData(ComplexMetricProcessingFunction? metricProcessingFunction) {
    subscription = _listenToData.listen((newValue) {
      if (metricProcessingFunction != null) {
        metricProcessingFunction(newValue);
      }
    });
  }

  RecordWithSport processMeasurement(List<int> data);

  void trimQueues() {}
}
