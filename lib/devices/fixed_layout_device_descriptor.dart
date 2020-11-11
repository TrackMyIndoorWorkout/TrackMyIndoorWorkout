import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import 'device_descriptor.dart';
import 'short_metric_descriptor.dart';

class FixedLayoutDeviceDescriptor extends DeviceDescriptor {
  final ShortMetricDescriptor timeMetric;
  final ShortMetricDescriptor caloriesMetric;
  final ShortMetricDescriptor speedMetric;
  final ShortMetricDescriptor powerMetric;
  final ShortMetricDescriptor cadenceMetric;

  FixedLayoutDeviceDescriptor({
    fourCC,
    vendorName,
    modelName,
    fullName = '',
    namePrefix,
    nameStart,
    manufacturer,
    model,
    primaryMeasurementServiceId,
    primaryMeasurementId,
    heartRate,
    canPrimaryMeasurementProcessed,
    this.timeMetric,
    this.caloriesMetric,
    this.speedMetric,
    this.powerMetric,
    this.cadenceMetric,
  }) : super(
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
        );

  double getTime(List<int> data) {
    return timeMetric.getMeasurementValue(data);
  }

  double getCalories(List<int> data) {
    return caloriesMetric.getMeasurementValue(data);
  }

  double getSpeed(List<int> data) {
    return speedMetric.getMeasurementValue(data);
  }

  double getPower(List<int> data) {
    return powerMetric.getMeasurementValue(data);
  }

  double getCadence(List<int> data) {
    return cadenceMetric.getMeasurementValue(data);
  }

  double getHeartRate(List<int> data) {
    return data[heartRate].toDouble();
  }

  @override
  Record processPrimaryMeasurement(
    Activity activity,
    int lastElapsed,
    Duration idleDuration,
    double lastSpeed,
    double lastDistance,
    int lastCalories,
    int cadence,
    List<int> data,
    Record supplement,
  ) {
    final elapsed = data != null ? getTime(data).toInt() : lastElapsed;
    double dD = 0;
    if (lastSpeed > 0) {
      final dT = elapsed - lastElapsed;
      if (dT > 0) {
        dD = dT > 0 ? lastSpeed / DeviceDescriptor.MS2KMH * dT : 0.0;
      }
    }
    final elapsedDuration = Duration(seconds: elapsed);
    // This is not simply DateTime.now() because the measurements may
    // flood in batches for processing so we take their timestamp
    // instead of the current time
    // See github.com/TrackMyIndoorWorkout/TrackMyIndoorWorkout/issues/16
    final timeStamp =
        activity.startDateTime.add(idleDuration).add(elapsedDuration);
    if (data != null) {
      return Record(
        activityId: activity.id,
        timeStamp: timeStamp.millisecondsSinceEpoch,
        distance: lastDistance + dD,
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
        distance: lastDistance + dD,
        elapsed: supplement.elapsed,
        calories: supplement.calories,
        power: supplement.power,
        speed: lastSpeed,
        cadence: supplement.cadence,
        heartRate: supplement.heartRate,
      );
    }
  }

  @override
  int processCadenceMeasurement(List<int> data) {
    return 0;
  }
}
