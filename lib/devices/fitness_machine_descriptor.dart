import 'dart:collection';

import 'package:meta/meta.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import 'byte_metric_descriptor.dart';
import 'cadence_data.dart';
import 'device_descriptor.dart';
import 'short_metric_descriptor.dart';
import 'three_byte_metric_descriptor.dart';

abstract class FitnessMachineDescriptor extends DeviceDescriptor {
  // Primary metrics
  int featuresFlag;

  // Secondary (Crank cadence) metrics
  int cadenceFlag;

  int byteCounter;
  ListQueue<CadenceData> cadenceData;
  static const int REVOLUTION_SLIDING_WINDOW = 15; // Seconds
  static const int EVENT_TIME_OVERFLOW = 64; // Overflows every 64 seconds
  double residueCalories;

  FitnessMachineDescriptor({
    @required sport,
    @required fourCC,
    @required vendorName,
    @required modelName,
    fullName = '',
    @required namePrefix,
    nameStart,
    manufacturer,
    model,
    primaryMeasurementServiceId,
    primaryMeasurementId,
    canPrimaryMeasurementProcessed,
    cadenceMeasurementServiceId,
    cadenceMeasurementId,
    canCadenceMeasurementProcessed,
    heartRate,
    calorieFactor,
    distanceFactor = 1.0,
  }) : super(
          sport: sport,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          fullName: fullName,
          namePrefix: namePrefix,
          nameStart: nameStart,
          manufacturer: manufacturer,
          model: model,
          primaryMeasurementServiceId: primaryMeasurementServiceId,
          primaryMeasurementId: primaryMeasurementId,
          canPrimaryMeasurementProcessed: canPrimaryMeasurementProcessed,
          cadenceMeasurementServiceId: cadenceMeasurementServiceId,
          cadenceMeasurementId: cadenceMeasurementId,
          canCadenceMeasurementProcessed: canCadenceMeasurementProcessed,
          heartRate: heartRate,
          calorieFactor: calorieFactor,
          distanceFactor: distanceFactor,
        ) {
    cadenceData = ListQueue<CadenceData>();
    featuresFlag = 0;
    cadenceFlag = 0;
    residueCalories = 0;
  }

  processFlag(int flag);

  int processCadenceMeasurement(List<int> data) {
    if (!canCadenceMeasurementProcessed(data)) return 0;

    var flag = data[0];
    // 16 bit revolution and 16 bit time
    if (cadenceFlag != flag) {
      var lengthOffset = 1; // The flag itself
      // Has wheel revolution? (first bit)
      if (flag % 2 == 1) {
        // Skip it, we are not interested in wheel revolution
        lengthOffset += 6; // 32 bit revolution and 16 bit time
      }
      flag ~/= 2;
      // Has crank revolution? (second bit)
      if (flag % 2 == 0) {
        return 0;
      }
      revolutionsMetric =
          ShortMetricDescriptor(lsb: lengthOffset, msb: lengthOffset + 1, divider: 1.0);
      revolutionTime =
          ShortMetricDescriptor(lsb: lengthOffset + 2, msb: lengthOffset + 3, divider: 1024.0);
      cadenceFlag = flag;
    }

    // See https://web.archive.org/web/20170816162607/https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.csc_measurement.xml
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
      secondsDiff += FitnessMachineDescriptor.EVENT_TIME_OVERFLOW;
    }

    while (secondsDiff > FitnessMachineDescriptor.REVOLUTION_SLIDING_WINDOW &&
        cadenceData.length > 2) {
      cadenceData.removeFirst();
      secondsDiff = cadenceData.last.seconds - cadenceData.first.seconds;
      // Check overflow
      if (secondsDiff < 0) {
        secondsDiff += FitnessMachineDescriptor.EVENT_TIME_OVERFLOW;
      }
    }

