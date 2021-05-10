import 'package:floor/floor.dart';
import 'package:meta/meta.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';

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
  @required
  final String deviceName;
  @ColumnInfo(name: 'device_id')
  @required
  final String deviceId;
  final int start; // ms since epoch
  int end; // ms since epoch
  double distance; // m
  int elapsed; // s
  int calories; // kCal
  bool uploaded;
  @ColumnInfo(name: 'strava_id')
  int stravaId;
  @ColumnInfo(name: 'four_cc')
  @required
  final String fourCC;
  @required
  final String sport;
  @ColumnInfo(name: 'power_factor')
  @required
  final double powerFactor;
  @ColumnInfo(name: 'calorie_factor')
  @required
  final double calorieFactor;

  @ignore
  DateTime startDateTime;

  String get elapsedString => Duration(seconds: elapsed).toDisplay();

  Activity({
    this.id,
    this.deviceName,
    this.deviceId,
    this.start,
    this.end: 0,
    this.distance: 0.0,
    this.elapsed: 0,
    this.calories: 0,
    this.uploaded: false,
    this.stravaId,
    this.startDateTime,
    this.fourCC,
    this.sport,
    this.powerFactor,
    this.calorieFactor,
  })  : assert(deviceName != null),
        assert(deviceId != null),
        assert(fourCC != null),
        assert(sport != null),
        assert(powerFactor != null),
        assert(calorieFactor != null) {
    if (distance == null) {
      distance = 0.0;
    }
  }

  bool flipForPace(String item) {
    return item == "speed" && sport != ActivityType.Ride;
  }

  void finish(double distance, int elapsed, int calories) {
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
    if (si) return '${distance.toStringAsFixed(0)}';
    return '${(distance * M2MILE).toStringAsFixed(2)}';
  }

  String distanceByUnit(bool si) {
    final distanceStr = distanceString(si);
    return '$distanceStr ${si ? "m" : "mi"}';
  }

  Activity hydrate() {
    startDateTime = DateTime.fromMillisecondsSinceEpoch(start);
    return this;
  }
}
