import 'device_descriptor.dart';
import 'metric_descriptor.dart';

final devices = [
  DeviceDescriptor(
    vendorName: "Precor",
    modelName: "Spinning Power Chrono",
    sku: "SBK 869",
    namePrefix: "CHRONO",
    nameStart: [67, 72, 82, 79, 78, 79], // CHRONO
    manufacturer: [80, 114, 101, 99, 111, 114], // Precor
    model: [49], // 1
    measurementServiceId: "ee07",
    equipmentTypeId: "e01f",
    equipmentStateId: "e01e",
    measurementId: "e01d",
    byteCount: 19,
    measurementPrefix: [83, 89, 22],
    time: MetricDescriptor(lsb: 3, msb: 4, divider: 1),
    calories: MetricDescriptor(lsb: 13, msb: 14, divider: 1),
    speed: MetricDescriptor(lsb: 6, msb: 7, divider: 100),
    power: MetricDescriptor(lsb: 17, msb: 18, divider: 1),
    cadence: MetricDescriptor(lsb: 8, msb: 9, divider: 10),
    heartRate: 5,
  )
];
