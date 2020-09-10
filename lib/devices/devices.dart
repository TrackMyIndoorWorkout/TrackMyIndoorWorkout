import 'package:flutter_blue/flutter_blue.dart';
import 'device_descriptor.dart';
import 'metric_descriptor.dart';

final devices = [
  DeviceDescriptor(
      fullName: "Precor Spinning Power Chrono",
      namePrefix: "CHRONO",
      nameStart: [67, 72, 82, 79, 78, 79], // CHRONO
      manufacturer: [80, 114, 101, 99, 111, 114], // Precor
      model: [49], // 1
      measurementServiceGuid: Guid("a026ee07-0a7d-4ab3-97fa-f1500f9feb8b"),
      equipmentTypeGuid: Guid("a026e01f-0a7d-4ab3-97fa-f1500f9feb8b"),
      equipmentStateGuid: Guid("a026e01e-0a7d-4ab3-97fa-f1500f9feb8b"),
      measurementGuid: Guid("a026e01d-0a7d-4ab3-97fa-f1500f9feb8b"),
      byteCount: 19,
      measurementPrefix: [83, 89, 22],
      time: MetricDescriptor(lsb: 3, msb: 4, divider: 1),
      calories: MetricDescriptor(lsb: 13, msb: 14, divider: 1),
      speed: MetricDescriptor(lsb: 6, msb: 7, divider: 100),
      power: MetricDescriptor(lsb: 17, msb: 18, divider: 1),
      cadence: MetricDescriptor(lsb: 8, msb: 9, divider: 10),
      heartRate: 5)
];
