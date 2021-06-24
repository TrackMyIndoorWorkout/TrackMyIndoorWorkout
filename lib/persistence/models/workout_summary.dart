import 'package:floor/floor.dart';
import '../../devices/device_descriptors/device_descriptor.dart';
import '../../persistence/preferences.dart';
import '../../utils/display.dart';

const WORKOUT_SUMMARIES_TABLE_NAME = 'workout_summary';

@Entity(
  tableName: WORKOUT_SUMMARIES_TABLE_NAME,
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
  late double speed; // km/h
  final String sport;
  @ColumnInfo(name: 'power_factor')
  final double powerFactor;
  @ColumnInfo(name: 'calorie_factor')
  final double calorieFactor;

  @ignore
  late DateTime startDateTime;

  String get elapsedString => Duration(seconds: elapsed).toDisplay();

  WorkoutSummary({
    this.id,
    required this.deviceName,
    required this.deviceId,
    required this.manufacturer,
    required this.start,
    required this.distance,
    required this.elapsed,
    required this.sport,
    required this.powerFactor,
    required this.calorieFactor,
  }) {
    startDateTime = DateTime.fromMillisecondsSinceEpoch(start);
    speed = elapsed > 0 ? distance / elapsed * DeviceDescriptor.MS2KMH : 0.0;
  }

  String speedString(bool si) {
    final speedString = speedOrPaceString(speed, si, sport);
    final speedUnit = getSpeedUnit(si, sport);
    return '$speedString $speedUnit';
  }

  String distanceStringWithUnit(bool si) {
    return distanceByUnit(distance, si);
  }

  double distanceAtTime(int elapsed) {
    return speed * DeviceDescriptor.KMH2MS * elapsed;
  }
}
