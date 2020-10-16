import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import 'device_descriptor.dart';
import 'metric_descriptor.dart';

class FixedLayoutDeviceDescriptor extends DeviceDescriptor {
  final MetricDescriptor time;
  final MetricDescriptor calories;
  final MetricDescriptor speed;
  final MetricDescriptor power;
  final MetricDescriptor cadence;

  FixedLayoutDeviceDescriptor({
    vendorName,
    modelName,
    fullName = '',
    sku,
    namePrefix,
    nameStart,
    manufacturer,
    model,
    measurementServiceId,
    equipmentTypeId,
    equipmentStateId,
    measurementId,
    heartRate,
    canMeasurementProcessed,
    this.time,
    this.calories,
    this.speed,
    this.power,
    this.cadence,
  }) : super(
          vendorName: vendorName,
          modelName: modelName,
          fullName: fullName,
          sku: sku,
          namePrefix: namePrefix,
          nameStart: nameStart,
          manufacturer: manufacturer,
          model: model,
          measurementServiceId: measurementServiceId,
          equipmentTypeId: equipmentTypeId,
          equipmentStateId: equipmentStateId,
          measurementId: measurementId,
          heartRate: heartRate,
          canMeasurementProcessed: canMeasurementProcessed,
        );

  double getTime(List<int> data) {
    return time.getMeasurementValue(data);
  }

  double getCalories(List<int> data) {
    return calories.getMeasurementValue(data);
  }

  double getSpeed(List<int> data) {
    return speed.getMeasurementValue(data);
  }

  double getPower(List<int> data) {
    return power.getMeasurementValue(data);
  }

  double getCadence(List<int> data) {
    return cadence.getMeasurementValue(data);
  }

  double getHeartRate(List<int> data) {
    return data[heartRate].toDouble();
  }

  @override
  Record getMeasurement(
    Activity activity,
    int lastElapsed,
    Duration idleDuration,
    double speed,
    double distance,
    List<int> data,
    Record supplement,
  ) {
    final elapsed = getTime(data).toInt();
    double dD = 0;
    if (speed > 0) {
      final dT = elapsed - lastElapsed;
      if (dT > 0) {
        dD = dT > 0 ? speed / DeviceDescriptor.MS2KMH * dT : 0.0;
      }
    }
    final elapsedDuration = Duration(seconds: elapsed);
    final timeStamp = activity.startDateTime.add(idleDuration).add(elapsedDuration);
    if (data != null) {
      return Record(
        activityId: activity.id,
        timeStamp: timeStamp.millisecondsSinceEpoch,
        distance: distance + dD,
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
        distance: distance + dD,
        elapsed: supplement.elapsed,
        calories: supplement.calories,
        power: supplement.power,
        speed: speed,
        cadence: supplement.cadence,
        heartRate: supplement.heartRate,
      );
    }
  }
}
