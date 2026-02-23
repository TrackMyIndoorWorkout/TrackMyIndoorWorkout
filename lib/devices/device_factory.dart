import 'package:collection/collection.dart';

import '../../preferences/treadmill_rsc_only_mode.dart';
import '../../persistence/device_usage.dart';
import '../../ui/models/advertisement_digest.dart';
import '../../utils/machine_type.dart';
import '../export/fit/fit_manufacturer.dart';
import '../utils/constants.dart';
import 'device_descriptors/concept2_bike_erg.dart';
import 'device_descriptors/better_health_heart_rate_descriptor.dart';
import 'device_descriptors/cardiostrong_ib50_descriptor.dart';
import 'device_descriptors/concept2_erg.dart';
import 'device_descriptors/concept2_row_erg.dart';
import 'device_descriptors/concept2_ski_erg.dart';
import 'device_descriptors/cross_trainer_device_descriptor.dart';
import 'device_descriptors/cycling_power_meter_descriptor.dart';
import 'device_descriptors/cycling_speed_and_cadence_descriptor.dart';
import 'device_descriptors/device_descriptor.dart';
import 'device_descriptors/heart_rate_descriptor.dart';
import 'device_descriptors/indoor_bike_device_descriptor.dart';
import 'device_descriptors/kayak_first_descriptor.dart';
import 'device_descriptors/internal_sensor_descriptor.dart';
import 'device_descriptors/internal_heart_rate_descriptor.dart';
import 'device_descriptors/life_fitness_bike_descriptor.dart';
import 'device_descriptors/life_fitness_elliptical_descriptor.dart';
import 'device_descriptors/life_fitness_stair_climber_descriptor.dart';
import 'device_descriptors/life_fitness_step_climber_descriptor.dart';
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
import 'device_descriptors/stair_climber_device_descriptor.dart';
import 'device_descriptors/step_climber_device_descriptor.dart';
import 'device_descriptors/treadmill_device_descriptor.dart';
import 'device_fourcc.dart';
import 'gatt/ftms.dart';
import 'gatt/hrm.dart';
import 'gatt/precor.dart';
import 'gatt/kayak_first.dart';
import 'gatt/power_meter.dart';
import 'gatt/csc.dart';
import 'gatt/schwinn_x70.dart';
import 'gatt/concept2.dart';

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

  static StairClimberDeviceDescriptor getGenericFTMSStairClimber() {
    return StairClimberDeviceDescriptor(
      fourCC: genericFTMSStairClimberFourCC,
      vendorName: "Unknown",
      modelName: "Generic Stair Climber",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Stair Climber",
    );
  }

  static StepClimberDeviceDescriptor getGenericFTMSStepClimber() {
    return StepClimberDeviceDescriptor(
      fourCC: genericFTMSStepClimberFourCC,
      vendorName: "Unknown",
      modelName: "Generic Step Climber",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Step Climber",
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

  static HeartRateSensorDescriptor getGenericHeartRateMonitor() {
    return HeartRateSensorDescriptor(
      vendorName: "Unknown",
      modelName: "Generic Heart Rate Monitor",
      manufacturerNamePart: "Unknown",
      manufacturerFitId: stravaFitId,
      model: "Generic Heart Rate Monitor",
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
      vendorName: strydManufacturerName,
      modelName: "$strydManufacturerName Foot Pod",
      manufacturerNamePart: strydManufacturerName,
      manufacturerFitId: strydFitId,
      model: "",
      deviceCategory: DeviceCategory.primarySensor,
    );
  }

  static RunningSpeedAndCadenceDescriptor getTechnogymRun() {
    return RunningSpeedAndCadenceDescriptor(
      fourCC: technogymRunFourCC,
      vendorName: technogymManufacturerName,
      modelName: "Technogym Run",
      manufacturerNamePart: technogymManufacturerName,
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
      vendorName: yesoulManufacturerName,
      modelName: yesoulModelName,
      manufacturerNamePart: yesoulManufacturerName,
      manufacturerFitId: stravaFitId,
      model: yesoulModelName,
    );
  }

  static DeviceDescriptor getDescriptorForFourCC(String fourCC) {
    switch (fourCC) {
      case betterHealthHeartRateFourCC:
        return BetterHealthHeartRateDescriptor();
      case bowflexC7BikeFourCC:
        return DeviceFactory.getBowflexC7();
      case cardiostrongIB50FourCC:
        return CardiostrongIB50Descriptor();
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
      case genericFTMSBikeFourCC:
        return DeviceFactory.getGenericFTMSBike();
      case genericFTMSCanoeFourCC:
        return DeviceFactory.getGenericFTMSCanoeer();
      case genericFTMSCrossTrainerFourCC:
        return DeviceFactory.getGenericFTMSCrossTrainer();
      case genericFTMSEllipticalFourCC:
        return DeviceFactory.getGenericFTMSElliptical();
      case genericFTMSKayakFourCC:
        return DeviceFactory.getGenericFTMSKayaker();
      case genericFTMSRowerFourCC:
        return DeviceFactory.getGenericFTMSRower();
      case genericFTMSStairClimberFourCC:
        return DeviceFactory.getGenericFTMSStairClimber();
      case genericFTMSStepClimberFourCC:
        return DeviceFactory.getGenericFTMSStepClimber();
      case genericFTMSSwimFourCC:
        return DeviceFactory.getGenericFTMSSwimmer();
      case genericFTMSTreadmillFourCC:
        return DeviceFactory.getGenericFTMSTreadmill();
      case heartRateMonitorFourCC:
        return DeviceFactory.getGenericHeartRateMonitor();
      case kayakFirstFourCC:
        return KayakFirstDescriptor();
      case internalMotionSensorFourCC:
        return InternalSensorDescriptor();
      case internalHeartRateMonitorFourCC:
        return InternalHeartRateDescriptor();
      case kayakProGenesisPortFourCC:
        return DeviceFactory.getKayaPro();
      case lifeFitnessBikeFourCC:
        return LifeFitnessBikeDescriptor();
      case lifeFitnessEllipticalFourCC:
        return LifeFitnessEllipticalDescriptor();
      case lifeFitnessStairClimberFourCC:
        return LifeFitnessStairClimberDescriptor();
      case lifeFitnessStepClimberFourCC:
        return LifeFitnessStepClimberDescriptor();
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
      case ActivityType.rockClimbing:
        fourCC = genericFTMSStairClimberFourCC;
        break;
      case ActivityType.rowing:
        fourCC = genericFTMSRowerFourCC;
        break;
      case ActivityType.stairStepper:
        fourCC = genericFTMSStepClimberFourCC;
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
      case ActivityType.workout:
        fourCC = concept2BikeFourCC;
        break;
    }

    return DeviceFactory.getDescriptorForFourCC(fourCC);
  }

  static DeviceDescriptor? determineDescriptor({
    required AdvertisementDigest advertisementDigest,
    required String platformName,
    required DeviceUsage? deviceUsage,
    required bool heartRateMonitorWorkout,
    required String treadmillRscOnlyMode,
    required bool paddlingWithCyclingSensors,
  }) {
    DeviceDescriptor? descriptor;
    if (!advertisementDigest.needsMatrixSpecialTreatment()) {
      final loweredPlatformName = platformName.toLowerCase();
      final ftmsServiceSports = advertisementDigest.machineTypes
          .map((m) => m.sport)
          .toList(growable: false);
      var found = false;
      for (final mapEntry in deviceNamePrefixes.entries.whereNot((dnp) => dnp.value.ambiguous)) {
        if (found) break;
        final lowerPostfix = mapEntry.value.deviceNameLoweredPostfix;
        final descriptorDefaultSport = deviceSportDescriptors[mapEntry.key]!.defaultSport;
        for (var lowerPrefix in mapEntry.value.deviceNameLoweredPrefixes) {
          if (loweredPlatformName.startsWith(lowerPrefix) &&
              (lowerPostfix.isEmpty || loweredPlatformName.endsWith(lowerPostfix)) &&
              !mapEntry.value.shouldBeExcludedByBluetoothName(loweredPlatformName) &&
              (!mapEntry.value.sportsMatch || ftmsServiceSports.contains(descriptorDefaultSport)) &&
              advertisementDigest.isPrefixContained(mapEntry.value.manufacturerNameLoweredPrefix)) {
            if (mapEntry.key == technogymRunFourCC &&
                treadmillRscOnlyMode == treadmillRscOnlyModeNever) {
              continue;
            }

            if (allConcept2FourCCs.contains(mapEntry.key) &&
                advertisementDigest.serviceUuids.contains(fitnessMachineUuid)) {
              // TODO: Does BikeErg implement Indoor Bike FTMS (if any at all)?
              // TODO: What does SkiErg implement (if any at all)?
              continue;
            }

            var descriptorCandidate = DeviceFactory.getDescriptorForFourCC(mapEntry.key);
            if (descriptorCandidate.sport == ActivityType.run &&
                mapEntry.key != technogymRunFourCC &&
                treadmillRscOnlyMode == treadmillRscOnlyModeAlways) {
              descriptorCandidate = DeviceFactory.getDescriptorForFourCC(technogymRunFourCC);
            }

            descriptor = descriptorCandidate;
            found = true;
            break;
          }
        }
      }
    }

    // Step 2. Try to infer from if it has proprietary service
    // Or other dedicated workarounds
    if (descriptor == null) {
      if (!advertisementDigest.serviceUuids.contains(fitnessMachineUuid)) {
        if (advertisementDigest.serviceUuids.contains(precorServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(precorSpinnerChronoPowerFourCC);
        } else if (advertisementDigest.serviceUuids.contains(schwinnX70ServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(schwinnX70BikeFourCC);
        } else if (advertisementDigest.serviceUuids.contains(c2ErgPrimaryServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(concept2ErgFourCC);
        } else if (advertisementDigest.serviceUuids.contains(kayakFirstServiceUuid)) {
          descriptor = DeviceFactory.getDescriptorForFourCC(kayakFirstFourCC);
        } else if (advertisementDigest.serviceUuids.contains(cyclingPowerServiceUuid)) {
          if (paddlingWithCyclingSensors) {
            descriptor = DeviceFactory.getDescriptorForFourCC(powerMeterBasedPaddleFourCC);
          } else {
            descriptor = DeviceFactory.getDescriptorForFourCC(powerMeterBasedBikeFourCC);
          }
        } else if (advertisementDigest.serviceUuids.contains(cyclingCadenceServiceUuid)) {
          if (paddlingWithCyclingSensors) {
            descriptor = DeviceFactory.getDescriptorForFourCC(cscSensorBasedPaddleFourCC);
          } else {
            descriptor = DeviceFactory.getDescriptorForFourCC(cscSensorBasedBikeFourCC);
          }
        } else if (advertisementDigest.serviceUuids.contains(heartRateServiceUuid) &&
            heartRateMonitorWorkout) {
          descriptor = DeviceFactory.getDescriptorForFourCC(heartRateMonitorFourCC);
        }
      } else if (advertisementDigest.needsMatrixSpecialTreatment()) {
        if (advertisementDigest.machineType == MachineType.treadmill) {
          descriptor = DeviceFactory.getDescriptorForFourCC(matrixTreadmillFourCC);
        } else if (advertisementDigest.machineType == MachineType.indoorBike) {
          descriptor = DeviceFactory.getDescriptorForFourCC(matrixBikeFourCC);
        }
      } else if (deviceUsage != null) {
        descriptor = DeviceFactory.genericDescriptorForSport(deviceUsage.sport);
      } else if (advertisementDigest.serviceUuids.contains(fitnessMachineUuid) &&
          advertisementDigest.machineType.isSpecificFtms) {
        descriptor = DeviceFactory.genericDescriptorForSport(advertisementDigest.machineType.sport);
      }
    }
    return descriptor;
  }

  static List<DeviceDescriptor> allDescriptors() {
    return [for (var fourCC in allFourCC) DeviceFactory.getDescriptorForFourCC(fourCC)];
  }

  static List<String> getSportChoices(String fourCC) {
    if (fourCC == kayakFirstFourCC) {
      return paddleSports;
    } else if (fourCC == concept2ErgFourCC) {
      return c2Sports;
    } else if (fourCC == heartRateMonitorFourCC) {
      return allSports;
    }

    // KayakPro
    return waterSports;
  }
}
