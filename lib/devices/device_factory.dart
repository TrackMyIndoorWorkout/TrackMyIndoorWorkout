import '../export/fit/fit_manufacturer.dart';
import '../utils/constants.dart';
import 'device_descriptors/concept2_bike_erg.dart';
import 'device_descriptors/concept2_erg.dart';
import 'device_descriptors/concept2_row_erg.dart';
import 'device_descriptors/concept2_ski_erg.dart';
import 'device_descriptors/cross_trainer_device_descriptor.dart';
import 'device_descriptors/cycling_power_meter_descriptor.dart';
import 'device_descriptors/cycling_speed_and_cadence_descriptor.dart';
import 'device_descriptors/device_descriptor.dart';
import 'device_descriptors/indoor_bike_device_descriptor.dart';
import 'device_descriptors/kayak_first_descriptor.dart';
import 'device_descriptors/life_fitness_bike_descriptor.dart';
import 'device_descriptors/life_fitness_elliptical_descriptor.dart';
import 'device_descriptors/life_fitness_stair_climber_descriptor.dart';
import 'device_descriptors/life_fitness_treadmill_descriptor.dart';
import 'device_descriptors/matrix_bike_descriptor.dart';
import 'device_descriptors/matrix_treadmill_descriptor.dart';
import 'device_descriptors/mr_captain_descriptor.dart';
import 'device_descriptors/npe_runn_treadmill.dart';
import 'device_descriptors/paddling_power_meter_descriptor.dart';
import 'device_descriptors/paddling_speed_and_cadence_descriptor.dart';
import 'device_descriptors/precor_spinner_chrono_power.dart';
import 'device_descriptors/rower_device_descriptor.dart';
import 'device_descriptors/running_speed_and_cadence_descriptor.dart';
import 'device_descriptors/schwinn_ac_performance_plus.dart';
import 'device_descriptors/schwinn_x70.dart';
import 'device_descriptors/treadmill_device_descriptor.dart';
import 'device_fourcc.dart';

class DeviceFactory {
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

