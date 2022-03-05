import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';

abstract class DataHandler {
  final int flagByteSize;
  int featuresFlag = -1;
  int byteCounter = 0;

  int? heartRateByteIndex;

  // Common metrics
  ShortMetricDescriptor? speedMetric;
  ShortMetricDescriptor? cadenceMetric;
  ThreeByteMetricDescriptor? distanceMetric;
  ShortMetricDescriptor? powerMetric;
  ShortMetricDescriptor? caloriesMetric;
  ShortMetricDescriptor? timeMetric;
  ShortMetricDescriptor? caloriesPerHourMetric;
  ByteMetricDescriptor? caloriesPerMinuteMetric;

  DataHandler({
    this.flagByteSize = 2,
    this.heartRateByteIndex,
    this.timeMetric,
    this.caloriesMetric,
    this.speedMetric,
    this.powerMetric,
    this.cadenceMetric,
    this.distanceMetric,
  });

  DataHandler clone();

  bool isDataProcessable(List<int> data);

  void initFlag() {
    clearMetrics();
    featuresFlag = -1;
    byteCounter = flagByteSize;
  }

  void processFlag(int flag) {
    initFlag();
  }

  void preProcessFlag(List<int> data) {
    if (data.length > flagByteSize) {
      var flag = data[0] + maxUint8 * data[1];
      if (flag != featuresFlag) {
        featuresFlag = flag;
        processFlag(flag);
      }
    }
  }

  RecordWithSport? stubRecord(List<int> data) {
    preProcessFlag(data);

    return null;
  }

  double? getSpeed(List<int> data) {
    return speedMetric?.getMeasurementValue(data);
  }

  double? getCadence(List<int> data) {
    return cadenceMetric?.getMeasurementValue(data);
  }

  double? getDistance(List<int> data) {
    return distanceMetric?.getMeasurementValue(data);
  }

  double? getPower(List<int> data) {
    return powerMetric?.getMeasurementValue(data);
  }

  double? getCalories(List<int> data) {
    return caloriesMetric?.getMeasurementValue(data);
  }

  double? getCaloriesPerHour(List<int> data) {
    return caloriesPerHourMetric?.getMeasurementValue(data);
  }

  double? getCaloriesPerMinute(List<int> data) {
    return caloriesPerMinuteMetric?.getMeasurementValue(data);
  }

  double? getTime(List<int> data) {
    return timeMetric?.getMeasurementValue(data);
  }

  double? getHeartRate(List<int> data) {
    if (heartRateByteIndex == null) return 0;

    return data[heartRateByteIndex!].toDouble();
  }

  void clearMetrics() {
    speedMetric = null;
    cadenceMetric = null;
    distanceMetric = null;
    powerMetric = null;
    caloriesMetric = null;
    timeMetric = null;
    caloriesPerHourMetric = null;
    caloriesPerMinuteMetric = null;
  }
}
