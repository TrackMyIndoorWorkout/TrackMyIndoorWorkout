import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import 'cycling_device_descriptor.dart';
import 'device_descriptor.dart';
import 'short_metric_descriptor.dart';
import 'three_byte_metric_descriptor.dart';

class FixedLayoutDeviceDescriptor extends CyclingDeviceDescriptor {
  final ShortMetricDescriptor timeMetric;
  final ShortMetricDescriptor caloriesMetric;
  final ShortMetricDescriptor speedMetric;
  final ShortMetricDescriptor powerMetric;
  final ShortMetricDescriptor cadenceMetric;
  final ThreeByteMetricDescriptor distanceMetric;

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
    this.distanceMetric,
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

  double _getTime(List<int> data) {
    return timeMetric?.getMeasurementValue(data);
  }

  double _getCalories(List<int> data) {
    return caloriesMetric?.getMeasurementValue(data);
  }

  double _getSpeed(List<int> data) {
    return speedMetric?.getMeasurementValue(data);
  }

  double _getPower(List<int> data) {
    return powerMetric?.getMeasurementValue(data);
  }

  double _getCadence(List<int> data) {
    return cadenceMetric?.getMeasurementValue(data);
  }

  double _getDistance(List<int> data) {
    return distanceMetric?.getMeasurementValue(data);
  }

  double _getHeartRate(List<int> data) {
    return data[heartRate].toDouble();
  }

  @override
  Record processPrimaryMeasurement(
    Activity activity,
    Duration idleDuration,
    Record lastRecord,
    List<int> data,
  ) {
    final elapsed = data != null ? _getTime(data).toInt() : lastRecord.elapsed;
    double newDistance = 0;
    if (data != null && distanceMetric != null) {
      newDistance = _getDistance(data);
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
    final timeStamp =
        activity.startDateTime.add(idleDuration).add(elapsedDuration);
    if (data != null) {
      return Record(
        activityId: activity.id,
        timeStamp: timeStamp.millisecondsSinceEpoch,
        distance: newDistance,
        elapsed: elapsed,
        calories: _getCalories(data).toInt(),
        power: _getPower(data).toInt(),
        speed: _getSpeed(data),
        cadence: _getCadence(data).toInt(),
        heartRate: _getHeartRate(data).toInt(),
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
