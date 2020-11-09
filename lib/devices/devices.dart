import 'device_descriptor.dart';
import 'fixed_layout_device_descriptor.dart';
import 'gatt_standard_device_descriptor.dart';
import 'short_metric_descriptor.dart';

Map<String, DeviceDescriptor> deviceMap = {
  "PSCP": FixedLayoutDeviceDescriptor(
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
    equipmentTypeId: "e01f",
    equipmentStateId: "e01e",
    measurementService1Id: "ee07",
    measurement1Id: "e01d",
    heartRate: 5,
    canMeasurementProcessed: (List<int> data) {
      if (data.length != 19) return false;
      const measurementPrefix = [83, 89, 22];
      for (int i = 0; i < measurementPrefix.length; i++) {
        if (data[i] != measurementPrefix[i]) return false;
      }
      return true;
    },
    time: ShortMetricDescriptor(lsb: 3, msb: 4, divider: 1),
    calories: ShortMetricDescriptor(lsb: 13, msb: 14, divider: 1),
    speed: ShortMetricDescriptor(lsb: 6, msb: 7, divider: 100),
    power: ShortMetricDescriptor(lsb: 17, msb: 18, divider: 1),
    cadence: ShortMetricDescriptor(lsb: 8, msb: 9, divider: 10),
  ),
  "SIC4": GattStandardDeviceDescriptor(
    fourCC: "SIC4",
    vendorName: "Nautilus, Inc",
    modelName: "Schwinn IC4/IC8",
    namePrefix: "IC BIKE",
    nameStart: [73, 67, 32, 66, 111, 113, 105],
    // IC Bike
    manufacturer: [78, 97, 117, 116, 105, 108, 117, 115, 44, 32, 73, 110, 99],
    // Nautilus, Inc
    model: [73, 67, 32, 66, 73, 75, 69],
    // IC BIKE
    equipmentTypeId: "e01f",
    equipmentStateId: "e01e",
    measurementService1Id: "1826",
    measurement1Id: "2ad2",
    measurementService2Id: "1816",
    measurement2Id: "2a5b",
    heartRate: 8,
    canMeasurementProcessed: (List<int> data) {
      return true;
    },
    time: ShortMetricDescriptor(lsb: 3, msb: 4, divider: 1),
    calories: ShortMetricDescriptor(lsb: 13, msb: 14, divider: 1),
    speed: ShortMetricDescriptor(lsb: 6, msb: 7, divider: 100),
    power: ShortMetricDescriptor(lsb: 17, msb: 18, divider: 1),
    cadence: ShortMetricDescriptor(lsb: 8, msb: 9, divider: 10),
  ),
};
