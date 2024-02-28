import '../../export/fit/fit_manufacturer.dart';
import '../device_fourcc.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import 'rower_device_descriptor.dart';

class MrCaptainDescriptor extends RowerDeviceDescriptor {
  MrCaptainDescriptor()
      : super(
          sport: deviceSportDescriptors[mrCaptainRowerFourCC]!.defaultSport,
          isMultiSport: deviceSportDescriptors[mrCaptainRowerFourCC]!.isMultiSport,
          fourCC: mrCaptainRowerFourCC,
          vendorName: "Mr Captain",
          modelName: "Rower",
          manufacturerNamePart: "XG",
          manufacturerFitId: stravaFitId,
          model: "000000",
        );

  @override
  MrCaptainDescriptor clone() => MrCaptainDescriptor();

  int processEffedUpExpandedEnergyFlag(int flag) {
    if (flag % 2 == 1) {
      caloriesPerMinuteMetric = ShortMetricDescriptor(
        lsb: byteCounter,
        msb: byteCounter + 1,
        optional: true,
      );
      // Energy / minute UInt8, but there are two bytes FFS
      byteCounter += 2;
      caloriesMetric = ShortMetricDescriptor(
        lsb: byteCounter,
        msb: byteCounter + 1,
        optional: true,
      );
      // Total Energy: UInt16
      byteCounter += 2;
      caloriesPerHourMetric = ShortMetricDescriptor(
        lsb: byteCounter,
        msb: byteCounter + 1,
        optional: true,
      );
      // Energy / hour UInt16
      byteCounter += 2;
    }

    return advanceFlag(flag);
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.treadmill_data.xml
  @override
  void processFlag(int flag, int dataLength) {
    if (![11 * 256 + 66, 11 * 256 + 60].contains(flag) || dataLength != 20) {
      super.processFlag(flag, dataLength);
      return;
    }

    // Mr Captain violates the FTMS Rower protocol several places f-ed up
    // Flag bytes:
    // 66  0011 1100
    // 11  0000 1011
    //
    // C1  uint8 (1 byte) Stroke Rate, spm, 0.5 (negated bit 0 means present)
    // C1  uint16 (2 bytes) Stroke Count (negated bit 0 means present)
    // C3  uint24 (3 bytes) Total Distance (m) 1
    // C4  uint16 (2 bytes) Pace (s) 1
    // C5  uint16 (2 bytes) Avg Pace
    // C6  sint16 (2 bytes) Instantaneous Power (W) 1
    // -
    // C9  uint16 (2 bytes) Total Energy (kcal) 1
    // C9  uint16 (2 bytes) Energy Per Hour (kcal/hr) 1
    // C9  uint8 (1 byte) Energy Per Minute (kcal/min) 1
    // C10 uint8 (1 byte) Heart Rate (bpm) 1
    // C12 uint16 (2 bytes) Elapsed Time (s) 1
    //
    // total length (1 + 2 + 3 + 2 + 2 + 2) + (2 + 2 + 1 + 1 + 2) = 12 + 8 = 20
    // There's only 18 bytes instead of 20:
    // 1. No Avg Pace present
    // 2. Energy Per Minute precedes Total Energy and it's two bytes
    // 3. Elapsed Time is f-ed up, goes up/down, just one byte
    flag = processStrokeRateFlag(flag, true);
    flag = skipFlag(flag); // Average Stroke Rate C2
    flag = processTotalDistanceFlag(flag);
    flag = processPaceFlag(flag);
    flag = advanceFlag(flag); // Average Pace C5
    flag = processPowerFlag(flag);
    flag = skipFlag(flag); // Average Power - advanceFlag ?
    flag = processResistanceFlag(flag);
    flag = processEffedUpExpandedEnergyFlag(flag); // Mixed up, f-ed up
    flag = skipFlag(flag, size: 1); // Elapsed Time, should be 2 bytes, but it's f-ed up single byte
    // flag = skipFlag(flag, size: 1); // Metabolic Equivalent
    flag = skipFlag(flag); // Remaining Time
    flag = processHeartRateFlag(flag); // HR, should come out to 19, last byte
  }
}
