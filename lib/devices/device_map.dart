import '../utils/constants.dart';
import 'device_descriptors/device_descriptor.dart';
import 'device_descriptors/matrix_bike_descriptor.dart';
import 'device_descriptors/matrix_treadmill_descriptor.dart';
import 'device_descriptors/mr_captain_descriptor.dart';
import 'device_descriptors/npe_runn_treadmill.dart';
import 'device_descriptors/precor_spinner_chrono_power.dart';
import 'device_descriptors/schwinn_ac_performance_plus.dart';
import 'device_descriptors/schwinn_x70.dart';
import 'device_factory.dart';
import 'device_fourcc.dart';

Map<String, DeviceDescriptor> deviceMap = {
  precorSpinnerChronoPowerFourCC: PrecorSpinnerChronoPower(),
  schwinnICBikeFourCC: DeviceFactory.getSchwinnIcBike(),
  bowflexC7BikeFourCC: DeviceFactory.getBowflexC7(),
  schwinnUprightBikeFourCC: DeviceFactory.getSchwinnUprightBike(),
  schwinnX70BikeFourCC: SchwinnX70(),
  stagesSB20FourCC: DeviceFactory.getStagesSB20(),
  yesoulS3FourCC: DeviceFactory.getYesoulS3(),
  schwinnACPerfPlusFourCC: SchwinnACPerformancePlus(),
  matrixBikeFourCC: MatrixBikeDescriptor(),
  kayakProGenesisPortFourCC: DeviceFactory.getKayaPro(),
  mrCaptainRowerFourCC: MrCaptainDescriptor(),
  npeRunnFourCC: NpeRunnTreadmill(),
  matrixTreadmillFourCC: MatrixTreadmillDescriptor(),
  genericFTMSTreadmillFourCC: DeviceFactory.getGenericFTMSTreadmill(),
  genericFTMSBikeFourCC: DeviceFactory.getGenericFTMSBike(),
  genericFTMSKayakFourCC: DeviceFactory.getGenericFTMSKayaker(),
  genericFTMSCanoeFourCC: DeviceFactory.getGenericFTMSCanoeer(),
  genericFTMSRowerFourCC: DeviceFactory.getGenericFTMSRower(),
  genericFTMSSwimFourCC: DeviceFactory.getGenericFTMSSwimmer(),
  // Delete this?
  genericFTMSEllipticalFourCC: DeviceFactory.getGenericFTMSElliptical(),
  genericFTMSCrossTrainerFourCC: DeviceFactory.getGenericFTMSCrossTrainer(),
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
    return deviceMap[genericFTMSCrossTrainerFourCC]!;
  }

  return deviceMap[genericFTMSBikeFourCC]!;
}
