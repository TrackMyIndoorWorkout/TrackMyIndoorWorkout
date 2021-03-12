import '../persistence/models/activity.dart';
import '../persistence/models/record.dart';
import '../tcx/activity_type.dart';
import 'cadence_sensor.dart';
import 'device_descriptor.dart';
import 'heart_rate_monitor.dart';

class SchwinnACPerformancePlus extends DeviceDescriptor {
  SchwinnACPerformancePlus()
      : super(
          sport: ActivityType.Ride,
          fourCC: "SAP+",
          vendorName: "Schwinn",
          modelName: "AC Performance Plus",
          fullName: '',
          namePrefix: "Schwinn AC Perf+",
          manufacturer: "Schwinn",
          primaryServiceId: null,
          primaryMeasurementId: null,
          calorieFactor: 3.9,
        );

  @override
  bool canPrimaryMeasurementProcessed(List<int> data) {
    return false;
  }

  @override
  restartWorkout() {
    throw UnsupportedError("ANT+ only device => import only");
  }

  @override
  Record processPrimaryMeasurement(
    Activity activity,
    Duration idleDuration,
    Record lastRecord,
    List<int> data,
    HeartRateMonitor hrm,
    CadenceSensor cadenceSensor,
  ) {
    throw UnsupportedError("ANT+ only device => import only");
  }
}
