import 'package:flutter_blue/flutter_blue.dart';
import 'byte_metric_descriptor.dart';
import 'short_metric_descriptor.dart';

class HeartRateMonitor {
  final BluetoothDevice device;
  String heartRateServiceId;
  String heartRateMeasurementId;
  int heartRateFlag;
  int heartRate;
  ByteMetricDescriptor byteHeartRateMetric;
  ShortMetricDescriptor shortHeartRateMetric;

  HeartRateMonitor({
    this.device,
  }) : assert(device != null);

  bool canHeartRateMeasurementProcessed(List<int> data) {
    if (data == null || data.length < 1) return false;

    var flag = data[0];
    // 16 bit revolution and 16 bit time
    if (heartRateFlag != flag && flag > 0) {
      var expectedLength = 1; // The flag
      // Has wheel revolution? (first bit)
      if (flag % 2 == 0) {
        byteHeartRateMetric = ByteMetricDescriptor(lsb: expectedLength);
        expectedLength += 1; // 8 bit HR
      } else {
        shortHeartRateMetric = ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1);
        expectedLength += 2; // 16 bit HR
      }
      flag ~/= 2;
      // Sensor Contact Status Bit
      flag ~/= 2;
      // Energy Expanded Status
      if (flag % 2 == 1) {
        expectedLength += 2; // 16 bit, kJ
      }
      flag ~/= 2;
      // RR Interval bit
      if (flag % 2 == 1) {
        expectedLength += 2; // 1/1024 sec
      }
      heartRateFlag = flag;

      return data.length == expectedLength;
    }

    return flag > 0;
  }

  int processHeartRateMeasurement(List<int> data) {
    if (!canHeartRateMeasurementProcessed(data)) return 0;

    if (byteHeartRateMetric != null) {
      return byteHeartRateMetric?.getMeasurementValue(data)?.toInt();
    }
    if (shortHeartRateMetric != null) {
      return shortHeartRateMetric?.getMeasurementValue(data)?.toInt();
    }

    return null;
  }
}
