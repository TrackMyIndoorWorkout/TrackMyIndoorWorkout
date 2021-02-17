import 'package:meta/meta.dart';
import 'package:preferences/preference_service.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/preferences.dart';
import '../tcx/activity_type.dart';
import '../track/tracks.dart';
import 'byte_metric_descriptor.dart';
import 'short_metric_descriptor.dart';
import 'three_byte_metric_descriptor.dart';

typedef MeasurementProcessing(List<int> data);

abstract class DeviceDescriptor {
  static const double MS2KMH = 3.6;
  static const double KMH2MS = 1 / MS2KMH;
  static const int MAX_UINT16 = 65536;
  static const double J2CAL = 0.2390057;
  static const double J2KCAL = J2CAL / 1000.0;

  final String sport;
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
  ShortMetricDescriptor revolutionsMetric;
  ShortMetricDescriptor revolutionTime;

  // Special Metrics
  ByteMetricDescriptor strokeRateMetric;
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

  Record processPrimaryMeasurement(
    Activity activity,
    Duration idleDuration,
    Record lastRecord,
    List<int> data,
  );

  int processCadenceMeasurement(List<int> data);

  String get activityType {
    if (sport != ActivityType.Ride && sport != ActivityType.Run) {
      return sport;
    }
    final isVirtual = PrefService.getBool(VIRTUAL_WORKOUT_TAG);
    if (isVirtual) {
      if (sport == ActivityType.Ride) {
        return ActivityType.VirtualRide;
      }
      if (sport == ActivityType.Run) {
        return ActivityType.VirtualRun;
      }
    } else {
      if (sport == ActivityType.VirtualRide) {
        return ActivityType.Ride;
      }
      if (sport == ActivityType.VirtualRun) {
        return ActivityType.Run;
      }
    }
    return sport;
  }

  String unit(bool si) {
    if (sport == ActivityType.Ride || sport == ActivityType.VirtualRide) {
      return si ? 'kmh' : 'mph';
    } else if (sport == ActivityType.Run || sport == ActivityType.VirtualRun) {
      return si ? 'min /km' : 'min /mi';
    } else if (sport == ActivityType.Kayaking ||
        sport == ActivityType.Canoeing ||
        sport == ActivityType.Rowing) {
      return 'min /500';
    }
    return si ? 'kmh' : 'mph';
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

  int getRevolutions(List<int> data) {
    return revolutionsMetric?.getMeasurementValue(data)?.toInt();
  }

  double getRevolutionTime(List<int> data) {
    return revolutionTime?.getMeasurementValue(data);
  }

  int getStrokeRate(List<int> data) {
    return strokeRateMetric?.getMeasurementValue(data)?.toInt();
  }

  double getPace(List<int> data) {
    return paceMetric?.getMeasurementValue(data);
  }

  double getHeartRate(List<int> data) {
    if (heartRate == null) return 0;
    return data[heartRate].toDouble();
  }

  clearMetrics() {
    speedMetric = null;
    cadenceMetric = null;
    distanceMetric = null;
    powerMetric = null;
    caloriesMetric = null;
    timeMetric = null;
    revolutionsMetric = null;
    revolutionTime = null;
    strokeRateMetric = null;
    paceMetric = null;
    caloriesPerHourMetric = null;
    caloriesPerMinuteMetric = null;
  }
}
