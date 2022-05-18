import '../../export/fit/fit_manufacturer.dart';
import '../../utils/constants.dart';
import '../device_map.dart';
import '../gatt_constants.dart';
import '../metric_descriptors/six_byte_metric_descriptor.dart';
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
          manufacturerPrefix: "Nautilus", // "SCHWINN 170/270"
          manufacturerFitId: nautilusFitId,
          model: "",
          dataServiceId: schwinnX70ServiceUuid,
          dataCharacteristicId: schwinnX70MeasurementUuid,
          canMeasureHeartRate: false,
          timeMetric: ShortMetricDescriptor(lsb: 3, msb: 4, divider: 1024.0),
          caloriesMetric: SixByteMetricDescriptor(lsb: 10, msb: 15, divider: 256.0),
          cadenceMetric: ThreeByteMetricDescriptor(lsb: 4, msb: 6, divider: 1.0),
          // TODO: resistance level metric for power calculations
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

  @override
  double? getCadence(List<int> data) {
    // TODO: convert from revolution to cadence
    return cadenceMetric?.getMeasurementValue(data);
  }
}
