import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../devices/cadence_sensor.dart';
import '../devices/gatt_constants.dart';
import '../devices/heart_rate_monitor.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/preferences.dart';
import '../tcx/activity_type.dart';
import '../track/tracks.dart';
import 'byte_metric_descriptor.dart';
import 'short_metric_descriptor.dart';
import 'three_byte_metric_descriptor.dart';

abstract class DeviceDescriptor {
  static const double MS2KMH = 3.6;
  static const double KMH2MS = 1 / MS2KMH;
  static const double J2CAL = 0.2390057;
  static const double J2KCAL = J2CAL / 1000.0;

  final String sport;
  final String fourCC;
  final String vendorName;
  final String modelName;
  var fullName;
  final String namePrefix;
  final String manufacturer;
  final String model;
  final String primaryServiceId;
  final String primaryMeasurementId;

  bool canMeasureHeartRate;
  int heartRateByteIndex;

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

  // Special Metrics
  ByteMetricDescriptor strokeRateMetric;
  ShortMetricDescriptor strokeCountMetric;
  ShortMetricDescriptor paceMetric;
  ShortMetricDescriptor caloriesPerHourMetric;
  ByteMetricDescriptor caloriesPerMinuteMetric;

  double throttlePower;
  bool throttleOther;

  DeviceDescriptor({
    @required this.sport,
    @required this.fourCC,
    @required this.vendorName,
    @required this.modelName,
    this.fullName = '',
    @required this.namePrefix,
    this.manufacturer,
    this.model,
    this.primaryServiceId,
    this.primaryMeasurementId,
    this.canMeasureHeartRate = true,
    this.heartRateByteIndex,
    this.timeMetric,
    this.caloriesMetric,
    this.speedMetric,
    this.powerMetric,
    this.cadenceMetric,
    this.distanceMetric,
    this.calorieFactor = 1.0,
    this.distanceFactor = 1.0,
  })  : assert(sport != null),
        assert(fourCC != null),
        assert(vendorName != null),
        assert(modelName != null),
        assert(fullName != null),
        assert(namePrefix != null) {
    this.fullName = '$vendorName $modelName';
    throttlePower = 1.0;
    throttleOther = THROTTLE_OTHER_DEFAULT;
  }

  double get lengthFactor => getDefaultTrack(sport).lengthFactor;
  bool get isFitnessMachine => primaryServiceId == FITNESS_MACHINE_ID;

  restartWorkout();

  bool canDataProcessed(List<int> data);

  Record processData(
    Activity activity,
    Duration idleDuration,
    Record lastRecord,
    List<int> data,
    HeartRateMonitor hrm,
    CadenceSensor cadenceSensor,
  );

  String get tcxSport => sport == ActivityType.Ride && sport == ActivityType.Run ? sport : "Other";

  String getSpeedUnit(bool si) {
    if (sport == ActivityType.Ride) {
      return si ? 'kmh' : 'mph';
    } else if (sport == ActivityType.Run) {
      return si ? 'min /km' : 'min /mi';
    } else if (sport == ActivityType.Kayaking ||
        sport == ActivityType.Canoeing ||
        sport == ActivityType.Rowing) {
      return 'min /500';
    }
    return si ? 'kmh' : 'mph';
  }

  String get speedTitle => sport == ActivityType.Ride ? "Speed" : "Pace";

  IconData getIcon() {
    if (sport == ActivityType.Ride) {
      return Icons.directions_bike;
    } else if (sport == ActivityType.Run) {
      return Icons.directions_run;
    } else if (sport == ActivityType.Kayaking ||
        sport == ActivityType.Canoeing ||
        sport == ActivityType.Rowing) {
      return Icons.rowing;
    }
    return Icons.directions_bike;
  }

  String getCadenceUnit() {
    if (sport == ActivityType.Kayaking ||
        sport == ActivityType.Canoeing ||
        sport == ActivityType.Rowing) {
      return "spm";
    }
    return "rpm";
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

  double getCaloriesPerHour(List<int> data) {
    var caloriesPerHour = caloriesPerHourMetric?.getMeasurementValue(data);
    if (caloriesPerHour == null || !throttleOther) {
      return caloriesPerHour;
    }
    return caloriesPerHour * throttlePower;
  }

  double getCaloriesPerMinute(List<int> data) {
    var caloriesPerMinute = caloriesPerMinuteMetric?.getMeasurementValue(data);
    if (caloriesPerMinute == null || !throttleOther) {
      return caloriesPerMinute;
    }
    return caloriesPerMinute * throttlePower;
  }

  double getTime(List<int> data) {
    return timeMetric?.getMeasurementValue(data);
  }

  int getStrokeRate(List<int> data) {
    return strokeRateMetric?.getMeasurementValue(data)?.toInt();
  }

  double getPace(List<int> data) {
    return paceMetric?.getMeasurementValue(data);
  }

  double getHeartRate(List<int> data) {
    if (heartRateByteIndex == null) return 0;
    return data[heartRateByteIndex].toDouble();
  }

  clearMetrics() {
    speedMetric = null;
    cadenceMetric = null;
    distanceMetric = null;
    powerMetric = null;
    caloriesMetric = null;
    timeMetric = null;
    strokeRateMetric = null;
    paceMetric = null;
    caloriesPerHourMetric = null;
    caloriesPerMinuteMetric = null;
  }
}
