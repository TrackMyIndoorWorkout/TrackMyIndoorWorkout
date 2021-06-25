import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../persistence/database.dart';
import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import '../../track/tracks.dart';
import '../../utils/constants.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import '../gatt_constants.dart';

abstract class DeviceDescriptor {
  static const double MS2KMH = 3.6;
  static const double KMH2MS = 1 / MS2KMH;

  String defaultSport;
  final bool isMultiSport;
  final String fourCC;
  final String vendorName;
  final String modelName;
  final String namePrefix;
  final String manufacturer;
  final int manufacturerFitId;
  final String model;
  String? dataServiceId;
  String? dataCharacteristicId;
  final bool antPlus;

  int featuresFlag = -1;
  int byteCounter = 0;

  bool canMeasureHeartRate;
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

  // Adjusting skewed calories
  double calorieFactorDefault;
  double calorieFactor = 1.0;
  // Adjusting skewed distance
  double powerFactor = 1.0;
  bool extendTuning = EXTEND_TUNING_DEFAULT;
  double? slowPace;

  DeviceDescriptor({
    required this.defaultSport,
    required this.isMultiSport,
    required this.fourCC,
    required this.vendorName,
    required this.modelName,
    required this.namePrefix,
    required this.manufacturer, // TODO
    required this.manufacturerFitId, // TODO
    required this.model, // TODO
    this.dataServiceId,
    this.dataCharacteristicId,
    this.antPlus = false,
    this.canMeasureHeartRate = true,
    this.heartRateByteIndex,
    this.timeMetric,
    this.caloriesMetric,
    this.speedMetric,
    this.powerMetric,
    this.cadenceMetric,
    this.distanceMetric,
    this.calorieFactorDefault = 1.0,
  }) {
    calorieFactor = calorieFactorDefault;
  }

  String get fullName => '$vendorName $modelName';
  double get lengthFactor => getDefaultTrack(defaultSport).lengthFactor;
  bool get isFitnessMachine => dataServiceId == FITNESS_MACHINE_ID;

  Future<void> stopWorkout();

  bool canDataProcessed(List<int> data);

  void processFlag(int flag) {
    clearMetrics();
    byteCounter = 2;
  }

  RecordWithSport? stubRecord(List<int> data) {
    if (data.length > 2) {
      var flag = data[0] + MAX_UINT8 * data[1];
      if (flag != featuresFlag) {
        featuresFlag = flag;
        processFlag(flag);
      }
    }

    return null;
  }

  refreshTuning(String deviceId) async {
    final database = Get.find<AppDatabase>();
    calorieFactor = await database.calorieFactor(deviceId, this);
    powerFactor = await database.powerFactor(deviceId);
    final prefService = Get.find<BasePrefService>();
    extendTuning = prefService.get<bool>(EXTEND_TUNING_TAG) ?? EXTEND_TUNING_DEFAULT;
  }

  double? getSpeed(List<int> data) {
    var speed = speedMetric?.getMeasurementValue(data);
    if (speed == null || !extendTuning) {
      return speed;
    }

    return speed * powerFactor;
  }

  double? getCadence(List<int> data) {
    return cadenceMetric?.getMeasurementValue(data);
  }

  double? getDistance(List<int> data) {
    var distance = distanceMetric?.getMeasurementValue(data);
    if (distance == null || !extendTuning) {
      return distance;
    }

    return distance * powerFactor;
  }

  double? getPower(List<int> data) {
    var power = powerMetric?.getMeasurementValue(data);
    if (power == null) {
      return power;
    }

    return power * powerFactor;
  }

  double? getCalories(List<int> data) {
    var calories = caloriesMetric?.getMeasurementValue(data);
    if (calories == null || !extendTuning) {
      return calories;
    }

    return calories * calorieFactor;
  }

  double? getCaloriesPerHour(List<int> data) {
    var caloriesPerHour = caloriesPerHourMetric?.getMeasurementValue(data);
    if (caloriesPerHour == null || !extendTuning) {
      return caloriesPerHour;
    }

    return caloriesPerHour * calorieFactor;
  }

  double? getCaloriesPerMinute(List<int> data) {
    var caloriesPerMinute = caloriesPerMinuteMetric?.getMeasurementValue(data);
    if (caloriesPerMinute == null || !extendTuning) {
      return caloriesPerMinute;
    }

    return caloriesPerMinute * calorieFactor;
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
