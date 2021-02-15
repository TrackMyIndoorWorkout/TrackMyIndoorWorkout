import 'package:meta/meta.dart';

import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import 'cadence_data.dart';
import 'device_descriptor.dart';
import 'fitness_machine_descriptor.dart';
import 'short_metric_descriptor.dart';
import 'three_byte_metric_descriptor.dart';

class IndoorBikeDeviceDescriptor extends FitnessMachineDescriptor {
  IndoorBikeDeviceDescriptor({
    @required sport,
    @required fourCC,
    @required vendorName,
    @required modelName,
    fullName = '',
    @required namePrefix,
    nameStart,
    manufacturer,
    model,
    primaryMeasurementServiceId = "1826",
    primaryMeasurementId = "2ad2",
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
        );

  @override
  processFlag(int flag) {
    // Schwinn IC4:
    // 68 01000100 instant cadence, instant power
    //  2 00000010 heart rate
    // Two flag bytes
    int byteCounter = 2;
    // negated bit!
    final hasInstantSpeed = flag % 2 == 0;
    if (hasInstantSpeed) {
      // UInt16, km/h with 0.01 resolution
      speedMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 100.0);
      byteCounter += 2;
    }
    flag ~/= 2;
    // Has Average Speed?
    if (flag % 2 == 1) {
      // UInt16, km/h with 0.01 resolution
      if (!hasInstantSpeed) {
        speedMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 100.0);
      }
      byteCounter += 2;
    }
    flag ~/= 2;
    final hasInstantCadence = flag % 2 == 1;
    if (hasInstantCadence) {
      // UInt16, revolutions / minute with 0.5 resolution
      cadenceMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 2.0);
      byteCounter += 2;
    }
    flag ~/= 2;
    // Has Average Cadence?
    if (flag % 2 == 1) {
      // Fall back to the less instantaneous average metric
      // UInt16, revolutions / minute with 0.5 resolution
      if (!hasInstantCadence) {
        cadenceMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 2.0);
      }
      byteCounter += 2;
    }
    flag ~/= 2;
    // Has Total Distance?
    if (flag % 2 == 1) {
      // UInt24, meters
      distanceMetric =
          ThreeByteMetricDescriptor(lsb: byteCounter, msb: byteCounter + 2, divider: 1.0);
      byteCounter += 3;
    }
    flag ~/= 2;
    // Has Resistance Level
    if (flag % 2 == 1) {
      // SInt16
      byteCounter += 2;
    }
    flag ~/= 2;
    final hasInstantPower = flag % 2 == 1;
    if (hasInstantPower) {
      // SInt16, Watts
      powerMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 1.0);
      byteCounter += 2;
    }
    flag ~/= 2;
    // Has Average Power?
    if (flag % 2 == 1) {
      // Fall back to the less instantaneous average metric
      // SInt16, Watts
      if (!hasInstantPower) {
        powerMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 1.0);
      }
      byteCounter += 2;
    }
    flag ~/= 2;
    // Has Expanded Energy
    if (flag % 2 == 1) {
      // Total Energy: UInt16
      caloriesMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 1.0);
      // Also skipping Energy / hour UInt16 and Energy / minute UInt8
      byteCounter += 5;
    }
    flag ~/= 2;
    // Has Heart Rate
    if (flag % 2 == 1) {
      // UInt8
      heartRate = byteCounter;
      byteCounter++;
    }
    flag ~/= 2;
    // Has Metabolic Equivalent
    if (flag % 2 == 1) {
      // UInt8
      byteCounter++;
    }
    flag ~/= 2;
    // Has Elapsed Time
    if (flag % 2 == 1) {
      timeMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 1.0);
      byteCounter += 2;
    }
    flag ~/= 2;
    // Has Remaining Time
    if (flag % 2 == 1) {
      byteCounter += 2;
    }
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
        elapsedMillis: elapsedMillis,
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
        elapsedMillis: elapsedMillis,
      );
    }
  }

  @override
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
}
