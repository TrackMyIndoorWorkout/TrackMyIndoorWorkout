import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../device_fourcc.dart';
import 'device_descriptor.dart';

class SchwinnACPerformancePlus extends DeviceDescriptor {
  static const double extraCalorieFactor = 3.9;

  SchwinnACPerformancePlus()
      : super(
          defaultSport: ActivityType.ride,
          isMultiSport: false,
          fourCC: schwinnACPerfPlusFourCC,
          vendorName: "Schwinn",
          modelName: "AC Performance Plus",
          namePrefixes: ["Schwinn AC Perf+"],
          manufacturerPrefix: "Schwinn",
          manufacturerFitId: stravaFitId,
          model: "Schwinn AC Perf+",
          antPlus: true,
          canMeasureCalories: true, // #258 avoid over inflation
        );

  @override
  SchwinnACPerformancePlus clone() => SchwinnACPerformancePlus();

  @override
  bool isDataProcessable(List<int> data) {
    return false;
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    // Kinda breaks the Liskov-Substitution Principle in SOLID
    // TODO: solve it with Interface Segregation Principle
    throw UnsupportedError("ANT+ only device => import only");
  }

  @override
  void stopWorkout() {
    // Kinda breaks the Liskov-Substitution Principle in SOLID
    // TODO: solve it with Interface Segregation Principle
    throw UnsupportedError("ANT+ only device => import only");
  }
}
