import 'package:flutter_blue/flutter_blue.dart';

import 'fixed_layout_device_descriptor.dart';
import 'metric_descriptor.dart';

final withServices = [Guid('a026ee07-0a7d-4ab3-97fa-f1500f9feb8b')];

final devices = [
  FixedLayoutDeviceDescriptor(
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
    heartRate: 5,
    canMeasurementProcessed: (List<int> data) {
      if (data.length != 19) return false;
      const measurementPrefix = [83, 89, 22];
      for (int i = 0; i < measurementPrefix.length; i++) {
        if (data[i] != measurementPrefix[i]) return false;
      }
      return true;
    },
    time: MetricDescriptor(lsb: 3, msb: 4, divider: 1),
    calories: MetricDescriptor(lsb: 13, msb: 14, divider: 1),
    speed: MetricDescriptor(lsb: 6, msb: 7, divider: 100),
    power: MetricDescriptor(lsb: 17, msb: 18, divider: 1),
    cadence: MetricDescriptor(lsb: 8, msb: 9, divider: 10),
  ),
];
