import 'package:floor/floor.dart';
import '../../../utils/constants.dart';
import 'activity.dart';

const recordsTableName = 'records';

@Entity(tableName: recordsTableName, foreignKeys: [
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
  int? id;
  @ColumnInfo(name: 'activity_id')
  int? activityId;
  @ColumnInfo(name: 'time_stamp')
  int? timeStamp; // ms since epoch
  double? distance; // m
  int? elapsed; // s
  int? calories; // kCal
  int? power; // W
  double? speed; // km/h
  int? cadence;
  @ColumnInfo(name: 'heart_rate')
  int? heartRate;

  @ignore
  DateTime? dt;
  @ignore
  int? elapsedMillis;
  @ignore
  double? pace;
  @ignore
  double? strokeCount;
  @ignore
  String? sport;
  @ignore
  double? caloriesPerHour;
  @ignore
  double? caloriesPerMinute;
  @ignore
  int movingTime = 0; // ms

  Record({
    this.id,
    this.activityId,
    this.timeStamp,
    this.distance,
    this.elapsed,
    this.calories,
    this.power,
    this.speed,
    this.cadence,
    this.heartRate,
    this.elapsedMillis,
    this.pace,
    this.strokeCount,
    this.sport,
    this.caloriesPerHour,
    this.caloriesPerMinute,
  }) {
    if (dt == null) {
      if (timeStamp != null && timeStamp! > 0) {
        _dtFromTimeStamp();
      } else {
        dt = DateTime.now();
      }
    }

    if ((timeStamp == null || timeStamp == 0) && dt != null) {
      timeStamp = dt!.millisecondsSinceEpoch;
    }

    paceToSpeed();
  }

  void paceToSpeed() {
    if (sport != null && speed == null && pace != null) {
      if (pace!.abs() < displayEps) {
        speed = 0.0;
      } else {
        if (sport == ActivityType.run || sport == ActivityType.elliptical) {
          // minutes / km pace
          speed = 60.0 / pace!;
        } else if (sport == ActivityType.kayaking ||
            sport == ActivityType.canoeing ||
            sport == ActivityType.rowing) {
          // seconds / 500m pace
          speed = 30.0 / (pace! / 60.0);
        } else if (sport == ActivityType.swim) {
          // seconds / 100m pace
          speed = 6.0 / (pace! / 60.0);
        } else {
          // minutes / km pace
          speed = 60.0 / pace!;
        }
      }
    }
  }

  void _dtFromTimeStamp() {
    if (timeStamp == null) return;

    dt = DateTime.fromMillisecondsSinceEpoch(timeStamp!);
  }
}
