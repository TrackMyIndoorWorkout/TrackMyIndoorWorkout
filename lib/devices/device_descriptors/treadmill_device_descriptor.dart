import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../gatt_constants.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'fitness_machine_descriptor.dart';

class TreadmillDeviceDescriptor extends FitnessMachineDescriptor {
  ByteMetricDescriptor? paceMetric;

  TreadmillDeviceDescriptor({
    required fourCC,
    required vendorName,
    required modelName,
    required namePrefixes,
    manufacturerPrefix,
    manufacturerFitId,
    model,
    dataServiceId = fitnessMachineUuid,
    dataCharacteristicId = treadmillUuid,
    canMeasureHeartRate = false,
    heartRateByteIndex,
  }) : super(
          defaultSport: ActivityType.run,
          isMultiSport: false,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          namePrefixes: namePrefixes,
          manufacturerPrefix: manufacturerPrefix,
          manufacturerFitId: manufacturerFitId,
          model: model,
          dataServiceId: dataServiceId,
          dataCharacteristicId: dataCharacteristicId,
          canMeasureHeartRate: canMeasureHeartRate,
          heartRateByteIndex: heartRateByteIndex,
        );

  @override
  TreadmillDeviceDescriptor clone() => TreadmillDeviceDescriptor(
        fourCC: fourCC,
        vendorName: vendorName,
        modelName: modelName,
        namePrefixes: namePrefixes,
        manufacturerPrefix: manufacturerPrefix,
        manufacturerFitId: manufacturerFitId,
        model: model,
        dataServiceId: dataServiceId,
        dataCharacteristicId: dataCharacteristicId,
        canMeasureHeartRate: canMeasureHeartRate,
        heartRateByteIndex: heartRateByteIndex,
      );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.treadmill_data.xml
  @override
  void processFlag(int flag) {
    super.processFlag(flag);
    // negated first bit!
    flag = processSpeedFlag(flag);
    flag = skipFlag(flag); // Average Speed
    flag = processTotalDistanceFlag(flag);
    flag = skipFlag(flag, size: 4); // Inclination and Ramp Angle
    flag = skipFlag(flag, size: 4); // Positive and Negative Elevation Gain
    flag = processPaceFlag(flag);
    flag = skipFlag(flag, size: 1); // Average Pace
    flag = processExpandedEnergyFlag(flag);
    flag = processHeartRateFlag(flag);
    flag = skipFlag(flag, size: 1); // Metabolic Equivalent
    flag = processElapsedTimeFlag(flag);
    flag = skipFlag(flag); // Remaining Time
    flag = processForceAndPowerFlag(flag);
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    double? speed = getSpeed(data);
    double? pace = getPace(data); // km / minute
    speed ??= (pace ?? 0.0) * 60.0; // km / h
    // Run pace is not really a pace (speed reciprocal) but it's km/min
    if (pace != null && pace > 0) {
      pace = 1 / pace; // now minutes / km
    }

    return RecordWithSport(
      distance: getDistance(data),
      elapsed: getTime(data)?.toInt(),
      calories: getCalories(data)?.toInt(),
      power: getPower(data)?.toInt(),
      speed: speed,
      heartRate: getHeartRate(data)?.toInt(),
      pace: pace,
      sport: defaultSport,
      caloriesPerHour: getCaloriesPerHour(data),
      caloriesPerMinute: getCaloriesPerMinute(data),
    );
  }

  @override
  void stopWorkout() {}

  int processPaceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt8, km/min with 0.1 resolution
      paceMetric = ByteMetricDescriptor(lsb: byteCounter, divider: 10.0);
      byteCounter += 1;
    }

    return advanceFlag(flag);
  }

  int processForceAndPowerFlag(int flag) {
    if (flag % 2 == 1) {
      byteCounter += 2; // Skip force on belt: SInt16, Newton
      // SInt16, Watts
      powerMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
    }

    return advanceFlag(flag);
  }

  double? getPace(List<int> data) {
    // Run pace is not really a pace (speed reciprocal) but it's km/min
    return paceMetric?.getMeasurementValue(data);
  }

  @override
  void clearMetrics() {
    super.clearMetrics();
    paceMetric = null;
  }
}
