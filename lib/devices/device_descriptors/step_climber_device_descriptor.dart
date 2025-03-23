import '../../devices/device_fourcc.dart';
import '../../persistence/record.dart';
import '../gatt/ftms.dart';
import 'fitness_machine_descriptor.dart';

class StepClimberDeviceDescriptor extends FitnessMachineDescriptor {
  StepClimberDeviceDescriptor({
    required super.fourCC,
    required super.vendorName,
    required super.modelName,
    required super.manufacturerNamePart,
    required super.manufacturerFitId,
    required super.model,
    super.heartRateByteIndex,
    super.doNotReadManufacturerName,
  }) : super(
         sport: deviceSportDescriptors[genericFTMSStepClimberFourCC]!.defaultSport,
         isMultiSport: deviceSportDescriptors[genericFTMSStepClimberFourCC]!.isMultiSport,
         dataServiceId: fitnessMachineUuid,
         dataCharacteristicId: stepClimberUuid,
         flagByteSize: 2,
       );

  @override
  StepClimberDeviceDescriptor clone() => StepClimberDeviceDescriptor(
    fourCC: fourCC,
    vendorName: vendorName,
    modelName: modelName,
    manufacturerNamePart: manufacturerNamePart,
    manufacturerFitId: manufacturerFitId,
    model: model,
    heartRateByteIndex: heartRateByteIndex,
  );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.step_climber_data.xml
  @override
  void processFlag(int flag, int dataLength) {
    flag = processStrideCountFlag(flag, inverse: true, skipBytes: 2); // Floors and Step Count
    flag = processCadenceFlag(flag, divider: 1.0); // Steps / min
    flag = skipFlag(flag); // Average step rate
    flag = processTotalDistanceFlag(flag, numBytes: 2); // Pos elevation gain
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
    final cadence = getCadence(data);
    return RecordWithSport(
      distance: getDistance(data),
      elapsed: getTime(data)?.toInt(),
      calories: getCalories(data)?.toInt(),
      cadence: cadence?.toInt(),
      heartRate: getHeartRate(data),
      sport: sport,
      caloriesPerHour: getCaloriesPerHour(data),
      caloriesPerMinute: getCaloriesPerMinute(data),
      preciseCadence: cadence,
      strokeCount: getStrokeCount(data),
    );
  }

  @override
  void stopWorkout() {}
}
