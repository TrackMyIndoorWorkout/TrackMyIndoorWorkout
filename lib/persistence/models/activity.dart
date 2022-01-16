import 'package:floor/floor.dart';
import '../../devices/device_descriptors/device_descriptor.dart';
import '../../devices/device_map.dart';
import '../../preferences/generic.dart';
import '../../upload/constants.dart';
import '../../utils/display.dart' as display;
import 'workout_summary.dart';

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

  void finish(double? distance, int? elapsed, int? calories, int movingTime) {
    end = DateTime.now().millisecondsSinceEpoch;
    this.distance = distance ?? 0.0;
    this.elapsed = elapsed ?? 0;
    this.calories = calories ?? 0;
    this.movingTime = movingTime;
  }

  void markUploaded(int stravaId) {
    uploaded = true;
    this.stravaId = stravaId;
  }

  void markUnderArmourUploaded(int workoutId) {
    underArmourUploaded = true;
    uaWorkoutId = workoutId;
  }

  void suuntoUploadInitiated(String uploadId, String blobUrl) {
    suuntoUploadIdentifier = uploadId;
    suuntoBlobUrl = blobUrl;
  }

  void markSuuntoUploaded(String workoutUrl) {
    suuntoWorkoutUrl = workoutUrl;
    suuntoUploaded = true;
  }

  void markTrainingPeaksUploaded(int athleteId, int workoutId) {
    trainingPeaksAthleteId = athleteId;
    trainingPeaksWorkoutId = workoutId;
    trainingPeaksUploaded = true;
  }

  bool isUploaded(String portalName) {
    switch (portalName) {
      case suuntoChoice:
        return suuntoUploaded;
      case underArmourChoice:
        return underArmourUploaded;
      case trainingPeaksChoice:
        return trainingPeaksUploaded;
      case stravaChoice:
      default:
        return uploaded;
    }
  }

  bool isSpecificWorkoutUrl(String portalName) {
    switch (portalName) {
      case suuntoChoice:
        return suuntoWorkoutUrl.isNotEmpty && suuntoUploadIdentifier.isNotEmpty;
      case underArmourChoice:
        return uaWorkoutId > 0;
      case trainingPeaksChoice:
        return false;
      case stravaChoice:
      default:
        return false;
    }
  }

  String workoutUrl(String portalName) {
    switch (portalName) {
      case suuntoChoice:
        return "$suuntoWorkoutUrl$suuntoUploadIdentifier";
      case underArmourChoice:
        return "https://www.mapmyrun.com/workout/$uaWorkoutId";
      case trainingPeaksChoice:
        return "https://app.trainingpeaks.com/";
      case stravaChoice:
      default:
        return "https://sports-tracker.com/";
    }
  }

  String distanceString(bool si, bool highRes) {
    return display.distanceString(distance, si, highRes);
  }

  String distanceByUnit(bool si, bool highRes) {
    return display.distanceByUnit(distance, si, highRes);
  }

  Activity hydrate() {
    startDateTime = DateTime.fromMillisecondsSinceEpoch(start);
    return this;
  }

  DeviceDescriptor deviceDescriptor() {
    return deviceMap[fourCC] ?? genericDescriptorForSport(sport);
  }

  WorkoutSummary getWorkoutSummary(String manufacturer) {
    return WorkoutSummary(
      deviceName: deviceName,
      deviceId: deviceId,
      manufacturer: manufacturer,
      start: start,
      distance: distance,
      elapsed: elapsed,
      movingTime: movingTime,
      sport: sport,
      powerFactor: powerFactor,
      calorieFactor: calorieFactor,
    );
  }
}
