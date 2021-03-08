import '../tcx/activity_type.dart';
import 'device_descriptor.dart';
import 'fixed_layout_device_descriptor.dart';
import 'gatt_constants.dart';
import 'indoor_bike_device_descriptor.dart';
import 'rower_device_descriptor.dart';
import 'short_metric_descriptor.dart';
import 'three_byte_metric_descriptor.dart';

Map<String, DeviceDescriptor> deviceMap = {
  "PSCP": FixedLayoutDeviceDescriptor(
    sport: ActivityType.Ride,
    fourCC: "PSCP",
    vendorName: "Precor",
    modelName: "Spinner Chrono Power",
    namePrefix: "CHRONO",
    manufacturer: "Precor",
    model: "1",
    primaryServiceId: PRECOR_SERVICE_ID,
    primaryMeasurementId: PRECOR_MEASUREMENT_ID,
    canPrimaryMeasurementProcessed: (List<int> data) {
      if (data == null) return false;
      if (data.length != 19) return false;
      const measurementPrefix = [83, 89, 22];
      for (int i = 0; i < measurementPrefix.length; i++) {
        if (data[i] != measurementPrefix[i]) return false;
      }
      return true;
    },
    heartRateByteIndex: 5,
    timeMetric: ShortMetricDescriptor(lsb: 3, msb: 4),
    caloriesMetric: ShortMetricDescriptor(lsb: 13, msb: 14),
    speedMetric: ShortMetricDescriptor(lsb: 6, msb: 7, divider: 100.0),
    powerMetric: ShortMetricDescriptor(lsb: 17, msb: 18),
    cadenceMetric: ShortMetricDescriptor(lsb: 8, msb: 9, divider: 10.0),
    distanceMetric: ThreeByteMetricDescriptor(lsb: 10, msb: 12),
  ),
  "SIC4": IndoorBikeDeviceDescriptor(
    sport: ActivityType.Ride,
    fourCC: "SIC4",
    vendorName: "Nautilus, Inc",
    modelName: "Schwinn IC4/IC8",
    namePrefix: "IC Bike",
    manufacturer: "Nautilus, Inc",
    model: "IC BIKE",
    canPrimaryMeasurementProcessed: (List<int> data) {
      return (data?.length ?? 0) > 1;
    },
    calorieFactor: 1.40,
  ),
  "SAP+": IndoorBikeDeviceDescriptor(
    sport: ActivityType.Ride,
    fourCC: "SAP+",
    vendorName: "Schwinn",
    modelName: "AC Performance Plus",
    // is an ANT+ device, will never show as BLE
    namePrefix: "Schwinn AC Perf+",
    primaryServiceId: null,
    primaryMeasurementId: null,
    canPrimaryMeasurementProcessed: (List<int> data) {
      return false;
    },
    calorieFactor: 3.9,
  ),
  "KPro": RowerDeviceDescriptor(
    sport: ActivityType.Kayaking,
    fourCC: "KPro",
    vendorName: "KayakPro",
    modelName: "KayakPro Compact",
    namePrefix: "KayakPro",
    manufacturer: "North Pole Engineering Inc.",
    model: "64",
    // Rower Data
    canPrimaryMeasurementProcessed: (List<int> data) {
      return (data?.length ?? 0) > 1;
    },
    canMeasureHeartRate: false,
  ),
};
