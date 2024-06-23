import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../devices/gadgets/life_fitness_mixin.dart';
import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/athlete.dart';
import '../device_fourcc.dart';
import 'indoor_bike_device_descriptor.dart';

class LifeFitnessBikeDescriptor extends IndoorBikeDeviceDescriptor with LifeFitnessMixin {
  LifeFitnessBikeDescriptor()
      : super(
          fourCC: lifeFitnessBikeFourCC,
          vendorName: LifeFitnessMixin.lfManufacturer,
          modelName: "${LifeFitnessMixin.lfManufacturer} Bike",
          manufacturerNamePart: LifeFitnessMixin.lfNamePrefix,
          manufacturerFitId: stravaFitId,
          model: "${LifeFitnessMixin.lfManufacturer} Bike",
        );

  @override
  LifeFitnessBikeDescriptor clone() => LifeFitnessBikeDescriptor();

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.indoor_bike_data.xml
  @override
  void processFlag(int flag, int dataLength) {
    if (!(flag == 9 * 256 + 250 && dataLength == 26 ||
        flag == 11 * 256 + 250 && dataLength == 27)) {
      super.processFlag(flag, dataLength);
      return;
    }

    // Life Fitness violates the FTMS Indoor Bike protocol
    // Flag bytes:
    // 250  1111 1010 instant speed, avg speed, avg cadence, distance, resistance level, instant power, avg power
    //   9  0000 1001 total energy, elapsed time
    //  11  0000 1011 total energy, heart rate, elapsed time
    //
    // Promised in theory:
    // C1  uint16 (2 bytes) Instant Speed (negated bit 0 means present)
    // C2  uint16 (2 bytes) Avg Speed
    // C4  uint16 (2 bytes) Avg Cadence
    // C5  uint24 (3 bytes) Total Distance
    // C6  sint16 (2 bytes) Resistance Level
    // C7  sint16 (2 bytes) Instantaneous Power
    // C8  sint16 (2 bytes) Average Power
    // C9  uint16 + uint16 + uint8 (5 bytes) total energy, energy per hour, energy per minute
    // C10 uint8 (1 byte) Heart Rate
    // C12 uint16 (2 bytes) Elapsed Time
    //
    // In reality:
    // C1  uint16 (2 bytes) Instant Speed (negated bit 0 means present)
    // C2  uint16 (2 bytes) Avg Speed
    // C3  uint16 (2 bytes) Instant Cadence
    // C4  uint16 (2 bytes) Avg Cadence
    // C5  uint24 (3 bytes) Total Distance
    // C6  sint16 (2 bytes) Resistance Level
    // C7  sint16 (2 bytes) Instantaneous Power
    // C8  sint16 (2 bytes) Average Power
    // C9  uint16 + uint16 + uint8 (5 bytes) total energy, energy per hour, energy per minute
    // C10 uint8 (1 byte) Heart Rate
    // C12 uint16 (2 bytes) Elapsed Time
    //
    // Instant & Avg Speed, Instant & Avg Cadence, Distance, Resistance, Instant & Avg Power, ?
    flag = processSpeedFlag(flag);
    flag = skipFlag(flag); // Average Speed
    flag = processCadenceFlag(flag, inverse: true);
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
  }

  @override
  Future<void> prePumpConfiguration(
      List<BluetoothService> svcs, Athlete athlete, int logLvl) async {
    await prePumpConfig(svcs, athlete, logLvl);
  }

  @override
  void stopWorkout() {
    return stopWorkoutExt();
  }
}
