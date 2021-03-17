import 'package:meta/meta.dart';
import '../persistence/models/record.dart';
import 'device_descriptor.dart';

abstract class FixedLayoutDeviceDescriptor extends DeviceDescriptor {
  FixedLayoutDeviceDescriptor({
    @required sport,
    @required fourCC,
    @required vendorName,
    @required modelName,
    fullName = '',
    @required namePrefix,
    manufacturer,
    model,
    dataServiceId,
    dataCharacteristicId,
    canMeasureHeartRate,
    heartRateByteIndex,
    timeMetric,
    caloriesMetric,
    speedMetric,
    powerMetric,
    cadenceMetric,
    distanceMetric,
  }) : super(
          sport: sport,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          fullName: fullName,
          namePrefix: namePrefix,
          manufacturer: manufacturer,
          model: model,
          dataServiceId: dataServiceId,
          dataCharacteristicId: dataCharacteristicId,
          canMeasureHeartRate: canMeasureHeartRate,
          heartRateByteIndex: heartRateByteIndex,
          timeMetric: timeMetric,
          caloriesMetric: caloriesMetric,
          speedMetric: speedMetric,
          powerMetric: powerMetric,
          cadenceMetric: cadenceMetric,
          distanceMetric: distanceMetric,
        );

  @override
  Record stubRecord(List<int> data) {
    super.stubRecord(data);
    return Record(
      distance: getDistance(data),
      elapsed: getTime(data).toInt(),
      calories: getCalories(data).toInt(),
      power: getPower(data).toInt(),
      speed: getSpeed(data),
      cadence: getCadence(data).toInt(),
      heartRate: getHeartRate(data).toInt(),
    );
  }
}
