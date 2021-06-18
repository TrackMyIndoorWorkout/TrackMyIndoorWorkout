import 'dart:async';

import 'package:rxdart/rxdart.dart';
import '../../persistence/models/record.dart';
import 'device_base.dart';

typedef ComplexMetricProcessingFunction = Function(RecordWithSport record);

abstract class ComplexSensor extends DeviceBase {
  int featureFlag = 0;
  RecordWithSport? record;

  ComplexSensor(
    serviceId,
    characteristicsId,
    device,
  ) : super(
          serviceId: serviceId,
          characteristicsId: characteristicsId,
          device: device,
        );

  Stream<RecordWithSport> get _listenToMetric async* {
    if (!attached || characteristic == null) return;

    await for (var byteString in characteristic!.value.throttleTime(Duration(milliseconds: 950))) {
      if (!canMeasurementProcessed(byteString)) continue;

      record = processMeasurement(byteString);
      yield record!;
    }
  }

  void pumpMetric(ComplexMetricProcessingFunction metricProcessingFunction) {
    subscription = _listenToMetric.listen((newValue) {
      record = newValue;
      metricProcessingFunction(newValue);
    });
  }

  bool canMeasurementProcessed(List<int> data);

  RecordWithSport processMeasurement(List<int> data);

  void clearMetrics();
}
