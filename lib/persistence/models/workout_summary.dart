import 'package:floor/floor.dart';
import 'package:meta/meta.dart';
import '../../devices/device_descriptors/device_descriptor.dart';
import '../../persistence/preferences.dart';
import '../../utils/display.dart';

const String WORKOUT_SUMMARIES_TABLE_NAME = 'workout_summary';

@Entity(
  tableName: WORKOUT_SUMMARIES_TABLE_NAME,
  indices: [
    Index(value: ['sport']),
    Index(value: ['device_id']),
  ],
)
class WorkoutSummary {
  @PrimaryKey(autoGenerate: true)
  int id;
  @ColumnInfo(name: 'device_name')
  @required
  final String deviceName;
  @ColumnInfo(name: 'device_id')
  @required
  final String deviceId;
  @required
  final String manufacturer;
  @required
  final int start; // ms since epoch
  @required
  final double distance; // m
  @required
  final int elapsed; // s
  double speed; // km/h
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

  WorkoutSummary({
    this.id,
    this.deviceName,
    this.deviceId,
    this.manufacturer,
    this.start,
    this.distance,
    this.elapsed,
    this.sport,
    this.powerFactor,
    this.calorieFactor,
  })  : assert(deviceName != null),
        assert(deviceId != null),
        assert(manufacturer != null),
        assert(start != null),
        assert(distance != null),
        assert(elapsed != null),
        assert(sport != null),
        assert(powerFactor != null),
        assert(calorieFactor != null) {
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
}
