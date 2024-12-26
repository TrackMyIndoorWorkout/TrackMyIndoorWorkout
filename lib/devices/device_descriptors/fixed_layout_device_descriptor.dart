import '../../persistence/record.dart';
import 'device_descriptor.dart';

abstract class FixedLayoutDeviceDescriptor extends DeviceDescriptor {
  FixedLayoutDeviceDescriptor({
    required super.sport,
    required super.isMultiSport,
    required super.fourCC,
    required super.vendorName,
    required super.modelName,
    required super.manufacturerNamePart,
    required super.manufacturerFitId,
    required super.model,
    required super.dataServiceId,
    required super.dataCharacteristicId,
    super.controlCharacteristicId = "",
    super.statusCharacteristicId = "",
    super.tag = "FIXED_LAYOUT_DEVICE_DESCRIPTOR",
    super.listenOnControl = true,
    super.flagByteSize = 3,
    super.heartRateByteIndex,
    super.timeMetric,
    super.caloriesMetric,
    super.speedMetric,
    super.powerMetric,
    super.cadenceMetric,
    super.distanceMetric,
  }) : super(
          deviceCategory: DeviceCategory.smartDevice,
          hasFeatureFlags: false,
        );

  @override
  void processFlag(int flag, int dataLength) {
    // Empty implementation, hard coded layouts overlook flags
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    final cadence = getCadence(data);
    return RecordWithSport(
      distance: getDistance(data),
      elapsed: getTime(data)?.toInt(),
      calories: getCalories(data)?.toInt(),
      power: getPower(data)?.toInt(),
      speed: getSpeed(data),
      cadence: cadence?.toInt(),
      preciseCadence: cadence,
      resistance: getResistance(data)?.toInt(),
      heartRate: getHeartRate(data),
      sport: sport,
    );
  }
}
