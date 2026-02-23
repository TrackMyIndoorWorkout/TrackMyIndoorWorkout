import '../../export/fit/fit_manufacturer.dart';
import '../device_fourcc.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import 'indoor_bike_device_descriptor.dart';

class CardiostrongIB50Descriptor extends IndoorBikeDeviceDescriptor {
  CardiostrongIB50Descriptor()
    : super(
        fourCC: cardiostrongIB50FourCC,
        vendorName: "CardioStrong",
        modelName: "IB50",
        manufacturerNamePart: "Unknown",
        manufacturerFitId: stravaFitId,
        model: "IB50",
      );

  @override
  CardiostrongIB50Descriptor clone() => CardiostrongIB50Descriptor();

  @override
  int processTotalDistanceFlag(int flag, {int numBytes = 3}) {
    if (flag % 2 == 1) {
      // CardioStrong IB50 reports distance in 10-meter units (decameters)
      // instead of standard meters. We use divider: 0.1 to multiply the raw value by 10.
      distanceMetric = ThreeByteMetricDescriptor(
        lsb: byteCounter,
        msb: byteCounter + numBytes - 1,
        divider: 0.1,
      );
      byteCounter += numBytes;
    }

    return advanceFlag(flag);
  }
}