  static IndoorBikeDeviceDescriptor getMerachMr667() {
    return IndoorBikeDeviceDescriptor(
      fourCC: merachMr667FourCC,
      vendorName: "Merach",
      modelName: "MR667",
      manufacturerNamePart: "HUAWEI Technologies", // HUAWEI Technologies Co., Ltd.
      manufacturerFitId: stravaFitId,
      model: "MR667",
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

  static PaddlingPowerMeterDescriptor getPowerMeterBasedPaddler() {
    return PaddlingPowerMeterDescriptor(
      fourCC: powerMeterBasedPaddleFourCC,
      vendorName: "Unknown",
      modelName: "ESP Ergometer",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "ESP Ergometer",
    );
  }

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

  static RunningSpeedAndCadenceDescriptor getStrydFootPod() {
    return RunningSpeedAndCadenceDescriptor(
      fourCC: technogymRunFourCC,
      vendorName: "Stryd",
      modelName: "Stryd Foot Pod",
      manufacturerNamePart: "Stryd",
      manufacturerFitId: strydFitId,
      model: "",
      deviceCategory: DeviceCategory.primarySensor,
    );
  }

  static RunningSpeedAndCadenceDescriptor getTechnogymRun() {
    return RunningSpeedAndCadenceDescriptor(
      fourCC: technogymRunFourCC,
      vendorName: "Technogym",
      modelName: "Technogym Run",
      manufacturerNamePart: "Technogym",
      manufacturerFitId: technogymFitId,
      model: "Treadmill",
      deviceCategory: DeviceCategory.primarySensor,
    );
  }

  static RowerDeviceDescriptor getVirtufitUltimatePro2() {
    return RowerDeviceDescriptor(
      sport: deviceSportDescriptors[virtufitUltimatePro2FourCC]!.defaultSport,
      isMultiSport: deviceSportDescriptors[virtufitUltimatePro2FourCC]!.isMultiSport,
      fourCC: virtufitUltimatePro2FourCC,
      vendorName: "Virtufit",
      modelName: "Ultimate Pro 2",
      manufacturerNamePart: "XEBEX", // And not Wahoo Fitness, LLC
      manufacturerFitId: wahooFitnessFitId,
      model: "Ultimate Pro 2",
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

  static DeviceDescriptor getDescriptorForFourCC(String fourCC) {
    switch (fourCC) {
      case bowflexC7BikeFourCC:
        return DeviceFactory.getBowflexC7();
      case concept2RowerFourCC:
        return Concept2RowErg();
      case concept2SkiFourCC:
        return Concept2SkiErg();
      case concept2BikeFourCC:
        return Concept2BikeErg();
      case concept2ErgFourCC:
        return Concept2Erg(
          deviceSportDescriptors[concept2ErgFourCC]!.defaultSport,
          deviceSportDescriptors[concept2ErgFourCC]!.isMultiSport,
          concept2ErgFourCC,
        );
      case cscSensorBasedBikeFourCC:
        return DeviceFactory.getCSCBasedBike();
      case cscSensorBasedPaddleFourCC:
        return DeviceFactory.getCSCBasedPaddler();
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
      case kayakFirstFourCC:
        return KayakFirstDescriptor();
      case kayakProGenesisPortFourCC:
        return DeviceFactory.getKayaPro();
      case lifeFitnessBikeFourCC:
        return LifeFitnessBikeDescriptor();
      case lifeFitnessEllipticalFourCC:
        return LifeFitnessEllipticalDescriptor();
      case lifeFitnessStairFourCC:
        return LifeFitnessStairClimberDescriptor();
      case lifeFitnessTreadmillFourCC:
        return LifeFitnessTreadmillDescriptor();
      case matrixBikeFourCC:
        return MatrixBikeDescriptor();
      case matrixTreadmillFourCC:
        return MatrixTreadmillDescriptor();
      case merachMr667FourCC:
        return getMerachMr667();
      case mrCaptainRowerFourCC:
        return MrCaptainDescriptor();
      case npeRunnFourCC:
        return NpeRunnTreadmill();
      case powerMeterBasedBikeFourCC:
        return DeviceFactory.getPowerMeterBasedBike();
      case powerMeterBasedPaddleFourCC:
        return DeviceFactory.getPowerMeterBasedPaddler();
      case precorSpinnerChronoPowerFourCC:
        return PrecorSpinnerChronoPower();
      case schwinnACPerfPlusFourCC:
        return SchwinnACPerformancePlus();
      case schwinnICBikeFourCC:
        return DeviceFactory.getSchwinnIcBike();
      case schwinnUprightBikeFourCC:
        return DeviceFactory.getSchwinnUprightBike();
      case schwinnX70BikeFourCC:
        return SchwinnX70();
      case stagesSB20FourCC:
        return DeviceFactory.getStagesSB20();
      case strydFootPodFourCC:
        return getStrydFootPod();
      case technogymRunFourCC:
        return getTechnogymRun();
      case virtufitUltimatePro2FourCC:
        return getVirtufitUltimatePro2();
      case yesoulS3FourCC:
        return DeviceFactory.getYesoulS3();
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
      case ActivityType.nordicSki:
        fourCC = concept2SkiFourCC;
        break;
    }

    return DeviceFactory.getDescriptorForFourCC(fourCC);
  }

  static List<DeviceDescriptor> allDescriptors() {
    return [for (var fourCC in allFourCC) DeviceFactory.getDescriptorForFourCC(fourCC)];
  }

  static List<String> getSportChoices(String fourCC) {
    if (fourCC == kayakFirstFourCC) {
      return paddleSports;
    } else if (fourCC == concept2ErgFourCC) {
      return c2Sports;
    }

    // KayakPro
    return waterSports;
  }
}
