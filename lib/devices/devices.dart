import '../tcx/activity_type.dart';
import 'device_descriptor.dart';
import 'fixed_layout_device_descriptor.dart';
import 'gatt_standard_device_descriptor.dart';
import 'short_metric_descriptor.dart';
import 'three_byte_metric_descriptor.dart';

Map<String, DeviceDescriptor> deviceMap = {
  "PSCP": FixedLayoutDeviceDescriptor(
    sport: ActivityType.VirtualRide,
    fourCC: "PSCP",
    vendorName: "Precor",
    modelName: "Spinner Chrono Power",
    namePrefix: "CHRONO",
    nameStart: [67, 72, 82, 79, 78, 79],
    // CHRONO
    manufacturer: [80, 114, 101, 99, 111, 114],
    // Precor
    model: [49],
    // 1
    primaryMeasurementServiceId: "ee07",
    primaryMeasurementId: "e01d",
    canPrimaryMeasurementProcessed: (List<int> data) {
      if (data == null) return false;
      if (data.length != 19) return false;
      const measurementPrefix = [83, 89, 22];
      for (int i = 0; i < measurementPrefix.length; i++) {
        if (data[i] != measurementPrefix[i]) return false;
      }
      return true;
    },
    heartRate: 5,
    timeMetric: ShortMetricDescriptor(lsb: 3, msb: 4, divider: 1.0),
    caloriesMetric: ShortMetricDescriptor(lsb: 13, msb: 14, divider: 1.0),
    speedMetric: ShortMetricDescriptor(lsb: 6, msb: 7, divider: 100.0),
    powerMetric: ShortMetricDescriptor(lsb: 17, msb: 18, divider: 1.0),
    cadenceMetric: ShortMetricDescriptor(lsb: 8, msb: 9, divider: 10.0),
    distanceMetric: ThreeByteMetricDescriptor(lsb: 10, msb: 12, divider: 1.0),
  ),
  "SIC4": GattStandardDeviceDescriptor(
    sport: ActivityType.VirtualRide,
    fourCC: "SIC4",
    vendorName: "Nautilus, Inc",
    modelName: "Schwinn IC4/IC8",
    namePrefix: "IC Bike",
    nameStart: [73, 67, 32, 66, 111, 113, 105],
    // IC Bike
    manufacturer: [78, 97, 117, 116, 105, 108, 117, 115, 44, 32, 73, 110, 99],
    // Nautilus, Inc
    model: [73, 67, 32, 66, 73, 75, 69],
    // IC BIKE
    primaryMeasurementServiceId: "1826",
    primaryMeasurementId: "2ad2",
    canPrimaryMeasurementProcessed: (List<int> data) {
      return data != null && data.length > 1;
    },
    // cadenceMeasurementServiceId: "1816",
    // cadenceMeasurementId: "2a5b",
    canCadenceMeasurementProcessed: (List<int> data) {
      if (data == null || data.length < 1) return false;

      var flag = data[0];
      var expectedLength = 1; // The flag
      // Has wheel revolution? (first bit)
      if (flag % 2 == 1) {
        expectedLength += 6; // 32 bit revolution and 16 bit time
      }
      flag ~/= 2;
      // Has crank revolution? (second bit)
      if (flag % 2 == 1) {
        expectedLength += 4; // 16 bit revolution and 16 bit time
      }
      return data.length == expectedLength;
    },
    calorieFactor: 1.40,
  ),
  "SAP+": GattStandardDeviceDescriptor(
    sport: ActivityType.VirtualRide,
    fourCC: "SAP+",
    vendorName: "Schwinn",
    modelName: "AC Performance Plus",
    // is an ANT+ device, will never show as BLE
    namePrefix: "Schwinn AC Perf+",
    canPrimaryMeasurementProcessed: (List<int> data) {
      return false;
    },
    calorieFactor: 3.9,
  ),
  "KPro": GattStandardDeviceDescriptor(
    sport: ActivityType.Kayaking,
    fourCC: "KPro",
    vendorName: "KayakPro",
    modelName: "KayakPro Compact",
    namePrefix: "KayakPro",
    canPrimaryMeasurementProcessed: (List<int> data) {
      return true;
    },
  ),
};
