import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../gatt_constants.dart';
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
    dataServiceId = FITNESS_MACHINE_ID,
    dataCharacteristicId = CROSS_TRAINER_ID,
    canMeasureHeartRate = true,
    heartRateByteIndex,
    calorieFactorDefault = 1.0,
  }) : super(
          defaultSport: ActivityType.Elliptical,
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
          calorieFactorDefault: calorieFactorDefault,
        );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.cross_trainer_data.xml
  @override
  void processFlag(int flag) {
    super.processFlag(flag);
    // negated first bit!
    flag = processSpeedFlag(flag, true); // Instant
    flag = processSpeedFlag(flag, false); // Average (fallback)
    flag = processTotalDistanceFlag(flag);
    flag = processStepMetricsFlag(flag);
    flag = processStrideCountFlag(flag);
    flag = processElevationGainMetricsFlag(flag);
    flag = processInclinationAndRampAngleFlag(flag);
    flag = processResistanceLevelFlag(flag);
    flag = processPowerFlag(flag); // Instant
    flag = processPowerFlag(flag); // Average (fallback)
    flag = processExpandedEnergyFlag(flag);
    flag = processHeartRateFlag(flag);
    flag = processMetabolicEquivalentFlag(flag);
    flag = processElapsedTimeFlag(flag);
    flag = processRemainingTimeFlag(flag);
  }

  @override
  RecordWithSport stubRecord(List<int> data) {
    super.stubRecord(data);
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
