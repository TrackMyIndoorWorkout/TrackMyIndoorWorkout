import 'dart:async';

import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:rxdart/rxdart.dart';

import '../../persistence/record.dart';
import '../../preferences/sensor_data_threshold.dart';
import '../../utils/constants.dart';
import 'sensor_base.dart';

typedef ComplexMetricProcessingFunction = Function(RecordWithSport record);

abstract class ComplexSensor extends SensorBase {
  late RecordWithSport record;
  late final int sensorDataThreshold;

  ComplexSensor(super.serviceId, super.characteristicId, super.device) {
    record = RecordWithSport(sport: ActivityType.workout);
    final prefService = Get.find<BasePrefService>();
    sensorDataThreshold =
        prefService.get<int>(sensorDataThresholdTag) ?? sensorDataThresholdDefault;
  }

  Stream<RecordWithSport> get _listenToData async* {
    if (!attached || characteristic == null) return;

    await for (var byteList in characteristic!.lastValueStream.throttleTime(
      Duration(milliseconds: sensorDataThreshold),
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
