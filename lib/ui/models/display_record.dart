import '../../persistence/models/record.dart';
import '../../utils/display.dart';

class DisplayRecord {
  int? power; // W
  double? speed; // km/h
  int? cadence;
  int? heartRate;
  DateTime? dt;
  String? sport;

  DisplayRecord(Record source) {
    sport = source.sport;
    power = source.power ?? 0;
    speed = source.speed ?? 0.0;
    cadence = source.cadence ?? 0;
    heartRate = source.heartRate ?? 0;
    dt = source.dt;
  }

  double speedByUnit(bool si) {
    return speedByUnitCore(speed ?? 0.0, si);
  }
}
