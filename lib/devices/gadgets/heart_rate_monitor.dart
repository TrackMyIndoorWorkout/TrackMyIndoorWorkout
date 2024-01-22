import '../../persistence/isar/record.dart';
import '../../utils/constants.dart';
import '../gatt/hrm.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'complex_sensor.dart';

class HeartRateMonitor extends ComplexSensor {
  MetricDescriptor? heartRateMetric;
  MetricDescriptor? caloriesMetric;
  bool hasRRIntervals = false;

  HeartRateMonitor(device) : super(heartRateServiceUuid, heartRateMeasurementUuid, device);

  @override
  void processFlag(int flag) {
    if (featureFlag != flag && flag >= 0) {
      clearMetrics();
      featureFlag = flag;
      expectedLength = 1; // The flag
      // Heart rate value format (first bit)
      if (flag % 2 == 0) {
        heartRateMetric = ByteMetricDescriptor(lsb: expectedLength);
        expectedLength++; // 8 bit HR
      } else {
        heartRateMetric = ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1);
        expectedLength += 2; // 16 bit HR
      }

      flag ~/= 2;
      // Sensor Contact Status Bit Pair
      flag ~/= 4;
      // Energy Expended Status
      if (flag % 2 == 1) {
        caloriesMetric =
            ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1, divider: calToJ);
        expectedLength += 2; // 16 bit, kJ
      }

      flag ~/= 2;
      // RR Interval bit
      if (flag % 2 == 1) {
        hasRRIntervals = true;
        expectedLength += 2; // 1/1024 sec
      }

      flag ~/= 2;
    }
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.heart_rate_measurement.xml
  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.isEmpty) return false;

    var flag = data[0];
    // Clear out status bits so status change won't cause metric re-creation
    flag &= 25; // 1 + 8 + 16 = 2^5 - 6
    processFlag(flag);

    return featureFlag >= 0 &&
        (data.length == expectedLength ||
            hasRRIntervals &&
                data.length >= expectedLength &&
                (data.length - expectedLength) % 2 == 0);
  }

  @override
  RecordWithSport processMeasurement(List<int> data) {
    if (!canMeasurementProcessed(data)) {
      return RecordWithSport(sport: ActivityType.workout);
    }

    return RecordWithSport(
      timeStamp: DateTime.now(),
      heartRate: getHeartRate(data),
      calories: getCalories(data)?.toInt(),
      sport: ActivityType.workout,
    );
  }

  int? getHeartRate(List<int> data) {
    return heartRateMetric?.getMeasurementValue(data)?.toInt();
  }

  double? getCalories(List<int> data) {
    return caloriesMetric?.getMeasurementValue(data);
  }

  @override
  void clearMetrics() {
    caloriesMetric = null;
    heartRateMetric = null;
    hasRRIntervals = false;
  }
}
