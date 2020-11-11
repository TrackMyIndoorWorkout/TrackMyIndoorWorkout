import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';

typedef MeasurementProcessing(List<int> data);

abstract class DeviceDescriptor {
  static const double MS2KMH = 3.6;
  static const int MAX_UINT16 = 65536;
  static const double J2KCAL = 0.0002390057;

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
  final MeasurementProcessing canPrimaryMeasurementProcessed;
  String cadenceMeasurementServiceId;
  String cadenceMeasurementId;
  final MeasurementProcessing canCadenceMeasurementProcessed;
  int heartRate;

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
    this.canPrimaryMeasurementProcessed,
    this.cadenceMeasurementServiceId = '',
    this.cadenceMeasurementId = '',
    this.canCadenceMeasurementProcessed,
    this.heartRate,
  }) {
    this.fullName = '$vendorName $modelName';
  }

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
  );

  int processCadenceMeasurement(List<int> data);
}
