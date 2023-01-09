import '../../persistence/models/record.dart';
import '../../utils/display.dart';

class DisplayRecord {
  int? power; // W
  double? speed; // km/h
  int? cadence;
  int? heartRate;
  DateTime? dt;
  String? sport;

  DisplayRecord(Record? source) {
    sport = source?.sport;
    power = source?.power ?? 0;
    speed = source?.speed ?? 0.0;
    cadence = source?.cadence ?? 0;
    heartRate = source?.heartRate ?? 0;
    dt = source?.dt;
  }

  factory DisplayRecord.blank(String sport, DateTime dateTime) {
    return DisplayRecord(null)
      ..sport = sport
      ..dt = dateTime;
  }

  factory DisplayRecord.forValues(
      String sport, DateTime? dateTime, int? power, double? speed, int? cadence, int? heartRate) {
    return DisplayRecord(null)
      ..sport = sport
      ..dt = dateTime
      ..power = power
      ..speed = speed
      ..cadence = cadence
      ..heartRate = heartRate;
  }

  double speedByUnit(bool si) {
    return speedByUnitCore(speed ?? 0.0, si);
  }

  @override
  String toString() {
    return "power $power | "
        "speed $speed | "
        "cadence $cadence | "
        "heartRate $heartRate";
  }
}
