import 'package:floor/floor.dart';
import '../../persistence/preferences.dart';
import '../../utils/display.dart' as disp;
import 'workout_summary.dart';

const String ACTIVITIES_TABLE_NAME = 'activities';

@Entity(
  tableName: ACTIVITIES_TABLE_NAME,
  indices: [
    Index(value: ['start'])
  ],
)
class Activity {
  @PrimaryKey(autoGenerate: true)
  int? id;
  @ColumnInfo(name: 'device_name')
  final String deviceName;
  @ColumnInfo(name: 'device_id')
  final String deviceId;
  int start; // ms since epoch
  int end; // ms since epoch
  double distance; // m
  int elapsed; // s
  int calories; // kCal
  bool uploaded;
  @ColumnInfo(name: 'strava_id')
  int stravaId;
  @ColumnInfo(name: 'four_cc')
  final String fourCC;
  final String sport;
  @ColumnInfo(name: 'power_factor')
  final double powerFactor;
  @ColumnInfo(name: 'calorie_factor')
  final double calorieFactor;

  @ignore
  DateTime? startDateTime;

  String get elapsedString => Duration(seconds: elapsed).toDisplay();

  Activity({
    this.id,
    required this.deviceName,
    required this.deviceId,
    required this.start,
    this.end: 0,
    this.distance: 0.0,
    this.elapsed: 0,
    this.calories: 0,
    this.uploaded: false,
    this.stravaId: 0,
    this.startDateTime,
    required this.fourCC,
    required this.sport,
    required this.powerFactor,
    required this.calorieFactor,
  });

  void finish(double? distance, int? elapsed, int? calories) {
    this.end = DateTime.now().millisecondsSinceEpoch;
    this.distance = distance ?? 0.0;
    this.elapsed = elapsed ?? 0;
    this.calories = calories ?? 0;
  }

  void markUploaded(int stravaId) {
    this.uploaded = true;
    this.stravaId = stravaId;
  }

  String distanceString(bool si) {
    return disp.distanceString(distance, si);
  }

  String distanceByUnit(bool si) {
    return disp.distanceByUnit(distance, si);
  }

  Activity hydrate() {
    startDateTime = DateTime.fromMillisecondsSinceEpoch(start);
    return this;
  }

  WorkoutSummary getWorkoutSummary(String manufacturer) {
    return WorkoutSummary(
      deviceName: deviceName,
      deviceId: deviceId,
      manufacturer: manufacturer,
      start: start,
      distance: distance,
      elapsed: elapsed,
      sport: sport,
      powerFactor: powerFactor,
      calorieFactor: calorieFactor,
    );
  }
}
