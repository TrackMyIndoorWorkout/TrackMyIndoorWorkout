import 'dart:math';

import '../persistence/models/record.dart';
import '../persistence/preferences.dart';
import '../utils/display.dart';

class DisplayRecord {
  int power; // W
  double speed; // km/h
  int cadence;
  int heartRate;
  DateTime dt;
  String sport;

  DisplayRecord({Record source, List<PreferencesSpec> preferencesSpecs}) {
    power = min(max(source.power, preferencesSpecs[0].zoneLower.first.toInt()),
        preferencesSpecs[0].zoneUpper.last.toInt());
    speed = min(
        max(source.speed, preferencesSpecs[1].zoneLower.first), preferencesSpecs[1].zoneUpper.last);
    cadence = min(max(source.cadence, preferencesSpecs[2].zoneLower.first.toInt()),
        preferencesSpecs[2].zoneUpper.last.toInt());
    heartRate = min(max(source.heartRate, preferencesSpecs[3].zoneLower.first.toInt()),
        preferencesSpecs[3].zoneUpper.last.toInt());
    dt = source.dt;
    sport = source.sport;
  }

  double speedByUnit(bool si, String sport) {
    return speedOrPace(speed, si, sport);
  }
}
