import '../../export/fit/fit_manufacturer.dart';
import '../device_fourcc.dart';
import 'treadmill_device_descriptor.dart';

class MatrixTreadmillDescriptor extends TreadmillDeviceDescriptor {
  MatrixTreadmillDescriptor()
    : super(
        fourCC: matrixTreadmillFourCC,
        vendorName: "Matrix",
        modelName: "Matrix Treadmill",
        manufacturerNamePart: "CTM",
        manufacturerFitId: johnsonHealthTechId,
        model: "Matrix Treadmill",
      );

  @override
  MatrixTreadmillDescriptor clone() => MatrixTreadmillDescriptor();

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.treadmill_data.xml
  @override
  void processFlag(int flag, int dataLength) {
    if (![31 * 256 + 158, 27 * 256 + 158].contains(flag) || dataLength != 20) {
      super.processFlag(flag, dataLength);
      return;
    }

    // Matrix violates the FTMS Treadmill protocol and promises every feature
    // except the Instantaneous Pace and Average Pace (C7 and C8)
    // Flag bytes:
    // 158  1001 1110
    // 31   0001 1111
    //
    // C1  uint16 (2 bytes) Instant Speed (negated bit 0 means present)
    // C2  uint16 (2 bytes) Avg Speed
    // C3  uint24 (3 bytes) Total Distance
    // C4  sint16 + sint16 (4 bytes) Inclination and Ramp Angle
    // C5  uint16 + uint16 (4 bytes) Positive and Negative Elevation Gain
    // C8  uint16 + uint16 + uint8 (5 bytes) total energy, energy per hour, energy per minute
    // C9  uint8  (1 byte) Heart rate
    // C10 uint8  (1 byte) Metabolic Equivalent
    // C11 uint16 (2 bytes) Elapsed Time
    // C12 uint16 (2 bytes) Remaining Time
    // C13 sint16 + sint16 (4 bytes) Force on Belt and Power Output
    //
    // There's only 20 bytes instead of 30
    // Instantaneous Speed, Avg Speed, Distance, Inclination, Positive Elevation Gain, Total Calories
    flag = processSpeedFlag(flag);
    flag = skipFlag(flag); // Average Speed
    flag = processTotalDistanceFlag(flag);
    flag = skipFlag(flag, size: 4); // Inclination and Ramp Angle
    flag = skipFlag(flag, size: 4); // Positive and Negative Elevation Gain
    flag = advanceFlag(flag); // Instantaneous Pace
    flag = advanceFlag(flag); // Average Pace
    flag = processExpandedEnergyFlag(flag, partial: true);
    flag = advanceFlag(flag); // Heart Rate
    flag = skipFlag(flag, size: 1); // Metabolic Equivalent
    flag = advanceFlag(flag); // Elapsed Time
    flag = advanceFlag(flag); // Remaining Time
    flag = advanceFlag(flag); // Force on Belt and Power
  }
}
