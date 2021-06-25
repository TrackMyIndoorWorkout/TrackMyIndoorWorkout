import 'dart:collection';

import '../../utils/constants.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../gatt_constants.dart';
import 'cadence_data.dart';
import 'integer_sensor.dart';

class CyclingCadenceSensor extends IntegerSensor {
  static const int REVOLUTION_SLIDING_WINDOW = 10; // Seconds
  static const int EVENT_TIME_OVERFLOW = 64; // Overflows every 64 seconds

  // Secondary (Crank cadence) metrics
  ShortMetricDescriptor? revolutionsMetric;
  ShortMetricDescriptor? revolutionTime;
  ListQueue<CadenceData> cadenceData = ListQueue<CadenceData>();

  CyclingCadenceSensor(device)
      : super(
          CYCLING_CADENCE_SERVICE_ID,
          CYCLING_CADENCE_MEASUREMENT_ID,
          device,
        );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.csc_measurement.xml
  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.length < 1) return false;

    var flag = data[0];
    // 16 bit revolution and 16 bit time
    if (featureFlag != flag && flag > 0) {
      expectedLength = 1; // The flag itself
      // Has wheel revolution? (first bit)
      if (flag % 2 == 1) {
        // Skip it, we are not interested in wheel revolution
        expectedLength += 6; // 32 bit revolution and 16 bit time
      }

      flag ~/= 2;
      // Has crank revolution? (second bit)
      if (flag % 2 == 1) {
        revolutionsMetric = ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1);
        expectedLength += 2; // 16 bit revolution
        revolutionTime = ShortMetricDescriptor(
            lsb: expectedLength + 2, msb: expectedLength + 3, divider: 1024.0);
        expectedLength += 2; // 16 bit time
      }

      featureFlag = flag;

      return data.length == expectedLength;
    }

    return featureFlag >= 0 && data.length == expectedLength;
  }

  @override
  int processMeasurement(List<int> data) {
    if (!canMeasurementProcessed(data)) return 0;

    cadenceData.add(CadenceData(
      seconds: getRevolutionTime(data) ?? 0.0,
      revolutions: getRevolutions(data) ?? 0,
    ));

    var firstData = cadenceData.first;
    if (cadenceData.length == 1) {
      return firstData.revolutions ~/ firstData.seconds;
    }

    var lastData = cadenceData.last;
    var revDiff = lastData.revolutions - firstData.revolutions;
    // Check overflow
    if (revDiff < 0) {
      revDiff += MAX_UINT16;
    }
    var secondsDiff = lastData.seconds - firstData.seconds;
    // Check overflow
    if (secondsDiff < 0) {
      secondsDiff += EVENT_TIME_OVERFLOW;
    }

    while (secondsDiff > REVOLUTION_SLIDING_WINDOW && cadenceData.length > 2) {
      cadenceData.removeFirst();
      secondsDiff = cadenceData.last.seconds - cadenceData.first.seconds;
      // Check overflow
      if (secondsDiff < 0) {
        secondsDiff += EVENT_TIME_OVERFLOW;
      }
    }

    metric = revDiff ~/ secondsDiff;
    return metric;
  }

  int? getRevolutions(List<int> data) {
    return revolutionsMetric?.getMeasurementValue(data)?.toInt();
  }

  double? getRevolutionTime(List<int> data) {
    return revolutionTime?.getMeasurementValue(data);
  }

  @override
  void clearMetrics() {
    revolutionsMetric = null;
    revolutionTime = null;
  }
}
