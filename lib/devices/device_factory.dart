import '../export/fit/fit_manufacturer.dart';
import '../utils/constants.dart';
import 'device_descriptors/cross_trainer_device_descriptor.dart';
import 'device_descriptors/concept2_rower.dart';
import 'device_descriptors/cycling_power_meter_descriptor.dart';
import 'device_descriptors/cycling_speed_and_cadence_descriptor.dart';
import 'device_descriptors/device_descriptor.dart';
import 'device_descriptors/indoor_bike_device_descriptor.dart';
import 'device_descriptors/matrix_bike_descriptor.dart';
import 'device_descriptors/matrix_treadmill_descriptor.dart';
import 'device_descriptors/mr_captain_descriptor.dart';
import 'device_descriptors/npe_runn_treadmill.dart';
import 'device_descriptors/paddling_speed_and_cadence_descriptor.dart';
import 'device_descriptors/precor_spinner_chrono_power.dart';
import 'device_descriptors/rower_device_descriptor.dart';
import 'device_descriptors/schwinn_ac_performance_plus.dart';
import 'device_descriptors/schwinn_x70.dart';
import 'device_descriptors/treadmill_device_descriptor.dart';
import 'device_fourcc.dart';

class DeviceFactory {
  static IndoorBikeDeviceDescriptor getSchwinnIcBike() {
    return IndoorBikeDeviceDescriptor(
      fourCC: schwinnICBikeFourCC,
      vendorName: "Nautilus, Inc",
      modelName: "Schwinn IC4/IC8",
      manufacturerNamePart: "Nautilus",
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
      manufacturerNamePart: "Nautilus",
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
      manufacturerNamePart: "Nautilus",
      manufacturerFitId: nautilusFitId,
      model: "SCH BIKE",
    );
  }

  static IndoorBikeDeviceDescriptor getStagesSB20() {
    return IndoorBikeDeviceDescriptor(
      fourCC: stagesSB20FourCC,
      vendorName: "Stages Cycling",
      modelName: "SB20",
      manufacturerNamePart: "Stages",
      manufacturerFitId: stagesCyclingFitId,
      model: "SB20",
    );
  }

  static IndoorBikeDeviceDescriptor getYesoulS3() {
    return IndoorBikeDeviceDescriptor(
      fourCC: yesoulS3FourCC,
      vendorName: "Yesoul",
      modelName: "S3",
      manufacturerNamePart: "Yesoul",
      manufacturerFitId: stravaFitId,
      model: "S3",
    );
  }

  static RowerDeviceDescriptor getKayaPro() {
    return RowerDeviceDescriptor(
      sport: deviceSportDescriptors[kayakProGenesisPortFourCC]!.defaultSport,
      fourCC: kayakProGenesisPortFourCC,
      vendorName: "KayakPro",
      modelName: "KayakPro Compact",
      manufacturerNamePart: "North Pole Engineering",
      manufacturerFitId: northPoleEngineeringFitId,
      model: "64",
    );
  }

  static TreadmillDeviceDescriptor getGenericFTMSTreadmill() {
    return TreadmillDeviceDescriptor(
      fourCC: genericFTMSTreadmillFourCC,
      vendorName: "Unknown",
      modelName: "Generic Treadmill",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Treadmill",
    );
  }

  static IndoorBikeDeviceDescriptor getGenericFTMSBike() {
    return IndoorBikeDeviceDescriptor(
      fourCC: genericFTMSBikeFourCC,
      vendorName: "Unknown",
      modelName: "Generic Indoor Bike",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Indoor Bike",
    );
  }

  static RowerDeviceDescriptor getGenericFTMSKayaker() {
    return RowerDeviceDescriptor(
      sport: deviceSportDescriptors[genericFTMSKayakFourCC]!.defaultSport,
      isMultiSport: deviceSportDescriptors[genericFTMSKayakFourCC]!.isMultiSport,
      fourCC: genericFTMSKayakFourCC,
      vendorName: "Unknown",
      modelName: "Generic Kayak Ergometer",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Kayak Ergometer",
    );
  }

  static RowerDeviceDescriptor getGenericFTMSCanoeer() {
    return RowerDeviceDescriptor(
      sport: deviceSportDescriptors[genericFTMSCanoeFourCC]!.defaultSport,
      isMultiSport: false,
      fourCC: genericFTMSCanoeFourCC,
      vendorName: "Unknown",
      modelName: "Generic Canoe Ergometer",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Canoe Ergometer",
    );
  }

  static RowerDeviceDescriptor getGenericFTMSRower() {
    return RowerDeviceDescriptor(
      sport: deviceSportDescriptors[genericFTMSRowerFourCC]!.defaultSport,
      isMultiSport: deviceSportDescriptors[genericFTMSRowerFourCC]!.isMultiSport,
      fourCC: genericFTMSRowerFourCC,
      vendorName: "Unknown",
      modelName: "Generic Rower Ergometer",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Rower Ergometer",
    );
  }

  static RowerDeviceDescriptor getGenericFTMSSwimmer() {
    return RowerDeviceDescriptor(
      sport: deviceSportDescriptors[genericFTMSSwimFourCC]!.defaultSport,
      isMultiSport: deviceSportDescriptors[genericFTMSSwimFourCC]!.isMultiSport,
      fourCC: genericFTMSSwimFourCC,
      vendorName: "Unknown",
      modelName: "Generic Swim Ergometer",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Swim Ergometer",
    );
  }

