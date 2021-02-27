import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../devices/cadence_data.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/preferences.dart';
import '../tcx/activity_type.dart';
import '../track/tracks.dart';
import 'byte_metric_descriptor.dart';
import 'short_metric_descriptor.dart';
import 'three_byte_metric_descriptor.dart';

typedef bool MeasurementProcessing(List<int> data);

abstract class DeviceDescriptor {
  static const double MS2KMH = 3.6;
  static const double KMH2MS = 1 / MS2KMH;
  static const int MAX_UINT16 = 65536;
  static const double J2CAL = 0.2390057;
  static const double J2KCAL = J2CAL / 1000.0;
  static const int REVOLUTION_SLIDING_WINDOW = 15; // Seconds
  static const int EVENT_TIME_OVERFLOW = 64; // Overflows every 64 seconds

  final String sport;
  final String fourCC;
  final String vendorName;
  final String modelName;
  var fullName;
  final String namePrefix;
  final List<int> nameStart;
  final List<int> manufacturer;
  final List<int> model;
  final String primaryServiceId;
  final String primaryMeasurementId;
  final MeasurementProcessing canPrimaryMeasurementProcessed;
  String cadenceServiceId;
  String cadenceMeasurementId;

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

  // Secondary (Crank cadence) metrics
  ShortMetricDescriptor revolutionsMetric;
  ShortMetricDescriptor revolutionTime;
  // Secondary (Crank cadence) metrics
  int cadenceFlag;
  ListQueue<CadenceData> cadenceData;

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
    this.primaryServiceId,
    this.primaryMeasurementId,
    this.canPrimaryMeasurementProcessed,
    this.cadenceServiceId = '',
    this.cadenceMeasurementId = '',
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
    cadenceFlag = 0;
    cadenceData = ListQueue<CadenceData>();
  }

  double get lengthFactor => getDefaultTrack(sport).lengthFactor;

  restartWorkout();

  Record processPrimaryMeasurement(
    Activity activity,
    Duration idleDuration,
    Record lastRecord,
    List<int> data,
  );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.csc_measurement.xml
  bool canCadenceMeasurementProcessed(List<int> data) {
    if (data == null || data.length < 1) return false;

    var flag = data[0];
    // 16 bit revolution and 16 bit time
    if (cadenceFlag != flag && flag > 0) {
      var expectedLength = 1; // The flag itself
      // Has wheel revolution? (first bit)
      if (flag % 2 == 1) {
        // Skip it, we are not interested in wheel revolution
        expectedLength += 6; // 32 bit revolution and 16 bit time
      }
      flag ~/= 2;
      // Has crank revolution? (second bit)
      if (flag % 2 == 1) {
        expectedLength += 4; // 16 bit revolution and 16 bit time
      } else {
        return false;
      }
      revolutionsMetric = ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1);
      revolutionTime =
          ShortMetricDescriptor(lsb: expectedLength + 2, msb: expectedLength + 3, divider: 1024.0);
      cadenceFlag = flag;

      return data.length == expectedLength;
    }

    return flag > 0;
  }

  int processCadenceMeasurement(List<int> data) {
    if (!canCadenceMeasurementProcessed(data)) return 0;

    cadenceData.add(CadenceData(
      seconds: getRevolutionTime(data),
      revolutions: getRevolutions(data),
    ));

    var firstData = cadenceData.first;
    if (cadenceData.length == 1) {
      return firstData.revolutions ~/ firstData.seconds;
    }

    var lastData = cadenceData.last;
    var revDiff = lastData.revolutions - firstData.revolutions;
    // Check overflow
    if (revDiff < 0) {
      revDiff += DeviceDescriptor.MAX_UINT16;
    }
    var secondsDiff = lastData.seconds - firstData.seconds;
    // Check overflow
    if (secondsDiff < 0) {
      secondsDiff += EVENT_TIME_OVERFLOW;
    }

    while (secondsDiff > REVOLUTION_SLIDING_WINDOW && cadenceData.length > 2) {
      cadenceData.removeFirst();
      secondsDiff = cadenceData.last.seconds - cadenceData.first.seconds;
      // Check overflow
      if (secondsDiff < 0) {
        secondsDiff += EVENT_TIME_OVERFLOW;
      }
    }

    return revDiff ~/ secondsDiff;
  }

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
    revolutionsMetric = null;
    revolutionTime = null;
    strokeRateMetric = null;
    paceMetric = null;
    caloriesPerHourMetric = null;
    caloriesPerMinuteMetric = null;
  }
}
