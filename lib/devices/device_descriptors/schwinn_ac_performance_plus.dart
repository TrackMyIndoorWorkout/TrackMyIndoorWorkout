import '../../export/fit/fit_base_type.dart';
import '../../utils/constants.dart';
import '../device_map.dart';
import 'device_descriptor.dart';

class SchwinnACPerformancePlus extends DeviceDescriptor {
  SchwinnACPerformancePlus()
      : super(
          defaultSport: ActivityType.ride,
          isMultiSport: false,
          fourCC: schwinnACPerfPlusFourCC,
          vendorName: "Schwinn",
          modelName: "AC Performance Plus",
          namePrefixes: ["Schwinn AC Perf+"],
          manufacturerPrefix: "Schwinn",
          manufacturerFitId: FitBaseTypes.uint16Type.invalidValue,
          model: "Schwinn AC Perf+",
          dataServiceId: null,
          dataCharacteristicId: null,
          antPlus: true,
          calorieFactorDefault: 3.9,
        );

  @override
  bool canDataProcessed(List<int> data) {
    return false;
  }

  @override
  void stopWorkout() {
    throw UnsupportedError("ANT+ only device => import only");
  }
}
