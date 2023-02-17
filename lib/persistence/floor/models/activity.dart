import 'package:floor/floor.dart';
import '../../../utils/display.dart' as display;

const activitiesTableName = 'activities';

@Entity(
  tableName: activitiesTableName,
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
  @ColumnInfo(name: 'hrm_id')
  String hrmId;
  int start; // ms since epoch
  int end; // ms since epoch
  double distance; // m
  int elapsed; // s
  @ColumnInfo(name: 'moving_time')
  int movingTime; // ms
  int calories; // kCal
  bool uploaded;
  @ColumnInfo(name: 'strava_id')
  int stravaId;
  @ColumnInfo(name: 'four_cc')
  final String fourCC;
  String sport;
  @ColumnInfo(name: 'power_factor')
  final double powerFactor;
  @ColumnInfo(name: 'calorie_factor')
  double calorieFactor;
  @ColumnInfo(name: 'hr_calorie_factor')
  final double hrCalorieFactor;
  @ColumnInfo(name: 'hrm_calorie_factor')
  double hrmCalorieFactor;
  @ColumnInfo(name: 'hr_based_calories')
  final bool hrBasedCalories;
  @ColumnInfo(name: 'time_zone')
  final String timeZone;
  @ColumnInfo(name: 'suunto_uploaded')
  bool suuntoUploaded;
  @ColumnInfo(name: 'suunto_blob_url')
  String suuntoBlobUrl;
  @ColumnInfo(name: 'under_armour_uploaded')
  bool underArmourUploaded;
  @ColumnInfo(name: 'training_peaks_uploaded')
  bool trainingPeaksUploaded;
  @ColumnInfo(name: 'ua_workout_id')
  int uaWorkoutId;
  @ColumnInfo(name: 'suunto_upload_id')
  int suuntoUploadId;
  @ColumnInfo(name: 'suunto_upload_identifier')
  String suuntoUploadIdentifier;
  @ColumnInfo(name: 'suunto_workout_url')
  String suuntoWorkoutUrl;
  @ColumnInfo(name: 'training_peaks_workout_id')
  int trainingPeaksWorkoutId;
  @ColumnInfo(name: 'training_peaks_athlete_id')
  int trainingPeaksAthleteId;

  @ignore
  DateTime? startDateTime;

  String get elapsedString => Duration(seconds: elapsed).toDisplay();
  String get movingTimeString => Duration(milliseconds: movingTime).toDisplay();

  Activity({
    this.id,
    required this.deviceName,
    required this.deviceId,
    required this.hrmId,
    required this.start,
    this.end = 0,
    this.distance = 0.0,
    this.elapsed = 0,
    this.movingTime = 0,
    this.calories = 0,
    this.uploaded = false,
    this.suuntoUploaded = false,
    this.suuntoBlobUrl = "",
    this.underArmourUploaded = false,
    this.trainingPeaksUploaded = false,
    this.stravaId = 0,
    this.uaWorkoutId = 0,
    this.suuntoUploadId = 0,
    this.suuntoUploadIdentifier = "",
    this.suuntoWorkoutUrl = "",
    this.trainingPeaksAthleteId = 0,
    this.trainingPeaksWorkoutId = 0,
    this.startDateTime,
    required this.fourCC,
    required this.sport,
    required this.powerFactor,
    required this.calorieFactor,
    required this.hrCalorieFactor,
    required this.hrmCalorieFactor,
    required this.hrBasedCalories,
    required this.timeZone,
  });
}
