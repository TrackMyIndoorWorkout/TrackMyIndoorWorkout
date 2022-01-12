import '../../persistence/models/record.dart';
import '../../track/tracks.dart';
import '../../utils/constants.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import '../gatt_constants.dart';

abstract class DeviceDescriptor {
  static const double ms2kmh = 3.6;
  static const double kmh2ms = 1 / ms2kmh;
  static const double oldPowerCalorieFactorDefault = 3.6;
  static const double powerCalorieFactorDefault = 4.0;

  String defaultSport;
  final bool isMultiSport;
  final String fourCC;
  final String vendorName;
  final String modelName;
  final List<String> namePrefixes;
  final String manufacturerPrefix;
  final int manufacturerFitId;
  final String model;
  String? dataServiceId;
  String? dataCharacteristicId;
  final bool antPlus;

  final int flagByteSize;
  int featuresFlag = -1;
  int byteCounter = 0;

  bool canMeasureHeartRate;
  int? heartRateByteIndex;
  bool canMeasureCalories;

  // Common metrics
  ShortMetricDescriptor? speedMetric;
  ShortMetricDescriptor? cadenceMetric;
  ThreeByteMetricDescriptor? distanceMetric;
  ShortMetricDescriptor? powerMetric;
  ShortMetricDescriptor? caloriesMetric;
  ShortMetricDescriptor? timeMetric;
  ShortMetricDescriptor? caloriesPerHourMetric;
  ByteMetricDescriptor? caloriesPerMinuteMetric;

  double? slowPace;

  DeviceDescriptor({
    required this.defaultSport,
    required this.isMultiSport,
    required this.fourCC,
    required this.vendorName,
    required this.modelName,
    required this.namePrefixes,
    required this.manufacturerPrefix,
    required this.manufacturerFitId,
    required this.model, // Maybe eradicate?
    this.dataServiceId,
    this.dataCharacteristicId,
    this.antPlus = false,
    this.flagByteSize = 2,
    this.canMeasureHeartRate = true,
    this.heartRateByteIndex,
    this.canMeasureCalories = true,
    this.timeMetric,
    this.caloriesMetric,
    this.speedMetric,
    this.powerMetric,
    this.cadenceMetric,
    this.distanceMetric,
  });

  String get fullName => '$vendorName $modelName';
  double get lengthFactor => getDefaultTrack(defaultSport).lengthFactor;
  bool get isFitnessMachine => dataServiceId == fitnessMachineUuid;

  void stopWorkout();

  bool canDataProcessed(List<int> data);

  void initFlag() {
    clearMetrics();
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

  RecordWithSport adjustRecord(
    RecordWithSport record,
    double powerFactor,
    double calorieFactor,
    bool extendTuning,
  ) {
    if (record.power != null) {
      record.power = (record.power! * powerFactor).round();
    }

    if (extendTuning) {
      if (record.speed != null) {
        record.speed = record.speed! * powerFactor;
      }

      if (record.distance != null) {
        record.distance = record.distance! * powerFactor;
      }

      if (record.pace != null) {
        record.pace = record.pace! / powerFactor;
      }
    }

    if (record.calories != null) {
      record.calories = (record.calories! * calorieFactor).round();
    }

    if (record.caloriesPerHour != null) {
      record.caloriesPerHour = record.caloriesPerHour! * calorieFactor;
    }

    if (record.caloriesPerMinute != null) {
      record.caloriesPerMinute = record.caloriesPerMinute! * calorieFactor;
    }

    return record;
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
