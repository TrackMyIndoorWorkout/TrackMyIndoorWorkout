import '../../export/fit/fit_manufacturer.dart';
import '../../utils/constants.dart';
import '../device_map.dart';
import '../gatt_constants.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import 'fixed_layout_device_descriptor.dart';

class SchwinnX70 extends FixedLayoutDeviceDescriptor {
  SchwinnX70()
      : super(
          defaultSport: ActivityType.ride,
          isMultiSport: false,
          fourCC: schwinnX70BikeFourCC,
          vendorName: "Schwinn",
          modelName: "SCHWINN 170/270",
          namePrefixes: ["SCHWINN 170", "SCHWINN 270", "SCHWINN 570"],
          manufacturerPrefix: "Nautilus",
          manufacturerFitId: nautilusFitId,
          model: "1",
          dataServiceId: schwinnX70ServiceUuid,
          dataCharacteristicId: schwinnX70MeasurementUuid,
          canMeasureHeartRate: true,
          heartRateByteIndex: 5,
          timeMetric: ShortMetricDescriptor(lsb: 3, msb: 4),
          caloriesMetric: ShortMetricDescriptor(lsb: 13, msb: 14),
          speedMetric: ShortMetricDescriptor(lsb: 6, msb: 7, divider: 100.0),
          powerMetric: ShortMetricDescriptor(lsb: 17, msb: 18),
          cadenceMetric: ShortMetricDescriptor(lsb: 8, msb: 9, divider: 10.0),
          distanceMetric: ThreeByteMetricDescriptor(lsb: 10, msb: 12),
        );

  @override
  SchwinnX70 clone() => SchwinnX70();

  @override
  bool isDataProcessable(List<int> data) {
    if (data.length != 17) return false;

    const measurementPrefix = [17, 32, 0];
    for (int i = 0; i < measurementPrefix.length; i++) {
      if (data[i] != measurementPrefix[i]) return false;
    }
    return true;
  }

  @override
  void stopWorkout() {}
}