  // Delete this?
  static RowerDeviceDescriptor getGenericFTMSElliptical() {
    return RowerDeviceDescriptor(
      sport: deviceSportDescriptors[genericFTMSEllipticalFourCC]!.defaultSport,
      isMultiSport: deviceSportDescriptors[genericFTMSEllipticalFourCC]!.isMultiSport,
      fourCC: genericFTMSEllipticalFourCC,
      vendorName: "Unknown",
      modelName: "Generic Cross Elliptical",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Elliptical",
    );
  }

  static CrossTrainerDeviceDescriptor getGenericFTMSCrossTrainer() {
    return CrossTrainerDeviceDescriptor(
      fourCC: genericFTMSCrossTrainerFourCC,
      vendorName: "Unknown",
      modelName: "Generic Cross Trainer",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Cross Trainer",
    );
  }

  static CyclingPowerMeterDescriptor getPowerMeterBasedBike() {
    return CyclingPowerMeterDescriptor(
      fourCC: powerMeterBasedBikeFourCC,
      vendorName: "Unknown",
      modelName: "Power Meter Based Bike",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Power Meter Based Bike",
    );
  }

  static CyclingSpeedAndCadenceDescriptor getCSCBasedBike() {
    return CyclingSpeedAndCadenceDescriptor(
      fourCC: cscSensorBasedBikeFourCC,
      vendorName: "Unknown",
      modelName: "Speed and Cadence Sensor Bike",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Speed and Cadence Sensor Bike",
    );
  }

  static PaddlingSpeedAndCadenceDescriptor getCSCBasedPaddler() {
    return PaddlingSpeedAndCadenceDescriptor(
      fourCC: cscSensorBasedPaddleFourCC,
      vendorName: "Old Danube",
      modelName: "Old Danube",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Old Danube",
    );
  }

  static DeviceDescriptor getDescriptorForFourCC(String fourCC) {
    switch (fourCC) {
      case precorSpinnerChronoPowerFourCC:
        return PrecorSpinnerChronoPower();
      case schwinnICBikeFourCC:
        return DeviceFactory.getSchwinnIcBike();
      case bowflexC7BikeFourCC:
        return DeviceFactory.getBowflexC7();
      case schwinnUprightBikeFourCC:
        return DeviceFactory.getSchwinnUprightBike();
      case schwinnX70BikeFourCC:
        return SchwinnX70();
      case stagesSB20FourCC:
        return DeviceFactory.getStagesSB20();
      case yesoulS3FourCC:
        return DeviceFactory.getYesoulS3();
      case schwinnACPerfPlusFourCC:
        return SchwinnACPerformancePlus();
      case matrixBikeFourCC:
        return MatrixBikeDescriptor();
      case kayakProGenesisPortFourCC:
        return DeviceFactory.getKayaPro();
      case mrCaptainRowerFourCC:
        return MrCaptainDescriptor();
      case npeRunnFourCC:
        return NpeRunnTreadmill();
      case matrixTreadmillFourCC:
        return MatrixTreadmillDescriptor();
      case genericFTMSTreadmillFourCC:
        return DeviceFactory.getGenericFTMSTreadmill();
      case genericFTMSBikeFourCC:
        return DeviceFactory.getGenericFTMSBike();
      case genericFTMSKayakFourCC:
        return DeviceFactory.getGenericFTMSKayaker();
      case genericFTMSCanoeFourCC:
        return DeviceFactory.getGenericFTMSCanoeer();
      case genericFTMSRowerFourCC:
        return DeviceFactory.getGenericFTMSRower();
      case genericFTMSSwimFourCC:
        return DeviceFactory.getGenericFTMSSwimmer();
      // Delete this?
      case genericFTMSEllipticalFourCC:
        return DeviceFactory.getGenericFTMSElliptical();
      case genericFTMSCrossTrainerFourCC:
        return DeviceFactory.getGenericFTMSCrossTrainer();
      case powerMeterBasedBikeFourCC:
        return DeviceFactory.getPowerMeterBasedBike();
      case cscSensorBasedBikeFourCC:
        return DeviceFactory.getCSCBasedBike();
      case cscSensorBasedPaddleFourCC:
        return DeviceFactory.getCSCBasedPaddler();
      case concept2RowerFourCC:
        return Concept2Rower();
    }

    return DeviceFactory.getGenericFTMSBike();
  }

  static DeviceDescriptor genericDescriptorForSport(String sport) {
    String fourCC = genericFTMSBikeFourCC;
    switch (sport) {
      case ActivityType.ride:
        fourCC = genericFTMSBikeFourCC;
        break;
      case ActivityType.run:
        fourCC = genericFTMSTreadmillFourCC;
        break;
      case ActivityType.kayaking:
        fourCC = genericFTMSKayakFourCC;
        break;
      case ActivityType.canoeing:
        fourCC = genericFTMSCanoeFourCC;
        break;
      case ActivityType.rowing:
        fourCC = genericFTMSRowerFourCC;
        break;
      case ActivityType.swim:
        fourCC = genericFTMSSwimFourCC;
        break;
      case ActivityType.elliptical:
        fourCC = genericFTMSCrossTrainerFourCC;
        break;
    }

    return DeviceFactory.getDescriptorForFourCC(fourCC);
  }

  static List<DeviceDescriptor> allDescriptors() {
    return [for (var fourCC in allFourCC) DeviceFactory.getDescriptorForFourCC(fourCC)];
  }
}
