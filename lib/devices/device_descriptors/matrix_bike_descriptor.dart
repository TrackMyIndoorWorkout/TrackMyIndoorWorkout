import '../../export/fit/fit_manufacturer.dart';
import '../device_map.dart';
import 'indoor_bike_device_descriptor.dart';

class MatrixBikeDescriptor extends IndoorBikeDeviceDescriptor {
  MatrixBikeDescriptor()
      : super(
          fourCC: matrixBikeFourCC,
          vendorName: "Matrix",
          modelName: "Matrix Bike",
          namePrefixes: ["CTM", "Johnson", "Matrix"],
          manufacturerPrefix: "Johnson Health Tech",
          manufacturerFitId: johnsonHealthTechId,
          model: "Matrix Bike",
          canMeasureHeartRate: false,
        );

  @override
  MatrixBikeDescriptor spawn() {
    return MatrixBikeDescriptor();
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.treadmill_data.xml
  @override
  void processFlag(int flag) {
    initFlag();
    // Matrix violates the FTMS Indoor Bike protocol and promises every feature
    // except the Heart Rate (C10)
    // Flag bytes:
    // 254  1111 1110
    // 29   0001 1101
    //
    // C1  uint16 (2 bytes) Instant Speed (negated bit 0 means present)
    // C2  uint16 (2 bytes) Avg Speed
    // C3  uint16 (2 bytes) Instant Cadence
    // C4  uint16 (2 bytes) Avg Cadence
    // C5  uint24 (3 bytes) Total Distance
    // C6  sint16 (2 bytes) Resistance Level
    // C7  sint16 (2 bytes) Instantaneous Power
    // C8  sint16 (2 bytes) Average Power
    // C9  uint16 + uint16 + uint8 (5 bytes) total energy, energy per hour, energy per minute
    // C11 uint8 (1 byte) Metabolic Equivalent
    // C12 uint16 (2 bytes) Elapsed Time
    // C13 uint16 (2 bytes) Remaining Time
    //
    // There's only 20 bytes instead of 29
    // Instant & Avg Speed, Instant & Avg Cadence, Distance, Resistance, Instant & Avg Power, ?
    flag = processSpeedFlag(flag);
    flag = skipFlag(flag); // Average Speed
    flag = processCadenceFlag(flag);
    flag = skipFlag(flag); // Average Cadence
    flag = processTotalDistanceFlag(flag);
    flag = skipFlag(flag); // Resistance Level
    flag = processPowerFlag(flag);
    flag = skipFlag(flag); // Average Power
    flag = advanceFlag(flag); // Expanded Energy
    flag = advanceFlag(flag); // Heart Rate
    flag = skipFlag(flag, size: 1); // Metabolic Equivalent
    flag = advanceFlag(flag); // Elapsed Time
    flag = advanceFlag(flag); // Remaining Time
  }
}
