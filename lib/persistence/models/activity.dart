import 'package:floor/floor.dart';

const String ACTIVITIES_TABLE_NAME = 'activities';

@Entity(
  tableName: ACTIVITIES_TABLE_NAME,
  indices: [
    Index(value: ['start'])
  ],
)
class Activity {
  @PrimaryKey(autoGenerate: true)
  int id;
  @ColumnInfo(name: 'device_name')
  final String deviceName;
  @ColumnInfo(name: 'device_id')
  final String deviceId;
  final int start; // ms since epoch
  int end; // ms since epoch
  double distance; // m
  int elapsed; // s
  int calories; // kCal
  bool uploaded;

  Activity({
    this.deviceName,
    this.deviceId,
    this.start,
    this.end: 0,
    this.distance: 0,
    this.elapsed: 0,
    this.calories: 0,
    this.uploaded: false,
  });

  finish(double distance, int elapsed, int calories) {
    this.end = DateTime.now().millisecondsSinceEpoch;
    this.distance = distance;
    this.elapsed = elapsed;
    this.calories = calories;
  }
}
