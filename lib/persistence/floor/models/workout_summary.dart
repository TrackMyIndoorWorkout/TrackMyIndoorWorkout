import 'dart:math';

import 'package:floor/floor.dart';
import '../../../devices/device_descriptors/device_descriptor.dart';
import '../../../utils/constants.dart';
import '../../../utils/display.dart';

const workoutSummariesTableName = 'workout_summary';
const pacerIdentifier = "Pacer";

@Entity(
  tableName: workoutSummariesTableName,
  indices: [
    Index(value: ['sport']),
    Index(value: ['device_id']),
  ],
)
class WorkoutSummary {
  @PrimaryKey(autoGenerate: true)
  int? id;
  @ColumnInfo(name: 'device_name')
  final String deviceName;
  @ColumnInfo(name: 'device_id')
  final String deviceId;
  final String manufacturer;
  final int start; // ms since epoch
  final double distance; // m
  final int elapsed; // s
  @ColumnInfo(name: 'moving_time')
  int movingTime; // ms
  late double speed; // km/h
  final String sport;
  @ColumnInfo(name: 'power_factor')
  final double powerFactor; // Unused
  @ColumnInfo(name: 'calorie_factor')
  final double calorieFactor; // Unused

  @ignore
  late DateTime startDateTime;

  String get elapsedString => Duration(seconds: elapsed).toDisplay();
  String get movingTimeString => Duration(milliseconds: movingTime).toDisplay();
  bool get isPacer => manufacturer == pacerIdentifier;

  WorkoutSummary({
    this.id,
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
