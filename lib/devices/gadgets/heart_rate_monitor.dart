import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../gatt_constants.dart';
import 'integer_sensor.dart';

class HeartRateMonitor extends IntegerSensor {
  ByteMetricDescriptor? _byteHeartRateMetric;
  ShortMetricDescriptor? _shortHeartRateMetric;

  HeartRateMonitor(device) : super(HEART_RATE_SERVICE_ID, HEART_RATE_MEASUREMENT_ID, device);

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.heart_rate_measurement.xml
  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.length < 1) return false;

    var flag = data[0];
    if (featureFlag != flag) {
      expectedLength = 1; // The flag
      // Heart rate value format (first bit)
      if (flag % 2 == 0) {
        _byteHeartRateMetric = ByteMetricDescriptor(lsb: expectedLength);
        expectedLength += 1; // 8 bit HR
      } else {
        _shortHeartRateMetric = ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1);
        expectedLength += 2; // 16 bit HR
      }
      flag ~/= 2;
      // Sensor Contact Status Bit Pair
      flag ~/= 4;
      // Energy Expended Status
      if (flag % 2 == 1) {
        expectedLength += 2; // 16 bit, kJ
      }
      flag ~/= 2;
      // RR Interval bit
      if (flag % 2 == 1) {
        expectedLength += 2; // 1/1024 sec
      }
      featureFlag = flag;
    }

    return featureFlag >= 0 && data.length == expectedLength;
  }

  @override
  int processMeasurement(List<int> data) {
    if (canMeasurementProcessed(data)) {
      if (_byteHeartRateMetric != null) {
        final heartRate = _byteHeartRateMetric!.getMeasurementValue(data)?.toInt();
        if (heartRate != null && heartRate > 0) {
          metric = heartRate;
        }
      } else if (_shortHeartRateMetric != null) {
        final heartRate = _shortHeartRateMetric!.getMeasurementValue(data)?.toInt();
        if (heartRate != null && heartRate > 0) {
          metric = heartRate;
        }
      }
    }

    return metric;
  }

  @override
  void clearMetrics() {}
}
