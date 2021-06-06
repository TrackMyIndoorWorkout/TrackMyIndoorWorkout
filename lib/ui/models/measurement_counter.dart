import 'dart:math';

import '../../persistence/models/record.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';

class MeasurementCounter {
  final bool si;
  final String sport;

  int powerCounter = 0;
  int minPower = MIN_INIT;
  int maxPower = MAX_INIT;

  int speedCounter = 0;
  double minSpeed = MIN_INIT.toDouble();
  double maxSpeed = MAX_INIT.toDouble();

  int cadenceCounter = 0;
  int minCadence = MIN_INIT;
  int maxCadence = MAX_INIT;

  int hrCounter = 0;
  int minHr = MIN_INIT;
  int maxHr = MAX_INIT;

  late double slowPace;

  MeasurementCounter({
    required this.si,
    required this.sport,
  }) {
    if (sport != ActivityType.Ride) {
      final slowSpeed = PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(sport)] ?? EPS;
      slowPace = speedOrPace(slowSpeed, si, sport);
    } else {
      slowPace = 0.0;
    }
  }

  void processRecord(Record record) {
    if (record.power != null && record.power! > 0) {
      powerCounter++;
      maxPower = max(maxPower, record.power!);
      minPower = min(minPower, record.power!);
    }

    if (record.speed != null && record.speed! > 0) {
      speedCounter++;
      var speed = record.speedByUnit(si, sport);
      if (sport != ActivityType.Ride && speed > slowPace) {
        speed = slowPace;
      }
      maxSpeed = max(maxSpeed, speed);
      minSpeed = min(minSpeed, speed);
    }

    if (record.cadence != null && record.cadence! > 0) {
      cadenceCounter++;
      maxCadence = max(maxCadence, record.cadence!);
      minCadence = min(minCadence, record.cadence!);
    }

    if (record.heartRate != null && record.heartRate! > 0) {
      hrCounter++;
      maxHr = max(maxHr, record.heartRate!);
      minHr = min(minHr, record.heartRate!);
    }
  }

  bool get hasPower => powerCounter > 0;
  bool get hasSpeed => speedCounter > 0;
  bool get hasCadence => cadenceCounter > 0;
  bool get hasHeartRate => hrCounter > 0;
}
