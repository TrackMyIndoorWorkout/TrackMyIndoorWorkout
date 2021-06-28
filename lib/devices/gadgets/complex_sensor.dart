import 'dart:async';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import 'sensor_base.dart';

typedef ComplexMetricProcessingFunction = Function(RecordWithSport record);

abstract class ComplexSensor extends SensorBase {
  late double powerFactor;
  late bool extendTuning;
  late Random random;
  RecordWithSport? record;

  ComplexSensor(serviceId, characteristicsId, device)
      : super(serviceId, characteristicsId, device) {
    random = Random();
    extendTuning = prefService.get<bool>(EXTEND_TUNING_TAG) ?? EXTEND_TUNING_DEFAULT;
  }

  Stream<RecordWithSport> get _listenToData async* {
    if (!attached || characteristic == null) return;

    await for (var byteString in characteristic!.value.throttleTime(Duration(milliseconds: 950))) {
      if (!canMeasurementProcessed(byteString)) continue;

      record = processMeasurement(byteString);
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
