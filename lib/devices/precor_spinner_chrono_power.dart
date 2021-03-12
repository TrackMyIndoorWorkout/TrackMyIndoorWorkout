import '../tcx/activity_type.dart';
import 'fixed_layout_device_descriptor.dart';
import 'gatt_constants.dart';
import 'short_metric_descriptor.dart';
import 'three_byte_metric_descriptor.dart';

class PrecorSpinnerChronoPower extends FixedLayoutDeviceDescriptor {
  PrecorSpinnerChronoPower()
      : super(
          sport: ActivityType.Ride,
          fourCC: "PSCP",
          vendorName: "Precor",
          modelName: "Spinner Chrono Power",
          fullName: '',
          namePrefix: "CHRONO",
          manufacturer: "Precor",
          model: "1",
          primaryServiceId: PRECOR_SERVICE_ID,
          primaryMeasurementId: PRECOR_MEASUREMENT_ID,
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
  bool canPrimaryMeasurementProcessed(List<int> data) {
    if (data == null) return false;

    if (data.length != 19) return false;

    const measurementPrefix = [83, 89, 22];
    for (int i = 0; i < measurementPrefix.length; i++) {
      if (data[i] != measurementPrefix[i]) return false;
    }
    return true;
  }
}
