import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'device_base.dart';

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
    if (!attached) return;
    await for (var byteString in characteristic.value) {
      if (!canMeasurementProcessed(byteString)) continue;

      metric = processMeasurement(byteString);
      yield metric;
    }
  }

  Stream<int> get throttledMetric {
    return _listenToMetric.throttleTime(Duration(milliseconds: 500));
  }

  bool canMeasurementProcessed(List<int> data);

  int processMeasurement(List<int> data);

  clearMetrics();
}
