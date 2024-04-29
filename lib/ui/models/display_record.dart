import '../../persistence/isar/record.dart';
import '../../utils/display.dart';

class DisplayRecord {
  int? power; // W
  double? speed; // km/h
  int? cadence;
  int? heartRate;
  int? resistance;
  DateTime? timeStamp;
  String? sport;

  DisplayRecord();

  factory DisplayRecord.fromRecord(Record? source) {
    return DisplayRecord()
      ..sport = source?.sport
      ..timeStamp = source?.timeStamp
      ..power = source?.power ?? 0
      ..speed = source?.speed ?? 0.0
      ..cadence = source?.cadence ?? 0
      ..heartRate = source?.heartRate ?? 0
      ..resistance = source?.resistance ?? 0;
  }

  factory DisplayRecord.blank(String sport, DateTime dateTime) {
    return DisplayRecord()
      ..sport = sport
      ..timeStamp = dateTime;
  }

  factory DisplayRecord.forValues(
    String sport,
    DateTime? dateTime,
    int? power,
    double? speed,
    int? cadence,
    int? heartRate,
    int? resistance,
  ) {
    return DisplayRecord()
      ..sport = sport
      ..timeStamp = dateTime
      ..power = power
      ..speed = speed
      ..cadence = cadence
      ..heartRate = heartRate
      ..resistance = resistance;
  }

  double speedByUnit(bool si) {
    return speedByUnitCore(speed ?? 0.0, si);
  }

  @override
  String toString() {
    return "power $power | "
        "speed $speed | "
        "cadence $cadence | "
        "heartRate $heartRate | "
        "resistance $resistance";
  }
}
