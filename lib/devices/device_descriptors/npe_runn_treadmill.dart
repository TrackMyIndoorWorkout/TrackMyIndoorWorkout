import '../../export/fit/fit_manufacturer.dart';
import '../device_fourcc.dart';
import 'treadmill_device_descriptor.dart';

class NpeRunnTreadmill extends TreadmillDeviceDescriptor {
  NpeRunnTreadmill()
      : super(
          fourCC: npeRunnFourCC,
          vendorName: "North Pole Engineering Inc.",
          modelName: "Generic Treadmill",
          manufacturerNamePart: "North Pole Engineering",
          manufacturerFitId: northPoleEngineeringFitId,
          model: "77",
        );

  @override
  NpeRunnTreadmill clone() => NpeRunnTreadmill();
}
