import 'dart:math';

import '../../persistence/models/record.dart';
import '../../preferences/speed_spec.dart';
import '../../preferences/sport_spec.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';

class MeasurementCounter {
  final bool si;
  final String sport;

  int powerCounter = 0;
  int minPower = minInit;
  int maxPower = maxInit;

  int speedCounter = 0;
  double minSpeed = minInit.toDouble();
  double maxSpeed = maxInit.toDouble();

  int cadenceCounter = 0;
  int minCadence = minInit;
  int maxCadence = maxInit;

  int hrCounter = 0;
  int minHr = minInit;
  int maxHr = maxInit;

  double slowPace = eps;

  MeasurementCounter({
    required this.si,
    required this.sport,
  }) {
    if (sport != ActivityType.ride) {
      final slowSpeed = SpeedSpec.slowSpeeds[SportSpec.sport2Sport(sport)] ?? eps;
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
      var speed = record.speedByUnit(si);
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
