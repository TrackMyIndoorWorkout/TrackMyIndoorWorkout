import '../../utils/constants.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../gatt_constants.dart';
import 'cadence_mixin.dart';
import 'integer_sensor.dart';

class CyclingCadenceSensor extends IntegerSensor with CadenceMixin {
  // Secondary (Crank cadence) metrics
  MetricDescriptor? revolutionsMetric;
  MetricDescriptor? revolutionTime;

  CyclingCadenceSensor(device)
      : super(
          cyclingCadenceServiceUuid,
          cyclingCadenceMeasurementUuid,
          device,
        ) {
    initCadence(10, 64, maxUint16);
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.csc_measurement.xml
  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.isEmpty) return false;

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

    addCadenceData(getRevolutionTime(data), getRevolutions(data));

    processData();

    return computeCadence();
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
    clearCadenceData();
  }
}
