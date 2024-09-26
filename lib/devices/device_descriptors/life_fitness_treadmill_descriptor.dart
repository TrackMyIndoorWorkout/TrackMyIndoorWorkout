import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../devices/gadgets/life_fitness_mixin.dart';
import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/athlete.dart';
import '../device_fourcc.dart';
import 'treadmill_device_descriptor.dart';

class LifeFitnessTreadmillDescriptor extends TreadmillDeviceDescriptor with LifeFitnessMixin {
  LifeFitnessTreadmillDescriptor()
      : super(
          fourCC: lifeFitnessTreadmillFourCC,
          vendorName: LifeFitnessMixin.lfManufacturer,
          modelName: "${LifeFitnessMixin.lfManufacturer} Treadmill",
          manufacturerNamePart: LifeFitnessMixin.lfNamePrefix,
          manufacturerFitId: stravaFitId,
          model: "${LifeFitnessMixin.lfManufacturer} Treadmill",
          doNotReadManufacturerName: true,
        );

  @override
  LifeFitnessTreadmillDescriptor clone() => LifeFitnessTreadmillDescriptor();

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.treadmill_data.xml
  @override
  void processFlag(int flag, int dataLength) {
    if (![31 * 256 + 158, 27 * 256 + 158].contains(flag) || dataLength != 20) {
      super.processFlag(flag, dataLength);
      return;
    }

    // Flag bytes:
    // 158  1001 1110
    //   4  0000 0101
    //   5  0000 0100
    //   c  0000 1100
    //
    // C1  uint16 (2 bytes) Instant Speed (negated bit 0 means present)
    // C2  uint16 (2 bytes) Avg Speed
    // C3  uint24 (3 bytes) Total Distance
    // C4  sint16 + sint16 (4 bytes) Inclination and Ramp Angle
    // C5  uint16 + uint16 (4 bytes) Positive and Negative Elevation Gain
    // C8  uint16 + uint16 + uint8 (5 bytes) total energy, energy per hour, energy per minute
    // C9  uint8  (1 byte) Heart rate
    // C11 uint16 (2 bytes) Elapsed Time
    // C12 uint16 (2 bytes) Remaining Time
    //
    // It's very close to the reality, except that there's just one sint16
    // (instead of two) at the place of Positive + Negative elevation gain.
    // Not even to mention that those are uint16s. And 0x7FFF is the marker
    // of invalid value for sint16 and not for uint16. That's where it gets
    // misaligned from the FTMS standard.
    flag = processSpeedFlag(flag);
    flag = skipFlag(flag); // Average Speed
    flag = processTotalDistanceFlag(flag);
    flag = skipFlag(flag, size: 4); // Inclination and Ramp Angle
    flag = skipFlag(flag,
        size: 2); // *** MISAIGNMENT: 2 instead of 4 for Positive and Negative Elevation Gain
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
  Future<void> prePumpConfiguration(
      List<BluetoothService> svcs, Athlete athlete, int logLvl) async {
    await prePumpConfig(svcs, athlete, logLvl);
  }

  @override
  void stopWorkout() {
    return stopWorkoutExt();
  }
}
