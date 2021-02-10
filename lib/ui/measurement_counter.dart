import 'dart:math';

import 'package:meta/meta.dart';
import '../persistence/models/record.dart';

const MIN_INIT = 10000;

class MeasurementCounter {
  final bool si;
  final String sport;

  int powerCounter = 0;
  int minPower = MIN_INIT;
  int maxPower = 0;

  int speedCounter = 0;
  double minSpeed = MIN_INIT.toDouble();
  double maxSpeed = 0;

  int cadenceCounter = 0;
  int minCadence = MIN_INIT;
  int maxCadence = 0;

  int hrCounter = 0;
  int minHr = MIN_INIT;
  int maxHr = 0;

  MeasurementCounter({
    @required this.si,
    @required this.sport,
  })  : assert(si != null),
        assert(sport != null);

  processRecord(Record record) {
    if (record.power > 0) {
      powerCounter++;
      maxPower = max(maxPower, record.power);
      minPower = min(minPower, record.power);
    }
    if (record.speed > 0) {
      speedCounter++;
      final speed = record.speedByUnit(si, sport);
      maxSpeed = max(maxSpeed, speed);
      minSpeed = min(minSpeed, speed);
    }
    if (record.cadence > 0) {
      cadenceCounter++;
      maxCadence = max(maxCadence, record.cadence);
      minCadence = min(minCadence, record.cadence);
    }
    if (record.heartRate > 0) {
      hrCounter++;
      maxHr = max(maxHr, record.heartRate);
      minHr = min(minHr, record.heartRate);
    }
  }

  bool get hasPower => powerCounter > 0;
  bool get hasSpeed => speedCounter > 0;
  bool get hasCadence => cadenceCounter > 0;
  bool get hasHeartRate => hrCounter > 0;
}
