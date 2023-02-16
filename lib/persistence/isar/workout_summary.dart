import 'dart:math';

import 'package:isar/isar.dart';

import '../../../devices/device_descriptors/device_descriptor.dart';
import '../../../utils/constants.dart';
import '../../../utils/display.dart';

part 'workout_summary.g.dart';

const pacerIdentifier = "Pacer";

@Collection(inheritance: false)
class WorkoutSummary {
  Id id;
  final String deviceName;
  final String deviceId;
  final String manufacturer;
  final int start; // ms since epoch
  final double distance; // m
  final int elapsed; // s
  int movingTime; // ms
  late double speed; // km/h
  final String sport;
  final double powerFactor; // Unused
  final double calorieFactor; // Unused

  @ignore
  late DateTime startDateTime;

  String get elapsedString => Duration(seconds: elapsed).toDisplay();
  String get movingTimeString => Duration(milliseconds: movingTime).toDisplay();
  bool get isPacer => manufacturer == pacerIdentifier;

  WorkoutSummary({
    this.id = Isar.autoIncrement,
    required this.deviceName,
    required this.deviceId,
    required this.manufacturer,
    required this.start,
    required this.distance,
    required this.elapsed,
    required this.movingTime,
    required this.sport,
    this.powerFactor = 1.0,
    this.calorieFactor = 1.0,
  }) {
    startDateTime = DateTime.fromMillisecondsSinceEpoch(start);
    speed = elapsed > 0 ? distance / elapsed * DeviceDescriptor.ms2kmh : 0.0;
  }

  static String speedStringStatic(bool si, double speed, double? slowSpeed, String sport) {
    if (sport != ActivityType.ride && slowSpeed != null) {
      speed = max(speed, slowSpeed);
    }

    final speedString = speedOrPaceString(speed, si, sport);
    var speedUnit = getSpeedUnit(si, sport);
    if (speedUnit.startsWith("min ")) {
      speedUnit = speedUnit.substring(0, 3) + speedUnit.substring(4);
    }
    final retVal = '$speedString $speedUnit';
    return retVal;
  }

  String speedString(bool si, double? slowSpeed) {
    return speedStringStatic(si, speed, slowSpeed, sport);
  }

  String distanceStringWithUnit(bool si, bool highRes) {
    return distanceByUnit(distance, si, highRes);
  }

  double distanceAtTime(int time) {
    // #252 movingTime is in milliseconds!!
    // But right now we use elapsed time
    return speed * DeviceDescriptor.kmh2ms * time;
  }

  static WorkoutSummary getPacerWorkout(double pacerSpeed, String sport) {
    return WorkoutSummary(
      deviceName: pacerIdentifier,
      deviceId: pacerIdentifier,
      manufacturer: pacerIdentifier,
      start: DateTime.now().millisecondsSinceEpoch,
      distance: 0.0,
      elapsed: 0,
      movingTime: 0,
      sport: sport,
    )..speed = pacerSpeed;
  }
}
