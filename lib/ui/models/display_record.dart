import '../../persistence/models/record.dart';
import '../../tcx/activity_type.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';

class DisplayRecord {
  int power; // W
  double speed; // km/h
  int cadence;
  int heartRate;
  DateTime dt;
  String sport;

  DisplayRecord(Record source) {
    power = source.power;
    speed = (sport != ActivityType.Ride && source.speed > 0 && source.speed < MIN_SPEED)
        ? 0
        : source.speed;
    cadence = source.cadence;
    heartRate = source.heartRate;
    dt = source.dt;
    sport = source.sport;
  }

  double speedByUnit(bool si, String sport) {
    return speedOrPace(speed, si, sport);
  }
}
