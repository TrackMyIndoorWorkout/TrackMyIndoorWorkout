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
const concept2RowerFourCC = "Cpt2";
const merachMr667FourCC = "M667";
const virtufitUltimatePro2FourCC = "VFUP";

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
  merachMr667FourCC,
  virtufitUltimatePro2FourCC,
];

List<String> multiSportFourCCs = [
  kayakProGenesisPortFourCC,
  genericFTMSRowerFourCC,
];

// This was originally part of DeviceDescriptor, but we don't want to
// unnecessary instantiate a bunch of them when trying to identify an
// equipment. So it was factored out here.
Map<String, List<String>> deviceNamePrefixes = {
  precorSpinnerChronoPowerFourCC: ["CHRONO"],
  schwinnICBikeFourCC: ["IC Bike"],
  bowflexC7BikeFourCC: ["C7-"],
  schwinnUprightBikeFourCC: ["SCH130", "SCH230", "SCH510"],
  schwinnX70BikeFourCC: ["SCHWINN 170", "SCHWINN 270", "SCHWINN 570"],
  stagesSB20FourCC: ["Stages Bike"],
  yesoulS3FourCC: ["Yesoul"],
  schwinnACPerfPlusFourCC: ["Schwinn AC Perf+"],
  matrixBikeFourCC: ["CTM", "Johnson", "Matrix"],
  kayakProGenesisPortFourCC: ["KayakPro", "KP"],
  mrCaptainRowerFourCC: ["XG"],
  npeRunnFourCC: ["RUNN"],
  matrixTreadmillFourCC: ["CTM", "Johnson", "Matrix"],
  genericFTMSTreadmillFourCC: ["FTMS Treadmill"],
  genericFTMSBikeFourCC: ["FTMS Bike"],
  genericFTMSKayakFourCC: ["FTMS Kayak"],
  genericFTMSCanoeFourCC: ["FTMS Canoe"],
  genericFTMSRowerFourCC: ["FTMS Rower"],
  genericFTMSSwimFourCC: ["FTMS Swim"],
  // Delete this?
  genericFTMSEllipticalFourCC: ["FTMS Elliptical"],
  genericFTMSCrossTrainerFourCC: ["FTMS Cross Trainer"],
  powerMeterBasedBikeFourCC: ["Stages IC"],
  cscSensorBasedBikeFourCC: ["N/A"],
  cscSensorBasedPaddleFourCC: ["N/A"],
  concept2RowerFourCC: ["PM5"],
  merachMr667FourCC: ["Merach-MR667"],
  virtufitUltimatePro2FourCC: ["VIRTUFIT-UP2"],
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
  merachMr667FourCC: SportDescriptor(defaultSport: ActivityType.ride, isMultiSport: false),
  virtufitUltimatePro2FourCC:
      SportDescriptor(defaultSport: ActivityType.rowing, isMultiSport: false),
};
