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
const BOWFLEX_C7_BIKE_FOURCC = "BFC7";
const SCHWINN_UPRIGHT_BIKE_FOURCC = "S130";
const SCHWINN_AC_PERF_PLUS_FOURCC = "SAP+";
const KAYAK_PRO_GENESIS_PORT_FOURCC = "KPro";
const NPE_RUNN_FOURCC = "RUNN";
const GENERIC_FTMS_BIKE_FOURCC = "GRid";
const GENERIC_FTMS_TREADMILL_FOURCC = "GRun";
const GENERIC_FTMS_KAYAK_FOURCC = "GKay";
const GENERIC_FTMS_CANOE_FOURCC = "GCan";
const GENERIC_FTMS_ROWER_FOURCC = "GRow";
const GENERIC_FTMS_SWIM_FOURCC = "GSwi";
const GENERIC_FTMS_ELLIPTICAL_FOURCC = "GXtr";

Map<String, DeviceDescriptor> deviceMap = {
  PRECOR_SPINNER_CHRONO_POWER_FOURCC: PrecorSpinnerChronoPower(),
  SCHWINN_IC_BIKE_FOURCC: IndoorBikeDeviceDescriptor(
    fourCC: SCHWINN_IC_BIKE_FOURCC,
    vendorName: "Nautilus, Inc",
    modelName: "Schwinn IC4/IC8",
    namePrefixes: ["IC Bike"],
    manufacturerPrefix: "Nautilus",
    manufacturerFitId: nautilusFitId,
    model: "IC BIKE",
    calorieFactorDefault: 3.60,
  ),
  BOWFLEX_C7_BIKE_FOURCC: IndoorBikeDeviceDescriptor(
    fourCC: BOWFLEX_C7_BIKE_FOURCC,
    vendorName: "Nautilus Inc.",
    modelName: "Bowflex C7",
    namePrefixes: ["C7-"],
    manufacturerPrefix: "Nautilus",
    manufacturerFitId: nautilusFitId,
    model: "Bowflex C7",
    calorieFactorDefault: 3.60,
  ),
  SCHWINN_UPRIGHT_BIKE_FOURCC: IndoorBikeDeviceDescriptor(
    fourCC: SCHWINN_UPRIGHT_BIKE_FOURCC,
    vendorName: "Nautilus, Inc",
    modelName: "Schwinn 230/510",
    namePrefixes: ["SCH130", "SCH170"],
    manufacturerPrefix: "Nautilus",
    manufacturerFitId: nautilusFitId,
    model: "SCH BIKE",
    calorieFactorDefault: 1.00,
  ),
  SCHWINN_AC_PERF_PLUS_FOURCC: SchwinnACPerformancePlus(),
  KAYAK_PRO_GENESIS_PORT_FOURCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.Kayaking,
    fourCC: KAYAK_PRO_GENESIS_PORT_FOURCC,
    vendorName: "KayakPro",
    modelName: "KayakPro Compact",
    namePrefixes: ["KayakPro", "KP"],
    manufacturerPrefix: "North Pole Engineering",
    manufacturerFitId: northPoleEengineeringFitId,
    model: "64",
    canMeasureHeartRate: false,
  ),
  NPE_RUNN_FOURCC: TreadmillDeviceDescriptor(
    fourCC: NPE_RUNN_FOURCC,
    vendorName: "North Pole Engineering Inc.",
    modelName: "Generic Treadmill",
    namePrefixes: ["RUNN"],
    manufacturerPrefix: "North Pole Engineering",
    manufacturerFitId: northPoleEengineeringFitId,
    model: "77",
  ),
  GENERIC_FTMS_TREADMILL_FOURCC: TreadmillDeviceDescriptor(
    fourCC: GENERIC_FTMS_TREADMILL_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Treadmill",
    namePrefixes: ["FTMS Treadmill"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Treadmill",
  ),
  GENERIC_FTMS_BIKE_FOURCC: IndoorBikeDeviceDescriptor(
    fourCC: GENERIC_FTMS_BIKE_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Indoor Bike",
    namePrefixes: ["FTMS Bike"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Indoor Bike",
  ),
  GENERIC_FTMS_KAYAK_FOURCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.Kayaking,
    isMultiSport: false,
    fourCC: GENERIC_FTMS_KAYAK_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Kayak Ergometer",
    namePrefixes: ["FTMS Kayak"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Kayak Ergometer",
  ),
  GENERIC_FTMS_CANOE_FOURCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.Canoeing,
    isMultiSport: false,
    fourCC: GENERIC_FTMS_CANOE_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Canoe Ergometer",
    namePrefixes: ["FTMS Canoe"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Canoe Ergometer",
  ),
  GENERIC_FTMS_ROWER_FOURCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.Rowing,
    isMultiSport: false,
    fourCC: GENERIC_FTMS_ROWER_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Rower Ergometer",
    namePrefixes: ["FTMS Rower"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Rower Ergometer",
  ),
  GENERIC_FTMS_SWIM_FOURCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.Swim,
    isMultiSport: false,
    fourCC: GENERIC_FTMS_SWIM_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Swim Ergometer",
    namePrefixes: ["FTMS Swim"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Swim Ergometer",
  ),
  GENERIC_FTMS_ELLIPTICAL_FOURCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.Elliptical,
    isMultiSport: false,
    fourCC: GENERIC_FTMS_ELLIPTICAL_FOURCC,
    vendorName: "Unknown",
    modelName: "Generic Cross Trainer / Elliptical",
    namePrefixes: ["FTMS Cross Trainer"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Cross Trainer",
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
  } else if (sport == ActivityType.Elliptical) {
    return deviceMap[GENERIC_FTMS_ELLIPTICAL_FOURCC]!;
  }

  return deviceMap[GENERIC_FTMS_BIKE_FOURCC]!;
}
