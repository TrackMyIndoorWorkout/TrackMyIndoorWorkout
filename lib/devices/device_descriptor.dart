import 'package:preferences/preference_service.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/preferences.dart';
import '../tcx/activity_type.dart';
import 'short_metric_descriptor.dart';
import 'three_byte_metric_descriptor.dart';

typedef MeasurementProcessing(List<int> data);

abstract class DeviceDescriptor {
  static const double MS2KMH = 3.6;
  static const double KMH2MS = 1 / MS2KMH;
  static const int MAX_UINT16 = 65536;
  static const double J2CAL = 0.2390057;
  static const double J2KCAL = J2CAL / 1000.0;

  final bool isBike;
  final String fourCC;
  final String vendorName;
  final String modelName;
  var fullName;
  final String namePrefix;
  final List<int> nameStart;
  final List<int> manufacturer;
  final List<int> model;
  final String primaryMeasurementServiceId;
  final String primaryMeasurementId;
  final MeasurementProcessing canPrimaryMeasurementProcessed;
  String cadenceMeasurementServiceId;
  String cadenceMeasurementId;
  final MeasurementProcessing canCadenceMeasurementProcessed;
  int heartRate;

  // Primary metrics
  ShortMetricDescriptor speedMetric;
  ShortMetricDescriptor cadenceMetric;
  ThreeByteMetricDescriptor distanceMetric;
  ShortMetricDescriptor powerMetric;
  ShortMetricDescriptor caloriesMetric;
  ShortMetricDescriptor timeMetric;
  // Adjusting skewed calories
  double calorieFactor;
  // Adjusting skewed distance
  double distanceFactor;

  // Secondary (Crank cadence) metrics
  ShortMetricDescriptor revolutions;
  ShortMetricDescriptor revolutionTime;

  double throttlePower;
  bool throttleOther;

  DeviceDescriptor({
    this.isBike,
    this.fourCC,
    this.vendorName,
    this.modelName,
    this.fullName = '',
    this.namePrefix,
    this.nameStart,
    this.manufacturer,
    this.model,
    this.primaryMeasurementServiceId,
    this.primaryMeasurementId,
    this.canPrimaryMeasurementProcessed,
    this.cadenceMeasurementServiceId = '',
    this.cadenceMeasurementId = '',
    this.canCadenceMeasurementProcessed,
    this.heartRate,
    this.timeMetric,
    this.caloriesMetric,
    this.speedMetric,
    this.powerMetric,
    this.cadenceMetric,
    this.distanceMetric,
    this.calorieFactor = 1.0,
    this.distanceFactor = 1.0,
  }) {
    this.fullName = '$vendorName $modelName';
    throttlePower = 1.0;
    throttleOther = THROTTLE_OTHER_DEFAULT;
  }

  Record processPrimaryMeasurement(
    Activity activity,
    Duration idleDuration,
    Record lastRecord,
    List<int> data,
  );

  int processCadenceMeasurement(List<int> data);

  String activityType() {
    final isVirtual = PrefService.getBool(VIRTUAL_WORKOUT_TAG);
    if (isVirtual) {
      return isBike ? ActivityType.VirtualRide : ActivityType.VirtualRun;
    }
    return isBike ? ActivityType.Ride : ActivityType.Run;
  }

  setPowerThrottle(String throttlePercentString, bool throttleOther) {
    int throttlePercent = int.tryParse(throttlePercentString);
    throttlePower = (100 - throttlePercent) / 100;
    this.throttleOther = throttleOther;
  }

  double getSpeed(List<int> data) {
    var speed = speedMetric?.getMeasurementValue(data);
    if (speed == null || !throttleOther) {
      return speed;
    }
    return speed * throttlePower;
  }

  double getCadence(List<int> data) {
    return cadenceMetric?.getMeasurementValue(data);
  }

  double getDistance(List<int> data) {
    var distance = distanceMetric?.getMeasurementValue(data);
    if (distance == null || !throttleOther) {
      return distance;
    }
    return distance * throttlePower;
  }

  double getPower(List<int> data) {
    var power = powerMetric?.getMeasurementValue(data);
    if (power == null) {
      return power;
    }
    return power * throttlePower;
  }

  double getCalories(List<int> data) {
    var calories = caloriesMetric?.getMeasurementValue(data);
    if (calories == null || !throttleOther) {
      return calories;
    }
    return calories * throttlePower;
  }

  double getTime(List<int> data) {
    return timeMetric?.getMeasurementValue(data);
  }

  int getRevolutions(List<int> data) {
    return revolutions?.getMeasurementValue(data)?.toInt();
  }

  double getRevolutionTime(List<int> data) {
    return revolutionTime?.getMeasurementValue(data);
  }

  double getHeartRate(List<int> data) {
    return data[heartRate].toDouble();
  }
}
