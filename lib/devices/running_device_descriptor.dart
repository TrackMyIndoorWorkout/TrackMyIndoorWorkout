import 'package:preferences/preference_service.dart';
import 'package:track_my_indoor_exercise/tcx/activity_type.dart';
import '../persistence/preferences.dart';
import 'device_descriptor.dart';

abstract class RunningDeviceDescriptor extends DeviceDescriptor {
  RunningDeviceDescriptor({
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
    canPrimaryMeasurementProcessed,
    cadenceMeasurementServiceId = '',
    cadenceMeasurementId = '',
    canCadenceMeasurementProcessed,
    heartRate,
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
          canPrimaryMeasurementProcessed: canPrimaryMeasurementProcessed,
          cadenceMeasurementServiceId: cadenceMeasurementServiceId,
          cadenceMeasurementId: cadenceMeasurementId,
          canCadenceMeasurementProcessed: canCadenceMeasurementProcessed,
          heartRate: heartRate,
        );

  String activityType() {
    final isVirtual = PrefService.getBool(VIRTUAL_WORKOUT_TAG);
    return isVirtual ? ActivityType.VirtualRun : ActivityType.Run;
  }
}
