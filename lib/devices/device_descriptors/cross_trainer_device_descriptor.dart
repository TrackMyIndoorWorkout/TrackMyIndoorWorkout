import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../gatt/gatt_constants.dart';
import 'fitness_machine_descriptor.dart';

class CrossTrainerDeviceDescriptor extends FitnessMachineDescriptor {
  CrossTrainerDeviceDescriptor({
    required fourCC,
    required vendorName,
    required modelName,
    required namePrefixes,
    manufacturerPrefix,
    manufacturerFitId,
    model,
    heartRateByteIndex,
  }) : super(
          defaultSport: ActivityType.elliptical,
          isMultiSport: false,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          namePrefixes: namePrefixes,
          manufacturerPrefix: manufacturerPrefix,
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
        namePrefixes: namePrefixes,
        manufacturerPrefix: manufacturerPrefix,
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
    flag = skipFlag(flag); // Resistance Level
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
      caloriesPerHour: getCaloriesPerHour(data),
      caloriesPerMinute: getCaloriesPerMinute(data),
    );
  }

  @override
  void stopWorkout() {}
}
