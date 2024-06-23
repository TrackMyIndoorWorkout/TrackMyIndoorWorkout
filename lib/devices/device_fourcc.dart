import '../utils/constants.dart';

const bowflexC7BikeFourCC = "BFC7";
const concept2RowerFourCC = "C2Rw";
const concept2SkiFourCC = "C2Sk";
const concept2BikeFourCC = "C2Bk";
const concept2ErgFourCC = "Cpt2";
const cscSensorBasedBikeFourCC = "CSCB";
const cscSensorBasedPaddleFourCC = "CSCP";
const genericFTMSBikeFourCC = "GRid";
const genericFTMSCanoeFourCC = "GCan";
const genericFTMSClimberFourCC = "GClb";
const genericFTMSCrossTrainerFourCC = "GXtr";
const genericFTMSEllipticalFourCC = "GEll";
const genericFTMSKayakFourCC = "GKay";
const genericFTMSRowerFourCC = "GRow";
const genericFTMSSwimFourCC = "GSwi";
const genericFTMSTreadmillFourCC = "GRun";
const kayakFirstFourCC = "K1st";
const kayakProGenesisPortFourCC = "KPro";
const lifeFitnessBikeFourCC = "LFBk";
const lifeFitnessEllipticalFourCC = "LFEl";
const lifeFitnessStairFourCC = "LFSt";
const lifeFitnessTreadmillFourCC = "LFTm";
const npeRunnFourCC = "RUNN";
const matrixBikeFourCC = "MxBk";
const matrixTreadmillFourCC = "MxTm";
const merachMr667FourCC = "M667";
const mrCaptainRowerFourCC = "MrCn";
const mPowerImportDeviceId = "MPowerImport";
const powerMeterBasedBikeFourCC = "PowB";
const powerMeterBasedPaddleFourCC = "PowP";
const precorSpinnerChronoPowerFourCC = "PSCP";
const schwinnACPerfPlusFourCC = "SAP+";
const schwinnICBikeFourCC = "SIC4";
const schwinnUprightBikeFourCC = "S130";
const schwinnX70BikeFourCC = "SX70"; // 170, 270, 570u
const stagesSB20FourCC = "Stg2";
const strydFootPodFourCC = "Strd";
const technogymRunFourCC = "TRun";
const virtufitUltimatePro2FourCC = "VFUP";
const yesoulS3FourCC = "ysS3";

List<String> allFourCC = [
  bowflexC7BikeFourCC,
  concept2BikeFourCC,
  concept2ErgFourCC,
  concept2RowerFourCC,
  concept2SkiFourCC,
  cscSensorBasedBikeFourCC,
  cscSensorBasedPaddleFourCC,
  genericFTMSBikeFourCC,
  genericFTMSCanoeFourCC,
  genericFTMSClimberFourCC,
  genericFTMSCrossTrainerFourCC,
  genericFTMSEllipticalFourCC,
  genericFTMSKayakFourCC,
  genericFTMSRowerFourCC,
  genericFTMSSwimFourCC,
  genericFTMSTreadmillFourCC,
  kayakFirstFourCC,
  kayakProGenesisPortFourCC,
  lifeFitnessBikeFourCC,
  lifeFitnessEllipticalFourCC,
  lifeFitnessStairFourCC,
  lifeFitnessTreadmillFourCC,
  matrixBikeFourCC,
  matrixTreadmillFourCC,
  merachMr667FourCC,
  mPowerImportDeviceId,
  mrCaptainRowerFourCC,
  npeRunnFourCC,
  powerMeterBasedBikeFourCC,
  powerMeterBasedPaddleFourCC,
  precorSpinnerChronoPowerFourCC,
  schwinnACPerfPlusFourCC,
  schwinnICBikeFourCC,
  schwinnUprightBikeFourCC,
  schwinnX70BikeFourCC,
  stagesSB20FourCC,
  strydFootPodFourCC,
  technogymRunFourCC,
  virtufitUltimatePro2FourCC,
  yesoulS3FourCC,
];

List<String> multiSportFourCCs = [
  concept2ErgFourCC,
  genericFTMSRowerFourCC,
  kayakProGenesisPortFourCC,
  kayakFirstFourCC,
];

