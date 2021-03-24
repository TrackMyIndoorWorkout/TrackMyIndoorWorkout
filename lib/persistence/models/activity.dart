import 'package:floor/floor.dart';
import 'package:intl/intl.dart';
import '../../devices/device_map.dart';
import '../../persistence/preferences.dart';
import '../../tcx/tcx_output.dart';

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
  @ColumnInfo(name: 'strava_id')
  int stravaId;
  @ColumnInfo(name: 'four_cc')
  final String fourCC;

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
  });

  void finish(double distance, int elapsed, int calories) {
    this.end = DateTime.now().millisecondsSinceEpoch;
    this.distance = distance;
    this.elapsed = elapsed;
    this.calories = calories;
  }

  void markUploaded(int stravaId) {
    this.uploaded = true;
    this.stravaId = stravaId;
  }

  Map<String, dynamic> getPersistenceValues() {
    final startStamp = DateTime.fromMillisecondsSinceEpoch(start);
    final dateString = DateFormat.yMd().format(startStamp);
    final timeString = DateFormat.Hms().format(startStamp);
    final fileName = 'Activity_${dateString}_$timeString.${TCXOutput.FILE_EXTENSION}'
        .replaceAll('/', '-')
        .replaceAll(':', '-');
    final activityType = deviceMap[fourCC]?.sport ?? "Ride";
    return {
      'startStamp': startStamp,
      'name': '$activityType at $dateString $timeString',
      'description': '$activityType by $deviceName',
      'fileName': fileName,
    };
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
