import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../gatt_constants.dart';
import 'complex_sensor.dart';

class HeartRateMonitor extends ComplexSensor {
  ByteMetricDescriptor? _byteHeartRateMetric;
  ShortMetricDescriptor? _shortHeartRateMetric;
  ShortMetricDescriptor? _caloriesMetric;

  HeartRateMonitor(device) : super(heartRateServiceUuid, heartRateMeasurementUuid, device);

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.heart_rate_measurement.xml
  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.isEmpty) return false;

    var flag = data[0];
    // Clear out status bits so status change won't cause metric re-creation
    flag &= 25; // 1 + 8 + 16 = 2^5 - 6
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
        _caloriesMetric =
            ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1, divider: CAL_TO_J);
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
  RecordWithSport processMeasurement(List<int> data) {
    if (!canMeasurementProcessed(data)) {
      return RecordWithSport.getBlank(ActivityType.Run, uxDebug, random);
    }

    return RecordWithSport(
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      heartRate: getHeartRate(data),
      calories: getCalories(data),
      sport: ActivityType.Run,
    );
  }

  int? getHeartRate(List<int> data) {
    if (_byteHeartRateMetric != null) {
      return _byteHeartRateMetric!.getMeasurementValue(data)?.toInt();
    } else if (_shortHeartRateMetric != null) {
      return _shortHeartRateMetric!.getMeasurementValue(data)?.toInt();
    }

    return null;
  }

  double? getCalories(List<int> data) {
    var calories = _caloriesMetric?.getMeasurementValue(data);
    if (calories == null || !extendTuning) {
      return calories;
    }

    return calories * calorieFactor;
  }

  @override
  void clearMetrics() {}
}
