import '../export/fit/fit_manufacturer.dart';
import '../utils/constants.dart';
import 'device_descriptors/device_descriptor.dart';
import 'device_descriptors/indoor_bike_device_descriptor.dart';
import 'device_descriptors/precor_spinner_chrono_power.dart';
import 'device_descriptors/rower_device_descriptor.dart';
import 'device_descriptors/schwinn_ac_performance_plus.dart';
import 'device_descriptors/treadmill_device_descriptor.dart';

const mPowerImportDeviceId = "MPowerImport";
const precorSpinnerChronoPowerFourCC = "PSCP";
const schwinnICBikeFourCC = "SIC4";
const bowflexC7BikeFourCC = "BFC7";
const schwinnUprightBikeFourCC = "S130";
const schwinnACPerfPlusFourCC = "SAP+";
const kayakProGenesisPortFourCC = "KPro";
const npeRunnFourCC = "RUNN";
const genericFTMSBikeFourCC = "GRid";
const genericFTMSTreadmillFourCC = "GRun";
const genericFTMSKayakFourCC = "GKay";
const genericFTMSCanoeFourCC = "GCan";
const genericFTMSRowerFourCC = "GRow";
const genericFTMSSwimFourCC = "GSwi";
const genericFTMSEllipticalFourCC = "GXtr";

Map<String, DeviceDescriptor> deviceMap = {
  precorSpinnerChronoPowerFourCC: PrecorSpinnerChronoPower(),
  schwinnICBikeFourCC: IndoorBikeDeviceDescriptor(
    fourCC: schwinnICBikeFourCC,
    vendorName: "Nautilus, Inc",
    modelName: "Schwinn IC4/IC8",
    namePrefixes: ["IC Bike"],
    manufacturerPrefix: "Nautilus",
    manufacturerFitId: nautilusFitId,
    model: "IC BIKE",
    calorieFactorDefault: 3.60,
  ),
  bowflexC7BikeFourCC: IndoorBikeDeviceDescriptor(
    fourCC: bowflexC7BikeFourCC,
    vendorName: "Nautilus Inc.",
    modelName: "Bowflex C7",
    namePrefixes: ["C7-"],
    manufacturerPrefix: "Nautilus",
    manufacturerFitId: nautilusFitId,
    model: "Bowflex C7",
    calorieFactorDefault: 3.60,
  ),
  schwinnUprightBikeFourCC: IndoorBikeDeviceDescriptor(
    fourCC: schwinnUprightBikeFourCC,
    vendorName: "Nautilus, Inc",
    modelName: "Schwinn 230/510",
    namePrefixes: ["SCH130", "SCH170"],
    manufacturerPrefix: "Nautilus",
    manufacturerFitId: nautilusFitId,
    model: "SCH BIKE",
    calorieFactorDefault: 1.00,
  ),
  schwinnACPerfPlusFourCC: SchwinnACPerformancePlus(),
  kayakProGenesisPortFourCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.kayaking,
    fourCC: kayakProGenesisPortFourCC,
    vendorName: "KayakPro",
    modelName: "KayakPro Compact",
    namePrefixes: ["KayakPro", "KP"],
    manufacturerPrefix: "North Pole Engineering",
    manufacturerFitId: northPoleEengineeringFitId,
    model: "64",
    canMeasureHeartRate: false,
  ),
  npeRunnFourCC: TreadmillDeviceDescriptor(
    fourCC: npeRunnFourCC,
    vendorName: "North Pole Engineering Inc.",
    modelName: "Generic Treadmill",
    namePrefixes: ["RUNN"],
    manufacturerPrefix: "North Pole Engineering",
    manufacturerFitId: northPoleEengineeringFitId,
    model: "77",
  ),
  genericFTMSTreadmillFourCC: TreadmillDeviceDescriptor(
    fourCC: genericFTMSTreadmillFourCC,
    vendorName: "Unknown",
    modelName: "Generic Treadmill",
    namePrefixes: ["FTMS Treadmill"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Treadmill",
  ),
  genericFTMSBikeFourCC: IndoorBikeDeviceDescriptor(
    fourCC: genericFTMSBikeFourCC,
    vendorName: "Unknown",
    modelName: "Generic Indoor Bike",
    namePrefixes: ["FTMS Bike"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Indoor Bike",
  ),
  genericFTMSKayakFourCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.kayaking,
    isMultiSport: false,
    fourCC: genericFTMSKayakFourCC,
    vendorName: "Unknown",
    modelName: "Generic Kayak Ergometer",
    namePrefixes: ["FTMS Kayak"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Kayak Ergometer",
  ),
  genericFTMSCanoeFourCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.canoeing,
    isMultiSport: false,
    fourCC: genericFTMSCanoeFourCC,
    vendorName: "Unknown",
    modelName: "Generic Canoe Ergometer",
    namePrefixes: ["FTMS Canoe"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Canoe Ergometer",
  ),
  genericFTMSRowerFourCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.rowing,
    isMultiSport: false,
    fourCC: genericFTMSRowerFourCC,
    vendorName: "Unknown",
    modelName: "Generic Rower Ergometer",
    namePrefixes: ["FTMS Rower"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Rower Ergometer",
  ),
  genericFTMSSwimFourCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.swim,
    isMultiSport: false,
    fourCC: genericFTMSSwimFourCC,
    vendorName: "Unknown",
    modelName: "Generic Swim Ergometer",
    namePrefixes: ["FTMS Swim"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Swim Ergometer",
  ),
  genericFTMSEllipticalFourCC: RowerDeviceDescriptor(
    defaultSport: ActivityType.elliptical,
    isMultiSport: false,
    fourCC: genericFTMSEllipticalFourCC,
    vendorName: "Unknown",
    modelName: "Generic Cross Trainer / Elliptical",
    namePrefixes: ["FTMS Cross Trainer"],
    manufacturerPrefix: "Unknown",
    manufacturerFitId: stravaFitId,
    model: "Generic Cross Trainer",
  ),
};

DeviceDescriptor genericDescriptorForSport(String sport) {
  if (sport == ActivityType.ride) {
    return deviceMap[genericFTMSBikeFourCC]!;
  } else if (sport == ActivityType.run) {
    return deviceMap[genericFTMSTreadmillFourCC]!;
  } else if (sport == ActivityType.kayaking) {
    return deviceMap[genericFTMSKayakFourCC]!;
  } else if (sport == ActivityType.canoeing) {
    return deviceMap[genericFTMSCanoeFourCC]!;
  } else if (sport == ActivityType.rowing) {
    return deviceMap[genericFTMSRowerFourCC]!;
  } else if (sport == ActivityType.swim) {
    return deviceMap[genericFTMSSwimFourCC]!;
  } else if (sport == ActivityType.elliptical) {
    return deviceMap[genericFTMSEllipticalFourCC]!;
  }

  return deviceMap[genericFTMSBikeFourCC]!;
}
