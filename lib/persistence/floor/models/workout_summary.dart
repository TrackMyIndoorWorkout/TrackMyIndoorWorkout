import 'package:floor/floor.dart';
import '../../../devices/device_descriptors/device_descriptor.dart';
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
}
