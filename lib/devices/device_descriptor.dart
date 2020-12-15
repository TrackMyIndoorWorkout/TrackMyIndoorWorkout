import 'package:preferences/preference_service.dart';
import 'package:track_my_indoor_exercise/tcx/activity_type.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../persistence/preferences.dart';

typedef MeasurementProcessing(List<int> data);

abstract class DeviceDescriptor {
  static const double MS2KMH = 3.6;
  static const double KMH2MS = 1 / MS2KMH;
  static const int MAX_UINT16 = 65536;
  static const double J2CAL = 0.2390057;
  static const double J2KCAL = J2CAL / 1000.0;

  final bool isBike;
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
    this.isBike,
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
    Duration idleDuration,
    Record lastRecord,
    List<int> data,
  );

  int processCadenceMeasurement(List<int> data);

  String activityType() {
    final isVirtual = PrefService.getBool(VIRTUAL_WORKOUT_TAG);
    if (isVirtual) {
      return isBike ? ActivityType.VirtualRide : ActivityType.VirtualRun;
    }
    return isBike ? ActivityType.Ride : ActivityType.Run;
  }
}
