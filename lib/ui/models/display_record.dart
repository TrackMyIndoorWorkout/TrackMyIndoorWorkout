import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import '../../tcx/activity_type.dart';
import '../../utils/display.dart';

class DisplayRecord {
  int power; // W
  double speed; // km/h
  int cadence;
  int heartRate;
  DateTime dt;
  String sport;

  DisplayRecord(Record source) {
    sport = source.sport;
    power = source.power;
    speed = (sport != ActivityType.Ride &&
            source.speed > 0 &&
            source.speed < PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(sport)])
        ? 0
        : source.speed;
    cadence = source.cadence;
    heartRate = source.heartRate;
    dt = source.dt;
  }

  double speedByUnit(bool si, String sport) {
    return speedOrPace(speed, si, sport);
  }
}
