import '../../persistence/models/record.dart';
import 'device_descriptor.dart';

abstract class FixedLayoutDeviceDescriptor extends DeviceDescriptor {
  FixedLayoutDeviceDescriptor({
    required defaultSport,
    required isMultiSport,
    required fourCC,
    required vendorName,
    required modelName,
    required namePrefixes,
    manufacturerNamePart,
    manufacturerFitId,
    model,
    dataServiceId,
    dataCharacteristicId,
    controlCharacteristicId = "",
    listenOnControl = true,
    flagByteSize = 3,
    heartRateByteIndex,
    timeMetric,
    caloriesMetric,
    speedMetric,
    powerMetric,
    cadenceMetric,
    distanceMetric,
  }) : super(
          defaultSport: defaultSport,
          isMultiSport: isMultiSport,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          namePrefixes: namePrefixes,
          manufacturerNamePart: manufacturerNamePart,
          manufacturerFitId: manufacturerFitId,
          model: model,
          deviceCategory: DeviceCategory.smartDevice,
          dataServiceId: dataServiceId,
          dataCharacteristicId: dataCharacteristicId,
          controlCharacteristicId: controlCharacteristicId,
          listenOnControl: listenOnControl,
          hasFeatureFlags: false,
          flagByteSize: flagByteSize,
          heartRateByteIndex: heartRateByteIndex,
          timeMetric: timeMetric,
          caloriesMetric: caloriesMetric,
          speedMetric: speedMetric,
          powerMetric: powerMetric,
          cadenceMetric: cadenceMetric,
          distanceMetric: distanceMetric,
        );

  @override
  void processFlag(int flag) {
    // Empty implementation, hard coded layouts overlook flags
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    return RecordWithSport(
      distance: getDistance(data),
      elapsed: getTime(data)?.toInt(),
      calories: getCalories(data)?.toInt(),
      power: getPower(data)?.toInt(),
      speed: getSpeed(data),
      cadence: getCadence(data)?.toInt(),
      heartRate: getHeartRate(data),
      sport: defaultSport,
    );
  }
}
