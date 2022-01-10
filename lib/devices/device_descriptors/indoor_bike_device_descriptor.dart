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
    flag = processSpeedFlag(flag);
    flag = skipFlag(flag); // Average Speed
    flag = processCadenceFlag(flag);
    flag = skipFlag(flag); // Average Cadence
    flag = processTotalDistanceFlag(flag);
    flag = skipFlag(flag); // Resistance Level
    flag = processPowerFlag(flag);
    flag = skipFlag(flag); // Average Power
    flag = processExpandedEnergyFlag(flag);
    flag = processHeartRateFlag(flag);
    flag = skipFlag(flag, size: 1); // Metabolic Equivalent
    flag = processElapsedTimeFlag(flag);
    flag = skipFlag(flag); // Remaining Time
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
