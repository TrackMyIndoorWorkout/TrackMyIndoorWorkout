import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
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
    power = source.power;
    speed = (sport != ActivityType.Ride &&
            source.speed != null &&
            source.speed! > 0 &&
            source.speed! < (PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(sport ?? ActivityType.Run)] ?? EPS))
        ? 0
        : source.speed;
    cadence = source.cadence;
    heartRate = source.heartRate;
    dt = source.dt;
  }

  double speedByUnit(bool si, String sport) {
    if (speed == null) return 0.0;

    return speedOrPace(speed!, si, sport);
  }
}
