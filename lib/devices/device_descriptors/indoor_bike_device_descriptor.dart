import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../gatt_constants.dart';
import 'fitness_machine_descriptor.dart';

class IndoorBikeDeviceDescriptor extends FitnessMachineDescriptor {
  IndoorBikeDeviceDescriptor({
    required fourCC,
    required vendorName,
    required modelName,
    required namePrefixes,
    manufacturerPrefix,
    manufacturerFitId,
    model,
    dataServiceId = fitnessMachineUuid,
    dataCharacteristicId = indoorBikeUuid,
    canMeasureHeartRate = true,
    heartRateByteIndex,
    canMeasureCalories = true,
  }) : super(
          defaultSport: ActivityType.ride,
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
          canMeasureCalories: canMeasureCalories,
        );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.indoor_bike_data.xml
  @override
  void processFlag(int flag) {
    super.processFlag(flag);
    // Schwinn IC4, two flag bytes
    // 68 01000100 instant cadence, instant power
    //  2 00000010 heart rate
    // negated first bit!
    flag = processSpeedFlag(flag, true); // Instant
    flag = processSpeedFlag(flag, false); // Average (fallback)
    flag = processCadenceFlag(flag); // Instant
    flag = processCadenceFlag(flag); // Average (fallback)
    flag = processTotalDistanceFlag(flag);
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
  RecordWithSport? stubRecord(List<int> data) {
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
