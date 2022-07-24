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
    manufacturerPrefix,
    manufacturerFitId,
    model,
    dataServiceId,
    dataCharacteristicId,
    secondaryCharacteristicId = "",
    controlCharacteristicId = "",
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
          manufacturerPrefix: manufacturerPrefix,
          manufacturerFitId: manufacturerFitId,
          model: model,
          dataServiceId: dataServiceId,
          dataCharacteristicId: dataCharacteristicId,
          secondaryCharacteristicId: secondaryCharacteristicId,
          controlCharacteristicId: controlCharacteristicId,
          hasFeatureFlags: false,
          heartRateByteIndex: heartRateByteIndex,
          timeMetric: timeMetric,
          caloriesMetric: caloriesMetric,
          speedMetric: speedMetric,
          powerMetric: powerMetric,
          cadenceMetric: cadenceMetric,
          distanceMetric: distanceMetric,
        );

  @override
  RecordWithSport? stubRecord(List<int> data) {
    return RecordWithSport(
      distance: getDistance(data),
      elapsed: getTime(data)?.toInt(),
      calories: getCalories(data)?.toInt(),
      power: getPower(data)?.toInt(),
      speed: getSpeed(data),
      cadence: getCadence(data)?.toInt(),
      heartRate: getHeartRate(data)?.toInt(),
      sport: defaultSport,
    );
  }
}
