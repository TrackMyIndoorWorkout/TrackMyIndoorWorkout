import '../utils/constants.dart';

const mPowerImportDeviceId = "MPowerImport";
const precorSpinnerChronoPowerFourCC = "PSCP";
const schwinnICBikeFourCC = "SIC4";
const bowflexC7BikeFourCC = "BFC7";
const schwinnUprightBikeFourCC = "S130";
const schwinnACPerfPlusFourCC = "SAP+";
const schwinnX70BikeFourCC = "SX70"; // 170, 270, 570u
const matrixBikeFourCC = "MxBk";
const stagesSB20FourCC = "Stg2";
const yesoulS3FourCC = "ysS3";
const kayakProGenesisPortFourCC = "KPro";
const mrCaptainRowerFourCC = "MrCn";
const npeRunnFourCC = "RUNN";
const matrixTreadmillFourCC = "MxTm";
const genericFTMSBikeFourCC = "GRid";
const genericFTMSTreadmillFourCC = "GRun";
const genericFTMSKayakFourCC = "GKay";
const genericFTMSCanoeFourCC = "GCan";
const genericFTMSRowerFourCC = "GRow";
const genericFTMSSwimFourCC = "GSwi";
const genericFTMSEllipticalFourCC = "GEll";
const genericFTMSCrossTrainerFourCC = "GXtr";
const powerMeterBasedBikeFourCC = "PowB";
const cscSensorBasedBikeFourCC = "CSCB";
const cscSensorBasedPaddleFourCC = "CSCP";
const concept2RowerFourCC = "C2Rw";
const concept2SkiFourCC = "C2Sk";
const concept2BikeFourCC = "C2Bk";
const concept2ErgFourCC = "Cpt2";
const merachMr667FourCC = "M667";
const virtufitUltimatePro2FourCC = "VFUP";
const kayakFirstFourCC = "K1st";
const technogymRunFourCC = "TRun";
const strydFootPodFourCC = "Strd";

List<String> allFourCC = [
  mPowerImportDeviceId,
  precorSpinnerChronoPowerFourCC,
  schwinnICBikeFourCC,
  bowflexC7BikeFourCC,
  schwinnUprightBikeFourCC,
  schwinnACPerfPlusFourCC,
  schwinnX70BikeFourCC,
  matrixBikeFourCC,
  stagesSB20FourCC,
  yesoulS3FourCC,
  kayakProGenesisPortFourCC,
  mrCaptainRowerFourCC,
  npeRunnFourCC,
  matrixTreadmillFourCC,
  genericFTMSBikeFourCC,
  genericFTMSTreadmillFourCC,
  genericFTMSKayakFourCC,
  genericFTMSCanoeFourCC,
  genericFTMSRowerFourCC,
  genericFTMSSwimFourCC,
  genericFTMSEllipticalFourCC,
  genericFTMSCrossTrainerFourCC,
  powerMeterBasedBikeFourCC,
  cscSensorBasedBikeFourCC,
  cscSensorBasedPaddleFourCC,
  concept2RowerFourCC,
  concept2SkiFourCC,
  concept2BikeFourCC,
  concept2ErgFourCC,
  merachMr667FourCC,
  virtufitUltimatePro2FourCC,
  kayakFirstFourCC,
  technogymRunFourCC,
  strydFootPodFourCC,
];

List<String> multiSportFourCCs = [
  kayakProGenesisPortFourCC,
  kayakFirstFourCC,
  genericFTMSRowerFourCC,
  concept2ErgFourCC,
];

class DeviceIdentifierHelperEntry {
  final List<String> deviceNamePrefixes;
  late final List<String> deviceNameLoweredPrefixes;
  final String deviceNamePostfix;
  late final String deviceNameLoweredPostfix;
  final String manufacturerNamePrefix;
  late final String manufacturerNameLoweredPrefix;

