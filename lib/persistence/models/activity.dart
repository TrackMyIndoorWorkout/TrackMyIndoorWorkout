import 'package:floor/floor.dart';
import 'package:intl/intl.dart';
import 'package:virtual_velodrome_rider/tcx/tcx_output.dart';

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
    this.id,
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

  Map<String, dynamic> getPersistenceValues() {
    final startStamp = DateTime.fromMillisecondsSinceEpoch(start);
    final dateString = DateFormat.yMd().format(startStamp);
    final timeString = DateFormat.Hms().format(startStamp);
    final fileName = 'ERide_${dateString}_$timeString.${TCXOutput.FILE_EXTENSION}'
        .replaceAll('/', '-')
        .replaceAll(':', '-');
    return {
      'startStamp': startStamp,
      'name': 'Virtual velodrome ride at $dateString $timeString',
      'description': 'Virtual velodrome ride on a $deviceName',
      'fileName': fileName,
    };
  }
}
