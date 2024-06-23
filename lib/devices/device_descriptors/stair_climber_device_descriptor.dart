import '../../devices/device_fourcc.dart';
import '../../persistence/isar/record.dart';
import '../gatt/ftms.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'fitness_machine_descriptor.dart';

class StairClimberDeviceDescriptor extends FitnessMachineDescriptor {
  StairClimberDeviceDescriptor({
    required super.fourCC,
    required super.vendorName,
    required super.modelName,
    required super.manufacturerNamePart,
    required super.manufacturerFitId,
    required super.model,
    super.heartRateByteIndex,
  }) : super(
          sport: deviceSportDescriptors[genericFTMSClimberFourCC]!.defaultSport,
          isMultiSport: deviceSportDescriptors[genericFTMSClimberFourCC]!.isMultiSport,
          dataServiceId: fitnessMachineUuid,
          dataCharacteristicId: stairClimberUuid,
          flagByteSize: 2,
        );

  @override
  StairClimberDeviceDescriptor clone() => StairClimberDeviceDescriptor(
        fourCC: fourCC,
        vendorName: vendorName,
        modelName: modelName,
        manufacturerNamePart: manufacturerNamePart,
        manufacturerFitId: manufacturerFitId,
        model: model,
        heartRateByteIndex: heartRateByteIndex,
      );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.stair_climber_data.xml
  @override
  void processFlag(int flag, int dataLength) {
    // LifePro FlexStride Pro
    // 7e 0111 1110 Floors, Step/min, Avg. Step Rate, Pos. Elev. Gain, Stride Count, Total Enery (kCal) + (Energy / hr + Energy / min), Heart rate
    // 01 0000 0001 Elapsed Time (sec)
    // negated first bit!
    flag = skipFlag(flag, inverse: true); // Floors
    flag = processCadenceFlag(flag, divider: 1.0); // Steps / min
    flag = skipFlag(flag); // Average step rate
    flag = processTotalDistanceFlag(flag); // Pos elevation gain
    flag = processStrideCountFlag(flag);
    flag = processExpandedEnergyFlag(flag);
    flag = processHeartRateFlag(flag);
    flag = skipFlag(flag, size: 1); // Metabolic Equivalent
    flag = processElapsedTimeFlag(flag);
    flag = skipFlag(flag); // Remaining Time

    // #320 The Reserved flag is set
    hasFutureReservedBytes = flag > 0;
  }

  @override
  int processTotalDistanceFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16, meters
      distanceMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
    }

    return advanceFlag(flag);
  }

  int processStrideCountFlag(int flag) {
    if (flag % 2 == 1) {
      // UInt16
      strokeCountMetric = ShortMetricDescriptor(lsb: byteCounter, msb: byteCounter + 1);
      byteCounter += 2;
    }

    return advanceFlag(flag);
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
