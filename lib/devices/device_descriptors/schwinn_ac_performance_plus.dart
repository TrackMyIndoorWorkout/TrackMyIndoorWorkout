import '../../tcx/activity_type.dart';
import 'device_descriptor.dart';

class SchwinnACPerformancePlus extends DeviceDescriptor {
  SchwinnACPerformancePlus()
      : super(
          defaultSport: ActivityType.Ride,
          isMultiSport: false,
          fourCC: "SAP+",
          vendorName: "Schwinn",
          modelName: "AC Performance Plus",
          namePrefix: "Schwinn AC Perf+",
          manufacturer: "Schwinn",
          dataServiceId: null,
          dataCharacteristicId: null,
          calorieFactor: 3.9,
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
