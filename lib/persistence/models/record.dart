import 'package:floor/floor.dart';
import '../../persistence/preferences.dart';
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
  final double speed; // km/h
  final int cadence;
  @ColumnInfo(name: 'heart_rate')
  final int heartRate;

  @ignore
  DateTime dt;
  @ignore
  int elapsedMillis;

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
  });

  Record hydrate() {
    dt = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    return this;
  }

  double speedByUnit(bool si) {
    if (si) return speed;
    return speed * KM2MI;
  }

  double distanceByUnit(bool si) {
    if (si) return distance;
    return distance * M2MILE;
  }

  String distanceStringByUnit(bool si) {
    final dist = distanceByUnit(si);
    if (si) return dist.toStringAsFixed(0);
    return dist.toStringAsFixed(2);
  }
}