class DeviceIdentifierHelperEntry {
  final List<String> deviceNamePrefixes;
  late final List<String> deviceNameLoweredPrefixes;
  final String deviceNamePostfix;
  late final String deviceNameLoweredPostfix;
  final String manufacturerNamePrefix;
  late final String manufacturerNameLoweredPrefix;
  late final bool ambiguous;
  late final bool sportsMatch;

  DeviceIdentifierHelperEntry(
      {required this.deviceNamePrefixes,
      this.deviceNamePostfix = "",
      this.manufacturerNamePrefix = "",
      this.ambiguous = false,
      this.sportsMatch = false}) {
    deviceNameLoweredPrefixes =
        deviceNamePrefixes.map((d) => d.toLowerCase()).toList(growable: false);
    deviceNameLoweredPostfix = deviceNamePostfix.toLowerCase();
    manufacturerNameLoweredPrefix = manufacturerNamePrefix.toLowerCase();
  }
}

// This was originally part of DeviceDescriptor, but we don't want to
// unnecessary instantiate a bunch of them when trying to identify an
// equipment. So it was factored out here.
Map<String, DeviceIdentifierHelperEntry> deviceNamePrefixes = {
  bowflexC7BikeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["C7-"]),
  concept2BikeFourCC:
      DeviceIdentifierHelperEntry(deviceNamePrefixes: ["PM5"], deviceNamePostfix: "Bike"),
  concept2ErgFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["PM5"]),
  concept2RowerFourCC:
      DeviceIdentifierHelperEntry(deviceNamePrefixes: ["PM5"], deviceNamePostfix: "Row"),
  concept2SkiFourCC:
      DeviceIdentifierHelperEntry(deviceNamePrefixes: ["PM5"], deviceNamePostfix: "Ski"),
  cscSensorBasedBikeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: [notAvailable]),
  cscSensorBasedPaddleFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: [notAvailable]),
  genericFTMSBikeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Bike"]),
  genericFTMSCanoeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Canoe"]),
  genericFTMSClimberFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Climb"]),
  // Delete this?
  genericFTMSCrossTrainerFourCC:
      DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Cross Trainer"]),
  genericFTMSEllipticalFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Elliptical"]),
  genericFTMSKayakFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Kayak"]),
  genericFTMSRowerFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Rower"]),
  genericFTMSSwimFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Swim"]),
  genericFTMSTreadmillFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Treadmill"]),
  kayakFirstFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: []),
  kayakProGenesisPortFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["KayakPro", "KP"]),
  lifeFitnessBikeFourCC: DeviceIdentifierHelperEntry(
      deviceNamePrefixes: ["LF"], manufacturerNamePrefix: "LifeFitness", sportsMatch: true),
  lifeFitnessEllipticalFourCC: DeviceIdentifierHelperEntry(
      deviceNamePrefixes: ["LF"], manufacturerNamePrefix: "LifeFitness", sportsMatch: true),
  lifeFitnessStairFourCC: DeviceIdentifierHelperEntry(
      deviceNamePrefixes: ["LF"], manufacturerNamePrefix: "LifeFitness", sportsMatch: true),
  lifeFitnessTreadmillFourCC: DeviceIdentifierHelperEntry(
      deviceNamePrefixes: ["LF"], manufacturerNamePrefix: "LifeFitness", sportsMatch: true),
  matrixBikeFourCC: DeviceIdentifierHelperEntry(
      deviceNamePrefixes: ["CTM", "Johnson", "Matrix"], ambiguous: true),
  matrixTreadmillFourCC: DeviceIdentifierHelperEntry(
      deviceNamePrefixes: ["CTM", "Johnson", "Matrix"], ambiguous: true),
  merachMr667FourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Merach-MR667"]),
  mrCaptainRowerFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["XG"]),
  npeRunnFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["RUNN"]),
  powerMeterBasedBikeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Stages IC"]),
  powerMeterBasedPaddleFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: [notAvailable]),
  precorSpinnerChronoPowerFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["CHRONO"]),
  schwinnACPerfPlusFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Schwinn AC Perf+"]),
  schwinnICBikeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["IC Bike"]),
  schwinnUprightBikeFourCC:
      DeviceIdentifierHelperEntry(deviceNamePrefixes: ["SCH130", "SCH230", "SCH510"]),
  schwinnX70BikeFourCC: DeviceIdentifierHelperEntry(
      deviceNamePrefixes: ["SCHWINN 170", "SCHWINN 270", "SCHWINN 570"]),
  stagesSB20FourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Stages Bike"]),
  strydFootPodFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Stryd"]),
  technogymRunFourCC: DeviceIdentifierHelperEntry(
      deviceNamePrefixes: ["Treadmill"], manufacturerNamePrefix: "Technogym"),
  virtufitUltimatePro2FourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["VIRTUFIT-UP2"]),
  yesoulS3FourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Yesoul"]),
};

