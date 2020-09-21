import 'package:floor/floor.dart';
import 'activity.dart';

const String RECORDS_TABLE_NAME = 'records';

@Entity(tableName: RECORDS_TABLE_NAME, foreignKeys: [
  ForeignKey(
    childColumns: ['activity_id'],
    parentColumns: ['id'],
    entity: Activity,
  )
], indices: [
  Index(value: ['time_stamp'])
])
class Record {
  @PrimaryKey(autoGenerate: true)
  int id;
  @ColumnInfo(name: 'activity_id')
  final int activityId;
  @ColumnInfo(name: 'time_stamp')
  final int timeStamp; // ms since epoch
  final double distance; // m
  final int elapsed; // s
  final int calories; // kCal
  final int power; // W
  final double speed; // m/s
  final int cadence;
  @ColumnInfo(name: 'heart_rate')
  final int heartRate;
  final double lon;
  final double lat;

  Record({
    this.activityId,
    this.timeStamp,
    this.distance,
    this.elapsed,
    this.calories,
    this.power,
    this.speed,
    this.cadence,
    this.heartRate,
    this.lon,
    this.lat,
  });
}
