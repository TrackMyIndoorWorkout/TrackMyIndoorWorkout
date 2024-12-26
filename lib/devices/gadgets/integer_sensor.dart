import 'dart:async';

import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:rxdart/rxdart.dart';

import '../../preferences/sensor_data_threshold.dart';
import 'sensor_base.dart';

typedef IntegerMetricProcessingFunction = Function(int measurement);

abstract class IntegerSensor extends SensorBase {
  int metric = 0;
  late final int sensorDataThreshold;

  IntegerSensor(super.serviceId, super.characteristicId, super.device) {
    final prefService = Get.find<BasePrefService>();
    sensorDataThreshold =
        prefService.get<int>(sensorDataThresholdTag) ?? sensorDataThresholdDefault;
  }

  Stream<int> get _listenToData async* {
    if (!attached || characteristic == null) return;

    await for (var byteList in characteristic!.lastValueStream.throttleTime(
      Duration(milliseconds: sensorDataThreshold),
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