class SportDescriptor {
  final String defaultSport;
  final bool isMultiSport;

  SportDescriptor({required this.defaultSport, required this.isMultiSport});
}

// This is also so we don't want to unnecessary instantiate a bunch of
// DeviceDescriptor when working around sports.
Map<String, SportDescriptor> deviceSportDescriptors = {
  bowflexC7BikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  concept2RowerFourCC: SportDescriptor(defaultSport: ActivityType.rowing, isMultiSport: false),
  concept2SkiFourCC: SportDescriptor(defaultSport: ActivityType.nordicSki, isMultiSport: false),
  concept2BikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  concept2ErgFourCC: SportDescriptor(defaultSport: ActivityType.rowing, isMultiSport: true),
  cscSensorBasedBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  cscSensorBasedPaddleFourCC:
      SportDescriptor(defaultSport: ActivityType.kayaking, isMultiSport: false),
  genericFTMSBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  genericFTMSCanoeFourCC: SportDescriptor(defaultSport: ActivityType.canoeing, isMultiSport: false),
  genericFTMSClimberFourCC:
      SportDescriptor(defaultSport: ActivityType.rockClimbing, isMultiSport: false),
  genericFTMSCrossTrainerFourCC:
      SportDescriptor(defaultSport: ActivityType.elliptical, isMultiSport: false),
  // Delete this?
  genericFTMSEllipticalFourCC:
      SportDescriptor(defaultSport: ActivityType.elliptical, isMultiSport: false),
  genericFTMSKayakFourCC: SportDescriptor(defaultSport: ActivityType.kayaking, isMultiSport: false),
  genericFTMSRowerFourCC: SportDescriptor(defaultSport: ActivityType.rowing, isMultiSport: false),
  genericFTMSSwimFourCC: SportDescriptor(defaultSport: ActivityType.swim, isMultiSport: false),
  genericFTMSTreadmillFourCC: SportDescriptor(defaultSport: ActivityType.run, isMultiSport: false),
  kayakFirstFourCC: SportDescriptor(defaultSport: ActivityType.kayaking, isMultiSport: true),
  kayakProGenesisPortFourCC:
      SportDescriptor(defaultSport: ActivityType.kayaking, isMultiSport: true),
  lifeFitnessBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  lifeFitnessEllipticalFourCC:
      SportDescriptor(defaultSport: ActivityType.elliptical, isMultiSport: false),
  lifeFitnessStairFourCC:
      SportDescriptor(defaultSport: ActivityType.rockClimbing, isMultiSport: false),
  lifeFitnessTreadmillFourCC: SportDescriptor(defaultSport: ActivityType.run, isMultiSport: false),
  matrixBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  matrixTreadmillFourCC: SportDescriptor(defaultSport: ActivityType.run, isMultiSport: false),
  merachMr667FourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  mrCaptainRowerFourCC: SportDescriptor(defaultSport: ActivityType.rowing, isMultiSport: false),
  npeRunnFourCC: SportDescriptor(defaultSport: ActivityType.run, isMultiSport: false),
  precorSpinnerChronoPowerFourCC:
      SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  powerMeterBasedBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  powerMeterBasedPaddleFourCC:
      SportDescriptor(defaultSport: ActivityType.kayaking, isMultiSport: false),
  schwinnACPerfPlusFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  schwinnICBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  schwinnUprightBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  schwinnX70BikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  stagesSB20FourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  strydFootPodFourCC: SportDescriptor(defaultSport: ActivityType.run, isMultiSport: false),
  technogymRunFourCC: SportDescriptor(defaultSport: ActivityType.run, isMultiSport: false),
  virtufitUltimatePro2FourCC:
      SportDescriptor(defaultSport: ActivityType.rowing, isMultiSport: false),
  yesoulS3FourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
};
