import '../../devices/device_fourcc.dart';
import '../../persistence/isar/record.dart';
import '../gatt/ftms.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'fitness_machine_descriptor.dart';

class CrossTrainerDeviceDescriptor extends FitnessMachineDescriptor {
  CrossTrainerDeviceDescriptor({
    required fourCC,
    required vendorName,
    required modelName,
    manufacturerNamePart,
    manufacturerFitId,
    model,
    heartRateByteIndex,
  }) : super(
          sport: deviceSportDescriptors[genericFTMSCrossTrainerFourCC]!.defaultSport,
          isMultiSport: deviceSportDescriptors[genericFTMSCrossTrainerFourCC]!.isMultiSport,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          manufacturerNamePart: manufacturerNamePart,
          manufacturerFitId: manufacturerFitId,
          model: model,
          dataServiceId: fitnessMachineUuid,
          dataCharacteristicId: crossTrainerUuid,
          flagByteSize: 3,
          heartRateByteIndex: heartRateByteIndex,
        );

  @override
  CrossTrainerDeviceDescriptor clone() => CrossTrainerDeviceDescriptor(
        fourCC: fourCC,
        vendorName: vendorName,
        modelName: modelName,
        manufacturerNamePart: manufacturerNamePart,
        manufacturerFitId: manufacturerFitId,
        model: model,
        heartRateByteIndex: heartRateByteIndex,
      );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.cross_trainer_data.xml
  @override
  void processFlag(int flag) {
    // LifePro FlexStride Pro
    // 12 0000 1100 instant speed, total distance, cadence (step rate)
    // 33 0010 0001 instant power, elapsed time
    // negated first bit!
    flag = processSpeedFlag(flag);
    flag = skipFlag(flag); // Average Speed
    flag = processTotalDistanceFlag(flag);
    flag = processStepMetricsFlag(flag);
    flag = skipFlag(flag); // Stride Count
    flag = skipFlag(flag, size: 4); // Positive and Negative Elevation Gain
    flag = skipFlag(flag, size: 4); // Inclination and Ramp Angle
    flag = processResistanceFlag(flag);
    flag = processPowerFlag(flag);
    flag = skipFlag(flag); // Average Power
    flag = processExpandedEnergyFlag(flag);
    flag = processHeartRateFlag(flag);
    flag = skipFlag(flag, size: 1); // Metabolic Equivalent
    flag = processElapsedTimeFlag(flag);
    flag = skipFlag(flag); // Remaining Time

    // #320 The Reserved flag is set
    hasFutureReservedBytes = flag > 0;
  }

  @override
  int processResistanceFlag(int flag) {
    if (flag % 2 == 1) {
      // SInt16
      resistanceMetric =
          ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1, divider: 10.0);
      byteCounter += 2;
    }

    return advanceFlag(flag);
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
      sport: sport,
      caloriesPerHour: getCaloriesPerHour(data),
      caloriesPerMinute: getCaloriesPerMinute(data),
      resistance: getResistance(data),
    );
  }

  @override
  void stopWorkout() {}
}
