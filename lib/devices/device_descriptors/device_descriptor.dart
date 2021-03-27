import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import '../../tcx/activity_type.dart';
import '../../track/tracks.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import '../gatt_constants.dart';

abstract class DeviceDescriptor {
  static const double MS2KMH = 3.6;
  static const double KMH2MS = 1 / MS2KMH;
  static const double J2CAL = 0.2390057;
  static const double J2KCAL = J2CAL / 1000.0;

  final String defaultSport;
  final bool isMultiSport;
  final String fourCC;
  final String vendorName;
  final String modelName;
  var fullName;
  final String namePrefix;
  final String manufacturer;
  final String model;
  final String dataServiceId;
  final String dataCharacteristicId;

  int featuresFlag;
  int byteCounter;

  bool canMeasureHeartRate;
  int heartRateByteIndex;

  // Common metrics
  ShortMetricDescriptor speedMetric;
  ShortMetricDescriptor cadenceMetric;
  ThreeByteMetricDescriptor distanceMetric;
  ShortMetricDescriptor powerMetric;
  ShortMetricDescriptor caloriesMetric;
  ShortMetricDescriptor timeMetric;
  ShortMetricDescriptor caloriesPerHourMetric;
  ByteMetricDescriptor caloriesPerMinuteMetric;

  // Adjusting skewed calories
  double calorieFactor;
  // Adjusting skewed distance
  double distanceFactor;
  double throttlePower;
  bool throttleOther;

  DeviceDescriptor({
    @required this.defaultSport,
    @required this.isMultiSport,
    @required this.fourCC,
    @required this.vendorName,
    @required this.modelName,
    this.fullName = '',
    @required this.namePrefix,
    this.manufacturer,
    this.model,
    this.dataServiceId,
    this.dataCharacteristicId,
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
  })  : assert(defaultSport != null),
        assert(isMultiSport != null),
        assert(fourCC != null),
        assert(vendorName != null),
        assert(modelName != null),
        assert(fullName != null),
        assert(namePrefix != null) {
    this.fullName = '$vendorName $modelName';
    featuresFlag = 0;
    byteCounter = 0;
    throttlePower = 1.0;
    throttleOther = THROTTLE_OTHER_DEFAULT;
  }

  double get lengthFactor => getDefaultTrack(defaultSport).lengthFactor;
  bool get isFitnessMachine => dataServiceId == FITNESS_MACHINE_ID;

  void stopWorkout();

  bool canDataProcessed(List<int> data);

  void processFlag(int flag) {
    clearMetrics();
    byteCounter = 2;
  }

  RecordWithSport stubRecord(List<int> data) {
    if ((data?.length ?? 0) > 2) {
      var flag = data[0] + 256 * data[1];
      if (flag != featuresFlag) {
        featuresFlag = flag;
        processFlag(flag);
      }
    }
    return null;
  }

  String get tcxSport => defaultSport == ActivityType.Ride && defaultSport == ActivityType.Run ? defaultSport : "Other";

  String getSpeedUnit(bool si) {
    if (defaultSport == ActivityType.Ride) {
      return si ? 'kmh' : 'mph';
    } else if (defaultSport == ActivityType.Run) {
      return si ? 'min /km' : 'min /mi';
    } else if (defaultSport == ActivityType.Kayaking ||
        defaultSport == ActivityType.Canoeing ||
        defaultSport == ActivityType.Rowing) {
      return 'min /500';
    } else if (defaultSport == ActivityType.Swim) {
      return 'min /100';
    }
    return si ? 'kmh' : 'mph';
  }

  String get speedTitle => defaultSport == ActivityType.Ride ? "Speed" : "Pace";

  IconData getIcon() {
    if (defaultSport == ActivityType.Ride) {
      return Icons.directions_bike;
    } else if (defaultSport == ActivityType.Run) {
      return Icons.directions_run;
    } else if (defaultSport == ActivityType.Kayaking ||
        defaultSport == ActivityType.Canoeing ||
        defaultSport == ActivityType.Rowing) {
      return Icons.rowing;
    } else if (defaultSport == ActivityType.Swim) {
      return Icons.waves;
    }
    return Icons.directions_bike;
  }

  String getCadenceUnit() {
    if (defaultSport == ActivityType.Kayaking ||
        defaultSport == ActivityType.Canoeing ||
        defaultSport == ActivityType.Rowing ||
        defaultSport == ActivityType.Swim) {
      return "spm";
    }
    return "rpm";
  }

  void setPowerThrottle(String throttlePercentString, bool throttleOther) {
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

  double getHeartRate(List<int> data) {
    if (heartRateByteIndex == null) return 0;
    return data[heartRateByteIndex].toDouble();
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