    return revDiff ~/ secondsDiff;
  }

  int processSpeedFlag(int flag, bool negated) {
    if (flag % 2 == (negated ? 1 : 0)) {
      if (speedMetric == null) {
        // UInt16, km/h with 0.01 resolution
        speedMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 100.0);
      }
      byteCounter += 2;
    }
    flag ~/= 2;
    return flag;
  }

  int processCadenceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16, revolutions / minute with 0.5 resolution
      if (cadenceMetric == null) {
        cadenceMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 2.0);
      }
      byteCounter += 2;
    }
    flag ~/= 2;
    return flag;
  }

  int processTotalDistanceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt24, meters
      distanceMetric =
          ThreeByteMetricDescriptor(lsb: byteCounter, msb: byteCounter + 2, divider: 1.0);
      byteCounter += 3;
    }
    flag ~/= 2;
    return flag;
  }

  int processResistanceLevelFlag(int flag) {
    if (flag % 2 == 1) {
      // SInt16
      byteCounter += 2;
    }
    flag ~/= 2;
    return flag;
  }

  int processPowerFlag(int flag) {
    if (flag % 2 == 1) {
      if (powerMetric == null) {
        // SInt16, Watts
        powerMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 1.0);
      }
      byteCounter += 2;
    }
    flag ~/= 2;
    return flag;
  }

  int processExpandedEnergyFlag(int flag) {
    if (flag % 2 == 1) {
      // Total Energy: UInt16
      caloriesMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 1.0);
      // Energy / hour UInt16
      caloriesPerHourMetric =
          ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 1.0);
      // Energy / minute UInt8
      caloriesPerMinuteMetric = ByteMetricDescriptor(lsb: byteCounter, divider: 1.0);
      byteCounter += 5;
    }
    flag ~/= 2;
    return flag;
  }

  int processHeartRateFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt8
      heartRate = byteCounter;
      byteCounter++;
    }
    flag ~/= 2;
    return flag;
  }

  int processMetabolicEquivalentFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt8
      byteCounter++;
    }
    flag ~/= 2;
    return flag;
  }

  int processElapsedTimeFlag(int flag) {
    if (flag % 2 == 1) {
      timeMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 1.0);
      byteCounter += 2;
    }
    flag ~/= 2;
    return flag;
  }

  int processRemainingTimeFlag(int flag) {
    if (flag % 2 == 1) {
      byteCounter += 2;
    }
    flag ~/= 2;
    return flag;
  }

  int processStrokeRateFlag(int flag, bool negated) {
    if (flag % 2 == (negated ? 1 : 0)) {
      // UByte with 0.5 resolution
      strokeRateMetric = ByteMetricDescriptor(lsb: byteCounter, divider: 2.0);
      byteCounter += 1;
      revolutionsMetric =
          ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 1.0);
      byteCounter += 2;
    }
    flag ~/= 2;
    return flag;
  }

  int processAverageStrokeRateFlag(int flag) {
    if (flag % 2 == 1) {
      if (strokeRateMetric != null) {
        // UByte with 0.5 resolution
        strokeRateMetric = ByteMetricDescriptor(lsb: byteCounter, divider: 2.0);
      }
      byteCounter += 1;
    }
    flag ~/= 2;
    return flag;
  }

  int processPaceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16, seconds with 1 resolution
      if (paceMetric == null) {
        paceMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 1.0);
      }
      byteCounter += 2;
    }
    flag ~/= 2;
    return flag;
  }

  @override
  Record processPrimaryMeasurement(
    Activity activity,
    Duration idleDuration,
    Record lastRecord,
    List<int> data,
  ) {
    if (data != null && data.length > 2) {
      var flag = data[0] + 256 * data[1];
      if (flag != featuresFlag) {
        featuresFlag = flag;
        processFlag(flag);
      }
    }

    double elapsed;
    Duration elapsedDuration;
    int elapsedMillis;
    if (data != null && timeMetric != null) {
      elapsed = getTime(data);
      elapsedMillis = (elapsed * 1000.0).toInt();
      elapsedDuration = Duration(seconds: lastRecord.elapsed);
    } else {
      elapsedMillis =
          DateTime.now().subtract(idleDuration).difference(activity.startDateTime).inMilliseconds;
      elapsed = elapsedMillis / 1000.0;
      elapsedDuration = Duration(milliseconds: elapsedMillis);
    }

    double newDistance = 0;
    final dT = (elapsedMillis - lastRecord.elapsedMillis) / 1000.0;
    if (data != null && distanceMetric != null) {
      newDistance = getDistance(data);
    } else {
      double dD = 0;
      if (lastRecord.speed > 0) {
        if (dT > 0) {
          dD = lastRecord.speed * DeviceDescriptor.KMH2MS * distanceFactor * dT;
        }
      }
      newDistance = lastRecord.distance + dD;
    }
    final timeStamp = activity.startDateTime.add(idleDuration).add(elapsedDuration);
    if (data != null) {
      var cadence = lastRecord.cadence;
      if (cadenceMetric != null) {
        cadence = getCadence(data).toInt();
      } else if (strokeRateMetric != null) {
        cadence = getStrokeRate(data);
      }
      double power = getPower(data);
      double calories = 0;
      if (caloriesMetric != null) {
        calories = getCalories(data);
      } else {
        // Instead of dT fractional second we use 1s to boost calorie counting
        // Due to #35. On top of that
        final deltaCalories = power * calorieFactor * DeviceDescriptor.J2KCAL;
        residueCalories += deltaCalories;
        calories = lastRecord.calories + residueCalories;
        if (calories.floor() > lastRecord.calories) {
          residueCalories = calories - calories.floor();
        }
      }
      return Record(
        activityId: activity.id,
        timeStamp: timeStamp.millisecondsSinceEpoch,
        distance: newDistance,
        elapsed: elapsed.toInt(),
        calories: calories.floor(),
        power: power.toInt(),
        speed: getSpeed(data),
        cadence: cadence,
        heartRate: getHeartRate(data).toInt(),
        pace: getPace(data),
        elapsedMillis: elapsedMillis,
        sport: sport,
      );
    } else {
      return Record(
        activityId: activity.id,
        timeStamp: timeStamp.millisecondsSinceEpoch,
        distance: newDistance,
        elapsed: lastRecord.elapsed,
        calories: lastRecord.calories,
        power: lastRecord.power,
        speed: lastRecord.speed,
        cadence: lastRecord.cadence,
        heartRate: lastRecord.heartRate,
        pace: lastRecord.pace,
        elapsedMillis: elapsedMillis,
        sport: sport,
      );
    }
  }
}
