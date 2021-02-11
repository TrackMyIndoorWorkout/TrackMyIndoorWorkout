import 'package:meta/meta.dart';

import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import 'device_descriptor.dart';

class FixedLayoutDeviceDescriptor extends DeviceDescriptor {
  FixedLayoutDeviceDescriptor({
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
    heartRate,
    canPrimaryMeasurementProcessed,
    timeMetric,
    caloriesMetric,
    speedMetric,
    powerMetric,
    cadenceMetric,
    distanceMetric,
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
          heartRate: heartRate,
          canPrimaryMeasurementProcessed: canPrimaryMeasurementProcessed,
          timeMetric: timeMetric,
          caloriesMetric: caloriesMetric,
          speedMetric: speedMetric,
          powerMetric: powerMetric,
          cadenceMetric: cadenceMetric,
          distanceMetric: distanceMetric,
        );

  @override
  Record processPrimaryMeasurement(
    Activity activity,
    Duration idleDuration,
    Record lastRecord,
    List<int> data,
  ) {
    final elapsed = data != null ? getTime(data).toInt() : lastRecord.elapsed;
    double newDistance = 0;
    if (data != null && distanceMetric != null) {
      newDistance = getDistance(data);
    } else {
      double dD = 0;
      if (lastRecord.speed > 0) {
        final dT = elapsed - lastRecord.speed;
        if (dT > 0) {
          dD = dT > 0 ? lastRecord.speed * DeviceDescriptor.KMH2MS * dT : 0.0;
        }
      }
      newDistance = lastRecord.distance + dD;
    }

    final elapsedDuration = Duration(seconds: elapsed);
    // This is not simply DateTime.now() because the measurements may
    // flood in batches for processing so we take their timestamp
    // instead of the current time
    // See github.com/TrackMyIndoorWorkout/TrackMyIndoorWorkout/issues/16
    final timeStamp = activity.startDateTime.add(idleDuration).add(elapsedDuration);
    if (data != null) {
      return Record(
        activityId: activity.id,
        timeStamp: timeStamp.millisecondsSinceEpoch,
        distance: newDistance,
        elapsed: elapsed,
        calories: getCalories(data).toInt(),
        power: getPower(data).toInt(),
        speed: getSpeed(data),
        cadence: getCadence(data).toInt(),
        heartRate: getHeartRate(data).toInt(),
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
      );
    }
  }

  @override
  int processCadenceMeasurement(List<int> data) {
    return 0;
  }
}
