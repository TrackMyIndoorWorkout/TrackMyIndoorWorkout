import '../../devices/device_fourcc.dart';
import '../../persistence/isar/record.dart';
import '../gatt/ftms.dart';
import 'fitness_machine_descriptor.dart';

class IndoorBikeDeviceDescriptor extends FitnessMachineDescriptor {
  IndoorBikeDeviceDescriptor({
    required fourCC,
    required vendorName,
    required modelName,
    manufacturerNamePart,
    manufacturerFitId,
    model,
    heartRateByteIndex,
    canMeasureCalories = true,
  }) : super(
          sport: deviceSportDescriptors[genericFTMSBikeFourCC]!.defaultSport,
          isMultiSport: deviceSportDescriptors[genericFTMSBikeFourCC]!.isMultiSport,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          manufacturerNamePart: manufacturerNamePart,
          manufacturerFitId: manufacturerFitId,
          model: model,
          dataServiceId: fitnessMachineUuid,
          dataCharacteristicId: indoorBikeUuid,
          heartRateByteIndex: heartRateByteIndex,
          canMeasureCalories: canMeasureCalories,
        );

  @override
  IndoorBikeDeviceDescriptor clone() => IndoorBikeDeviceDescriptor(
        fourCC: fourCC,
        vendorName: vendorName,
        modelName: modelName,
        manufacturerNamePart: manufacturerNamePart,
        manufacturerFitId: manufacturerFitId,
        model: model,
        heartRateByteIndex: heartRateByteIndex,
        canMeasureCalories: canMeasureCalories,
      );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.indoor_bike_data.xml
  @override
  void processFlag(int flag) {
    // Schwinn IC4
    // 68 0100 0100 instant cadence, instant power
    //  2 0000 0010 heart rate
    // negated first bit!
    flag = processSpeedFlag(flag);
    flag = skipFlag(flag); // Average Speed
    flag = processCadenceFlag(flag);
    flag = skipFlag(flag); // Average Cadence
    flag = processTotalDistanceFlag(flag);
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
