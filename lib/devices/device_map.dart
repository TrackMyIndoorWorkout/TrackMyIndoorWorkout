import '../tcx/activity_type.dart';
import 'device_descriptors/device_descriptor.dart';
import 'device_descriptors/indoor_bike_device_descriptor.dart';
import 'device_descriptors/precor_spinner_chrono_power.dart';
import 'device_descriptors/rower_device_descriptor.dart';
import 'device_descriptors/schwinn_ac_performance_plus.dart';

Map<String, DeviceDescriptor> deviceMap = {
  "PSCP": PrecorSpinnerChronoPower(),
  "SIC4": IndoorBikeDeviceDescriptor(
    fourCC: "SIC4",
    vendorName: "Nautilus, Inc",
    modelName: "Schwinn IC4/IC8",
    namePrefix: "IC Bike",
    manufacturer: "Nautilus, Inc",
    model: "IC BIKE",
    calorieFactor: 1.40,
  ),
  "SAP+": SchwinnACPerformancePlus(),
  "KPro": RowerDeviceDescriptor(
    defaultSport: ActivityType.Kayaking,
    fourCC: "KPro",
    vendorName: "KayakPro",
    modelName: "KayakPro Compact",
    namePrefix: "KayakPro",
    manufacturer: "North Pole Engineering Inc.",
    model: "64",
    canMeasureHeartRate: false,
  ),
};