  DeviceIdentifierHelperEntry(
      {required this.deviceNamePrefixes,
      this.deviceNamePostfix = "",
      this.manufacturerNamePrefix = ""}) {
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
  precorSpinnerChronoPowerFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["CHRONO"]),
  schwinnICBikeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["IC Bike"]),
  bowflexC7BikeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["C7-"]),
  schwinnUprightBikeFourCC:
      DeviceIdentifierHelperEntry(deviceNamePrefixes: ["SCH130", "SCH230", "SCH510"]),
  schwinnX70BikeFourCC: DeviceIdentifierHelperEntry(
      deviceNamePrefixes: ["SCHWINN 170", "SCHWINN 270", "SCHWINN 570"]),
  stagesSB20FourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Stages Bike"]),
  yesoulS3FourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Yesoul"]),
  schwinnACPerfPlusFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Schwinn AC Perf+"]),
  matrixBikeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["CTM", "Johnson", "Matrix"]),
  kayakProGenesisPortFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["KayakPro", "KP"]),
  mrCaptainRowerFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["XG"]),
  npeRunnFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["RUNN"]),
  matrixTreadmillFourCC:
      DeviceIdentifierHelperEntry(deviceNamePrefixes: ["CTM", "Johnson", "Matrix"]),
  genericFTMSTreadmillFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Treadmill"]),
  genericFTMSBikeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Bike"]),
  genericFTMSKayakFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Kayak"]),
  genericFTMSCanoeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Canoe"]),
  genericFTMSRowerFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Rower"]),
  genericFTMSSwimFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Swim"]),
  // Delete this?
  genericFTMSEllipticalFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Elliptical"]),
  genericFTMSCrossTrainerFourCC:
      DeviceIdentifierHelperEntry(deviceNamePrefixes: ["FTMS Cross Trainer"]),
  powerMeterBasedBikeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Stages IC"]),
  cscSensorBasedBikeFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: [notAvailable]),
  cscSensorBasedPaddleFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: [notAvailable]),
  concept2RowerFourCC:
      DeviceIdentifierHelperEntry(deviceNamePrefixes: ["PM5"], deviceNamePostfix: "Row"),
  concept2SkiFourCC:
      DeviceIdentifierHelperEntry(deviceNamePrefixes: ["PM5"], deviceNamePostfix: "Ski"),
  concept2BikeFourCC:
      DeviceIdentifierHelperEntry(deviceNamePrefixes: ["PM5"], deviceNamePostfix: "Bike"),
  concept2ErgFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["PM5"]),
  merachMr667FourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Merach-MR667"]),
  virtufitUltimatePro2FourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["VIRTUFIT-UP2"]),
  kayakFirstFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: []),
  technogymRunFourCC: DeviceIdentifierHelperEntry(
      deviceNamePrefixes: ["Treadmill"], manufacturerNamePrefix: "Technogym"),
  strydFootPodFourCC: DeviceIdentifierHelperEntry(deviceNamePrefixes: ["Stryd"]),
};

class SportDescriptor {
  final String defaultSport;
  final bool isMultiSport;

  SportDescriptor({required this.defaultSport, required this.isMultiSport});
}

// This is also so we don't want to unnecessary instantiate a bunch of
// DeviceDescriptor when working around sports.
Map<String, SportDescriptor> deviceSportDescriptors = {
  precorSpinnerChronoPowerFourCC:
      SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  schwinnICBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  bowflexC7BikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  schwinnUprightBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  schwinnX70BikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  stagesSB20FourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  yesoulS3FourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  schwinnACPerfPlusFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  matrixBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  kayakProGenesisPortFourCC:
      SportDescriptor(defaultSport: ActivityType.kayaking, isMultiSport: true),
  mrCaptainRowerFourCC: SportDescriptor(defaultSport: ActivityType.rowing, isMultiSport: false),
  npeRunnFourCC: SportDescriptor(defaultSport: ActivityType.run, isMultiSport: false),
  matrixTreadmillFourCC: SportDescriptor(defaultSport: ActivityType.run, isMultiSport: false),
  genericFTMSTreadmillFourCC: SportDescriptor(defaultSport: ActivityType.run, isMultiSport: false),
  genericFTMSBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  genericFTMSKayakFourCC: SportDescriptor(defaultSport: ActivityType.kayaking, isMultiSport: false),
  genericFTMSCanoeFourCC: SportDescriptor(defaultSport: ActivityType.canoeing, isMultiSport: false),
  genericFTMSRowerFourCC: SportDescriptor(defaultSport: ActivityType.rowing, isMultiSport: false),
  genericFTMSSwimFourCC: SportDescriptor(defaultSport: ActivityType.swim, isMultiSport: false),
  // Delete this?
  genericFTMSEllipticalFourCC:
      SportDescriptor(defaultSport: ActivityType.elliptical, isMultiSport: false),
  genericFTMSCrossTrainerFourCC:
      SportDescriptor(defaultSport: ActivityType.elliptical, isMultiSport: false),
  powerMeterBasedBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  cscSensorBasedBikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  cscSensorBasedPaddleFourCC:
      SportDescriptor(defaultSport: ActivityType.kayaking, isMultiSport: false),
  concept2RowerFourCC: SportDescriptor(defaultSport: ActivityType.rowing, isMultiSport: false),
  concept2SkiFourCC: SportDescriptor(defaultSport: ActivityType.nordicSki, isMultiSport: false),
  concept2BikeFourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  concept2ErgFourCC: SportDescriptor(defaultSport: ActivityType.rowing, isMultiSport: true),
  merachMr667FourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  virtufitUltimatePro2FourCC:
      SportDescriptor(defaultSport: ActivityType.rowing, isMultiSport: false),
  kayakFirstFourCC: SportDescriptor(defaultSport: ActivityType.kayaking, isMultiSport: true),
  technogymRunFourCC: SportDescriptor(defaultSport: ActivityType.run, isMultiSport: false),
  strydFootPodFourCC: SportDescriptor(defaultSport: ActivityType.run, isMultiSport: false),
};
