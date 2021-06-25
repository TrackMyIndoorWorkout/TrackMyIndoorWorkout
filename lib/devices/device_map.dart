import '../export/fit/fit_manufacturer.dart';
import '../utils/constants.dart';
import 'device_descriptors/device_descriptor.dart';
import 'device_descriptors/indoor_bike_device_descriptor.dart';
import 'device_descriptors/precor_spinner_chrono_power.dart';
import 'device_descriptors/rower_device_descriptor.dart';
import 'device_descriptors/schwinn_ac_performance_plus.dart';
import 'device_descriptors/treadmill_device_descriptor.dart';

const MPOWER_IMPORT_DEVICE_ID = "MPowerImport";
const PRECOR_SPINNER_CHRONO_POWER_FOURCC = "PSCP";
const SCHWINN_IC_BIKE_FOURCC = "SIC4";
const SCHWINN_AC_PERF_PLUS_FOURCC = "SAP+";
const KAYAK_PRO_GENESIS_PORT_FOURCC = "KPro";
const NPE_RUNN_FOURCC = "RUNN";
const GENERIC_FTMS_BIKE_FOURCC = "GRid";
const GENERIC_FTMS_TREADMILL_FOURCC = "GRun";
const GENERIC_FTMS_KAYAK_FOURCC = "GKay";
const GENERIC_FTMS_CANOE_FOURCC = "GCan";
const GENERIC_FTMS_ROWER_FOURCC = "GRow";
const GENERIC_FTMS_SWIM_FOURCC = "GSwi";

Map<String, DeviceDescriptor> deviceMap = {
  PRECOR_SPINNER_CHRONO_POWER_FOURCC: PrecorSpinnerChronoPower(),
  SCHWINN_IC_BIKE_FOURCC: IndoorBikeDeviceDescriptor(
    fourCC: SCHWINN_IC_BIKE_FOURCC,
    vendorName: "Nautilus, Inc",
    modelName: "Schwinn IC4/IC8",
    namePrefix: "IC Bike",
    manufacturer: "Nautilus, Inc",
    manufacturerFitId: NAUTILUS_FIT_ID,
    model: "IC BIKE",
    calorieFactorDefault: 1.40,
  ),
  SCHWINN_AC_PERF_PLUS_FOURCC: SchwinnACPerformancePlus(),
  KAYAK_PRO_GENESIS_PORT_FOURCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.Kayaking,
    fourCC: KAYAK_PRO_GENESIS_PORT_FOURCC,
    vendorName: "KayakPro",
    modelName: "KayakPro Compact",
    namePrefix: "KayakPro",
    manufacturer: "North Pole Engineering Inc.",
    manufacturerFitId: NORTH_POLE_ENGINEERING_FIT_ID,
    model: "64",
    canMeasureHeartRate: false,
  ),
  NPE_RUNN_FOURCC: TreadmillDeviceDescriptor(
    fourCC: NPE_RUNN_FOURCC,
    vendorName: "North Pole Engineering Inc.",
    modelName: "Generic Treadmill",
    namePrefix: "RUNN",
    manufacturer: "North Pole Engineering Inc.",
    manufacturerFitId: NORTH_POLE_ENGINEERING_FIT_ID,
    model: "77",
  ),
  GENERIC_FTMS_TREADMILL_FOURCC: TreadmillDeviceDescriptor(
    fourCC: GENERIC_FTMS_TREADMILL_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Treadmill",
    namePrefix: "FTMS Treadmill",
    manufacturer: "Unknown",
    manufacturerFitId: STRAVA_FIT_ID,
    model: "Generic Treadmill",
  ),
  GENERIC_FTMS_BIKE_FOURCC: IndoorBikeDeviceDescriptor(
    fourCC: GENERIC_FTMS_BIKE_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Indoor Bike",
    namePrefix: "FTMS Bike",
    manufacturer: "Unknown",
    manufacturerFitId: STRAVA_FIT_ID,
    model: "Generic Indoor Bike",
  ),
  GENERIC_FTMS_KAYAK_FOURCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.Kayaking,
    isMultiSport: false,
    fourCC: GENERIC_FTMS_KAYAK_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Kayak Ergometer",
    namePrefix: "FTMS Kayak",
    manufacturer: "Unknown",
    manufacturerFitId: STRAVA_FIT_ID,
    model: "Generic Kayak Ergometer",
  ),
  GENERIC_FTMS_CANOE_FOURCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.Canoeing,
    isMultiSport: false,
    fourCC: GENERIC_FTMS_CANOE_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Canoe Ergometer",
    namePrefix: "FTMS Canoe",
    manufacturer: "Unknown",
    manufacturerFitId: STRAVA_FIT_ID,
    model: "Generic Canoe Ergometer",
  ),
  GENERIC_FTMS_ROWER_FOURCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.Rowing,
    isMultiSport: false,
    fourCC: GENERIC_FTMS_ROWER_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Rower Ergometer",
    namePrefix: "FTMS Rower",
    manufacturer: "Unknown",
    manufacturerFitId: STRAVA_FIT_ID,
    model: "Generic Rower Ergometer",
  ),
  GENERIC_FTMS_SWIM_FOURCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.Swim,
    isMultiSport: false,
    fourCC: GENERIC_FTMS_SWIM_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Swim Ergometer",
    namePrefix: "FTMS Swim",
    manufacturer: "Unknown",
    manufacturerFitId: STRAVA_FIT_ID,
    model: "Generic Swim Ergometer",
  ),
};

DeviceDescriptor genericDescriptorForSport(String sport) {
  if (sport == ActivityType.Ride) {
    return deviceMap[GENERIC_FTMS_BIKE_FOURCC]!;
  } else if (sport == ActivityType.Run) {
    return deviceMap[GENERIC_FTMS_TREADMILL_FOURCC]!;
  } else if (sport == ActivityType.Kayaking) {
    return deviceMap[GENERIC_FTMS_KAYAK_FOURCC]!;
  } else if (sport == ActivityType.Canoeing) {
    return deviceMap[GENERIC_FTMS_CANOE_FOURCC]!;
  } else if (sport == ActivityType.Rowing) {
    return deviceMap[GENERIC_FTMS_ROWER_FOURCC]!;
  } else if (sport == ActivityType.Swim) {
    return deviceMap[GENERIC_FTMS_SWIM_FOURCC]!;
  }

  return deviceMap[GENERIC_FTMS_BIKE_FOURCC]!;
}
