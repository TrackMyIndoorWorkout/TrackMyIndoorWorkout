import '../export/fit/fit_manufacturer.dart';
import '../utils/constants.dart';
import 'device_descriptors/device_descriptor.dart';
import 'device_descriptors/indoor_bike_device_descriptor.dart';
import 'device_descriptors/precor_spinner_chrono_power.dart';
import 'device_descriptors/rower_device_descriptor.dart';
import 'device_descriptors/schwinn_ac_performance_plus.dart';

const MPOWER_IMPORT_DEVICE_ID = 'MPowerImport';

Map<String, DeviceDescriptor> deviceMap = {
  "PSCP": PrecorSpinnerChronoPower(),
  "SIC4": IndoorBikeDeviceDescriptor(
    fourCC: "SIC4",
    vendorName: "Nautilus, Inc",
    modelName: "Schwinn IC4/IC8",
    namePrefix: "IC Bike",
    manufacturer: "Nautilus, Inc",
    manufacturerFitId: NAUTILUS_FIT_ID,
    model: "IC BIKE",
    calorieFactorDefault: 1.40,
  ),
  "SAP+": SchwinnACPerformancePlus(),
  "KPro": RowerDeviceDescriptor(
    defaultSport: ActivityType.Kayaking,
    fourCC: "KPro",
    vendorName: "KayakPro",
    modelName: "KayakPro Compact",
    namePrefix: "KayakPro",
    manufacturer: "North Pole Engineering Inc.",
    manufacturerFitId: NORTH_POLE_ENGINEERING_FIT_ID,
    model: "64",
    canMeasureHeartRate: false,
  ),
  "GRid": IndoorBikeDeviceDescriptor(
    fourCC: "GRid",
    vendorName: "Unknown",
    modelName: "FTMS Indoor Bike",
    namePrefix: "FTMS Bike",
    manufacturer: "Unknown",
    manufacturerFitId: STRAVA_FIT_ID,
    model: "FTMS Indoor Bike",
  ),
  "GKay": RowerDeviceDescriptor(
    defaultSport: ActivityType.Kayaking,
    isMultiSport: false,
    fourCC: "GKay",
    vendorName: "Unknown",
    modelName: "FTMS Kayak Ergometer",
    namePrefix: "FTMS Kayak",
    manufacturer: "Unknown",
    manufacturerFitId: STRAVA_FIT_ID,
    model: "FTMS Kayak Ergometer",
  ),
  "GCan": RowerDeviceDescriptor(
    defaultSport: ActivityType.Canoeing,
    isMultiSport: false,
    fourCC: "GCan",
    vendorName: "Unknown",
    modelName: "FTMS Canoe Ergometer",
    namePrefix: "FTMS Canoe",
    manufacturer: "Unknown",
    manufacturerFitId: STRAVA_FIT_ID,
    model: "FTMS Canoe Ergometer",
  ),
  "GRow": RowerDeviceDescriptor(
    defaultSport: ActivityType.Rowing,
    isMultiSport: false,
    fourCC: "GRow",
    vendorName: "Unknown",
    modelName: "FTMS Rower Ergometer",
    namePrefix: "FTMS Rower",
    manufacturer: "Unknown",
    manufacturerFitId: STRAVA_FIT_ID,
    model: "FTMS Rower Ergometer",
  ),
  "GSwi": RowerDeviceDescriptor(
    defaultSport: ActivityType.Swim,
    isMultiSport: false,
    fourCC: "GSwi",
    vendorName: "Unknown",
    modelName: "FTMS Swim Ergometer",
    namePrefix: "FTMS Swim",
    manufacturer: "Unknown",
    manufacturerFitId: STRAVA_FIT_ID,
    model: "FTMS Swim Ergometer",
  ),
};
