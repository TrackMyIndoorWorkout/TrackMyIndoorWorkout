import '../../persistence/models/record.dart';
import '../../track/tracks.dart';
import '../gatt_constants.dart';
import 'data_handler.dart';

abstract class DeviceDescriptor extends DataHandler {
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

  bool canMeasureHeartRate;
  bool canMeasureCalories;

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
    this.canMeasureHeartRate = true,
    this.canMeasureCalories = true,
    hasFeatureFlags = true,
    flagByteSize = 2,
    heartRateByteIndex,
    timeMetric,
    caloriesMetric,
    speedMetric,
    powerMetric,
    cadenceMetric,
    distanceMetric,
  }) : super(
          hasFeatureFlags: hasFeatureFlags,
          flagByteSize: flagByteSize,
          heartRateByteIndex: heartRateByteIndex,
          timeMetric: timeMetric,
          caloriesMetric: caloriesMetric,
          speedMetric: speedMetric,
          powerMetric: powerMetric,
          cadenceMetric: cadenceMetric,
          distanceMetric: distanceMetric,
        );

  String get fullName => '$vendorName $modelName';
  double get lengthFactor => getDefaultTrack(defaultSport).lengthFactor;
  bool get isFitnessMachine => dataServiceId == fitnessMachineUuid;

  void stopWorkout();

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
}
