import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';

typedef MeasurementProcessing(List<int> data);

abstract class DeviceDescriptor {
  static const double MS2KMH = 3.6;

  final String fourCC;
  final String vendorName;
  final String modelName;
  var fullName;
  final String namePrefix;
  final List<int> nameStart;
  final List<int> manufacturer;
  final List<int> model;
  final String primaryMeasurementServiceId;
  final String primaryMeasurementId;
  String cadenceMeasurementServiceId;
  String cadenceMeasurementId;
  final int heartRate;
  final MeasurementProcessing canMeasurementProcessed;

  DeviceDescriptor({
    this.fourCC,
    this.vendorName,
    this.modelName,
    this.fullName = '',
    this.namePrefix,
    this.nameStart,
    this.manufacturer,
    this.model,
    this.primaryMeasurementServiceId,
    this.primaryMeasurementId,
    this.cadenceMeasurementServiceId = '',
    this.cadenceMeasurementId = '',
    this.heartRate,
    this.canMeasurementProcessed,
  }) {
    this.fullName = '$vendorName $modelName';
  }

  Record getMeasurement(
    Activity activity,
    int lastElapsed,
    Duration idleDuration,
    double speed,
    double distance,
    List<int> data,
    Record supplement,
  );
}
