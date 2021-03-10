import '../tcx/activity_type.dart';
import 'device_descriptor.dart';
import 'indoor_bike_device_descriptor.dart';
import 'precor_spinner_chrono_power.dart';
import 'rower_device_descriptor.dart';
import 'schwinn_ac_performance_plus.dart';

Map<String, DeviceDescriptor> deviceMap = {
  "PSCP": PrecorSpinnerChronoPower(),
  "SIC4": IndoorBikeDeviceDescriptor(
    sport: ActivityType.Ride,
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
    sport: ActivityType.Kayaking,
    fourCC: "KPro",
    vendorName: "KayakPro",
    modelName: "KayakPro Compact",
    namePrefix: "KayakPro",
    manufacturer: "North Pole Engineering Inc.",
    model: "64",
    canMeasureHeartRate: false,
  ),
};
