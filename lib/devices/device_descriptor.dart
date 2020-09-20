import '../persistence/models/record.dart';

typedef MeasurementProcessing(List<int> data);

abstract class DeviceDescriptor {
  static const double MS2KMH = 3.6;

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
  final int heartRate;
  final MeasurementProcessing canMeasurementProcessed;

  DeviceDescriptor({
    this.vendorName,
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
    this.heartRate,
    this.canMeasurementProcessed,
  }) {
    this.fullName = '$vendorName $modelName';
  }

  Record getMeasurement(DateTime rightNow, DateTime lastRecord, double speed,
      double distance, List<int> data, Record supplement);
}
