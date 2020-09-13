import 'metric_descriptor.dart';

class DeviceDescriptor {
  final String vendorName;
  final String modelName;
  var fullName;
  final String sku;
  final String namePrefix;
  final List<int> nameStart;
  final List<int> manufacturer;
  final List<int> model;
  final String measurementServiceId;
  final String equipmentTypeId;
  final String equipmentStateId;
  final String measurementId;
  final int byteCount;
  final List<int> measurementPrefix;
  final MetricDescriptor time;
  final MetricDescriptor calories;
  final MetricDescriptor speed;
  final MetricDescriptor power;
  final MetricDescriptor cadence;
  final int heartRate;

  DeviceDescriptor(
      {this.vendorName,
      this.modelName,
      this.fullName = '',
      this.sku,
      this.namePrefix,
      this.nameStart,
      this.manufacturer,
      this.model,
      this.measurementServiceId,
      this.equipmentTypeId,
      this.equipmentStateId,
      this.measurementId,
      this.byteCount,
      this.measurementPrefix,
      this.time,
      this.calories,
      this.speed,
      this.power,
      this.cadence,
      this.heartRate}) {
    this.fullName = '$vendorName $modelName';
  }

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
}
