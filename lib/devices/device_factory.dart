import '../export/fit/fit_manufacturer.dart';
import '../utils/constants.dart';
import 'device_descriptors/cross_trainer_device_descriptor.dart';
import 'device_descriptors/indoor_bike_device_descriptor.dart';
import 'device_descriptors/rower_device_descriptor.dart';
import 'device_descriptors/treadmill_device_descriptor.dart';
import 'device_fourcc.dart';

class DeviceFactory {
  static IndoorBikeDeviceDescriptor getSchwinnIcBike() {
    return IndoorBikeDeviceDescriptor(
      fourCC: schwinnICBikeFourCC,
      vendorName: "Nautilus, Inc",
      modelName: "Schwinn IC4/IC8",
      namePrefixes: ["IC Bike"],
      manufacturerPrefix: "Nautilus",
      manufacturerFitId: nautilusFitId,
      model: "IC BIKE",
      canMeasureCalories: false,
    );
  }

  static IndoorBikeDeviceDescriptor getBowflexC7() {
    return IndoorBikeDeviceDescriptor(
      fourCC: bowflexC7BikeFourCC,
      vendorName: "Nautilus Inc.",
      modelName: "Bowflex C7",
      namePrefixes: ["C7-"],
      manufacturerPrefix: "Nautilus",
      manufacturerFitId: nautilusFitId,
      model: "Bowflex C7",
      canMeasureCalories: false,
    );
  }

  static IndoorBikeDeviceDescriptor getSchwinnUprightBike() {
    return IndoorBikeDeviceDescriptor(
      fourCC: schwinnUprightBikeFourCC,
      vendorName: "Nautilus, Inc",
      modelName: "Schwinn 230/510",
      namePrefixes: ["SCH130", "SCH230", "SCH510"],
      manufacturerPrefix: "Nautilus",
      manufacturerFitId: nautilusFitId,
      model: "SCH BIKE",
    );
  }

  static IndoorBikeDeviceDescriptor getStagesSB20() {
    return IndoorBikeDeviceDescriptor(
      fourCC: stagesSB20FourCC,
      vendorName: "Stages Cycling",
      modelName: "SB20",
      namePrefixes: ["Stages Bike"],
      manufacturerPrefix: "Stages",
      manufacturerFitId: stagesCyclingFitId,
      model: "SB20",
    );
  }

  static IndoorBikeDeviceDescriptor getYesoulS3() {
    return IndoorBikeDeviceDescriptor(
      fourCC: yesoulS3FourCC,
      vendorName: "Yesoul",
      modelName: "S3",
      namePrefixes: ["Yesoul"],
      manufacturerPrefix: "Yesoul",
      manufacturerFitId: stravaFitId,
      model: "S3",
    );
  }

  static RowerDeviceDescriptor getKayaPro() {
    return RowerDeviceDescriptor(
      defaultSport: ActivityType.kayaking,
      fourCC: kayakProGenesisPortFourCC,
      vendorName: "KayakPro",
      modelName: "KayakPro Compact",
      namePrefixes: ["KayakPro", "KP"],
      manufacturerPrefix: "North Pole Engineering",
      manufacturerFitId: northPoleEngineeringFitId,
      model: "64",
      canMeasureHeartRate: false,
    );
  }

  static TreadmillDeviceDescriptor getNpeRunn() {
    return TreadmillDeviceDescriptor(
      fourCC: npeRunnFourCC,
      vendorName: "North Pole Engineering Inc.",
      modelName: "Generic Treadmill",
      namePrefixes: ["RUNN"],
      manufacturerPrefix: "North Pole Engineering",
      manufacturerFitId: northPoleEngineeringFitId,
      model: "77",
    );
  }

  static TreadmillDeviceDescriptor getGenericFTMSTreadmill() {
    return TreadmillDeviceDescriptor(
      fourCC: genericFTMSTreadmillFourCC,
      vendorName: "Unknown",
      modelName: "Generic Treadmill",
      namePrefixes: ["FTMS Treadmill"],
      manufacturerPrefix: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Treadmill",
    );
  }

  static IndoorBikeDeviceDescriptor getGenericFTMSBike() {
    return IndoorBikeDeviceDescriptor(
      fourCC: genericFTMSBikeFourCC,
      vendorName: "Unknown",
      modelName: "Generic Indoor Bike",
      namePrefixes: ["FTMS Bike"],
      manufacturerPrefix: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Indoor Bike",
    );
  }

  static RowerDeviceDescriptor getGenericFTMSKayaker() {
    return RowerDeviceDescriptor(
      defaultSport: ActivityType.kayaking,
      isMultiSport: false,
      fourCC: genericFTMSKayakFourCC,
      vendorName: "Unknown",
      modelName: "Generic Kayak Ergometer",
      namePrefixes: ["FTMS Kayak"],
      manufacturerPrefix: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Kayak Ergometer",
    );
  }

  static RowerDeviceDescriptor getGenericFTMSCanoeer() {
    return RowerDeviceDescriptor(
      defaultSport: ActivityType.canoeing,
      isMultiSport: false,
      fourCC: genericFTMSCanoeFourCC,
      vendorName: "Unknown",
      modelName: "Generic Canoe Ergometer",
      namePrefixes: ["FTMS Canoe"],
      manufacturerPrefix: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Canoe Ergometer",
    );
  }

  static RowerDeviceDescriptor getGenericFTMSRower() {
    return RowerDeviceDescriptor(
      defaultSport: ActivityType.rowing,
      isMultiSport: false,
      fourCC: genericFTMSRowerFourCC,
      vendorName: "Unknown",
      modelName: "Generic Rower Ergometer",
      namePrefixes: ["FTMS Rower"],
      manufacturerPrefix: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Rower Ergometer",
    );
  }

  static RowerDeviceDescriptor getGenericFTMSSwimmer() {
    return RowerDeviceDescriptor(
      defaultSport: ActivityType.swim,
      isMultiSport: false,
      fourCC: genericFTMSSwimFourCC,
      vendorName: "Unknown",
      modelName: "Generic Swim Ergometer",
      namePrefixes: ["FTMS Swim"],
      manufacturerPrefix: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Swim Ergometer",
    );
  }

  // Delete this?
  static RowerDeviceDescriptor getGenericFTMSElliptical() {
    return RowerDeviceDescriptor(
      defaultSport: ActivityType.elliptical,
      isMultiSport: false,
      fourCC: genericFTMSEllipticalFourCC,
      vendorName: "Unknown",
      modelName: "Generic Cross Elliptical",
      namePrefixes: ["FTMS Elliptical"],
      manufacturerPrefix: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Elliptical",
    );
  }

  static CrossTrainerDeviceDescriptor getGenericFTMSCrossTrainer() {
    return CrossTrainerDeviceDescriptor(
      fourCC: genericFTMSCrossTrainerFourCC,
      vendorName: "Unknown",
      modelName: "Generic Cross Trainer",
      namePrefixes: ["FTMS Cross Trainer"],
      manufacturerPrefix: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Cross Trainer",
    );
  }
}
