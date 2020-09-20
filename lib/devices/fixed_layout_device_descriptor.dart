import '../persistence/models/record.dart';
import '../track/utils.dart';
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
  Record getMeasurement(DateTime rightNow, DateTime lastRecord, double speed,
      double distance, bool paused, List<int> data) {
    double dD = 0;
    if (speed > 0) {
      Duration dT = rightNow.difference(lastRecord);
      dD = speed / DeviceDescriptor.MS2KMH * dT.inMilliseconds / 1000.0;
    }
    final gps = calculateGPS(distance + dD);
    return Record(
      distance: distance + dD,
      elapsed: getTime(data).toInt(),
      calories: getCalories(data).toInt(),
      power: getPower(data).toInt(),
      speed: getSpeed(data),
      cadence: getCadence(data).toInt(),
      heartRate: getHeartRate(data).toInt(),
      lon: gps.dx,
      lat: gps.dy,
    );
  }
}
