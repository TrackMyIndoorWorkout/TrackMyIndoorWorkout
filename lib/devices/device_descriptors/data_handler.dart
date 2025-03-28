import '../../persistence/record.dart';
import '../../utils/constants.dart';
import '../metric_descriptors/metric_descriptor.dart';

abstract class DataHandler {
  final String tag;
  final bool hasFeatureFlags;
  final int flagByteSize;
  int featuresFlag = -1;
  int byteCounter = 0;
  bool hasFutureReservedBytes = false;

  int? heartRateByteIndex;

  bool lastNotMoving = true;

  // Common metrics
  MetricDescriptor? speedMetric;
  MetricDescriptor? cadenceMetric;
  MetricDescriptor? distanceMetric;
  MetricDescriptor? powerMetric;
  MetricDescriptor? caloriesMetric;
  MetricDescriptor? timeMetric;
  MetricDescriptor? caloriesPerHourMetric;
  MetricDescriptor? caloriesPerMinuteMetric;
  MetricDescriptor? resistanceMetric;
  MetricDescriptor? strokeCountMetric;

  DataHandler({
    this.tag = "DATA_HANDLER",
    this.hasFeatureFlags = true,
    this.flagByteSize = 2,
    this.heartRateByteIndex,
    this.timeMetric,
    this.caloriesMetric,
    this.speedMetric,
    this.powerMetric,
    this.cadenceMetric,
    this.distanceMetric,
    this.resistanceMetric,
    this.strokeCountMetric,
  });

  DataHandler clone();

  bool isDataProcessable(List<int> data);

  /// It tells if a gathered packet is the whole packet.
  /// Gets significance for fragmented packet devices.
  bool isWholePacket(List<int> data) {
    return true;
  }

  /// It tells if a gathered packet should be just skipped,
  /// and ignored.
  /// Gets significance for fragmented packet devices,
  /// and such which sometimes incorrectly emit packets
  /// violating gathering of series of smaller packets
  /// comprising larger packets (see isWholePacket above).
  /// Kayak First abides by 20 bytes MTU only.
  bool skipPacket(List<int> data) {
    return false;
  }

  void initFlag() {
    clearMetrics();
    featuresFlag = -1;
    byteCounter = flagByteSize;
  }

  bool isFlagValid(int flag);

  void processFlag(int flag, int dataLength);

  void preProcessFlag(List<int> data) {
    if (data.length > flagByteSize) {
      var flag = data[0];
      if (flagByteSize > 1) {
        flag += maxUint8 * data[1];
      }

      if (flagByteSize > 2) {
        flag += maxUint16 * data[2];
      }

      if (flag != featuresFlag) {
        initFlag();
        featuresFlag = flag;
        processFlag(flag, data.length);
      }
    }
  }

  RecordWithSport? stubRecord(List<int> data);

  RecordWithSport? wrappedStubRecord(List<int> data) {
    if (hasFeatureFlags) {
      preProcessFlag(data);
    }

    final stub = stubRecord(data);
    lastNotMoving = stub?.isNotMoving() ?? true;
    return stub;
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

  double? getResistance(List<int> data) {
    return resistanceMetric?.getMeasurementValue(data);
  }

  double? getStrokeCount(List<int> data) {
    return strokeCountMetric?.getMeasurementValue(data);
  }

  int? getHeartRate(List<int> data) {
    if (heartRateByteIndex == null || heartRateByteIndex! >= data.length) return null;

    return data[heartRateByteIndex!];
  }

  double? getTime(List<int> data) {
    return timeMetric?.getMeasurementValue(data);
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
    resistanceMetric = null;
    strokeCountMetric = null;
  }
}
