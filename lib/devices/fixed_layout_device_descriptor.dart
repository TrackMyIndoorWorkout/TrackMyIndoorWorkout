import 'package:meta/meta.dart';
import '../devices/cadence_sensor.dart';
import '../devices/heart_rate_monitor.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import 'device_descriptor.dart';

abstract class FixedLayoutDeviceDescriptor extends DeviceDescriptor {
  FixedLayoutDeviceDescriptor({
    @required sport,
    @required fourCC,
    @required vendorName,
    @required modelName,
    fullName = '',
    @required namePrefix,
    manufacturer,
    model,
    primaryServiceId,
    primaryMeasurementId,
    canMeasureHeartRate,
    heartRateByteIndex,
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
          manufacturer: manufacturer,
          model: model,
          primaryServiceId: primaryServiceId,
          primaryMeasurementId: primaryMeasurementId,
          canMeasureHeartRate: canMeasureHeartRate,
          heartRateByteIndex: heartRateByteIndex,
          timeMetric: timeMetric,
          caloriesMetric: caloriesMetric,
          speedMetric: speedMetric,
          powerMetric: powerMetric,
          cadenceMetric: cadenceMetric,
          distanceMetric: distanceMetric,
        );

  @override
  restartWorkout() {}

  @override
  Record processPrimaryMeasurement(
    Activity activity,
    Duration idleDuration,
    Record lastRecord,
    List<int> data,
    HeartRateMonitor hrm,
    CadenceSensor cadenceSensor,
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
      var heartRate = 0;
      if (hrm != null) {
        heartRate = hrm.metric;
      }
      if (heartRate == 0) {
        heartRate = getHeartRate(data).toInt();
      }
      return RecordWithSport(
        activityId: activity.id,
        timeStamp: timeStamp.millisecondsSinceEpoch,
        distance: newDistance,
        elapsed: elapsed,
        calories: getCalories(data).toInt(),
        power: getPower(data).toInt(),
        speed: getSpeed(data),
        cadence: getCadence(data).toInt(),
        heartRate: heartRate,
        sport: sport,
      );
    } else {
      return RecordWithSport(
        activityId: activity.id,
        timeStamp: timeStamp.millisecondsSinceEpoch,
        distance: newDistance,
        elapsed: lastRecord.elapsed,
        calories: lastRecord.calories,
        power: lastRecord.power,
        speed: lastRecord.speed,
        cadence: lastRecord.cadence,
        heartRate: lastRecord.heartRate,
        sport: sport,
      );
    }
  }
}
