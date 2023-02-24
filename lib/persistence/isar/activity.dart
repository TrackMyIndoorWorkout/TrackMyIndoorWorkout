import 'package:isar/isar.dart';
import '../../../devices/device_factory.dart';
import '../../../devices/device_fourcc.dart';
import '../../../devices/device_descriptors/device_descriptor.dart';
import '../../../upload/constants.dart';
import '../../../upload/strava/constants.dart';
import '../../../upload/training_peaks/constants.dart';
import '../../../upload/under_armour/constants.dart';
import '../../../utils/display.dart' as display;
import 'record.dart';
import 'workout_summary.dart';

part 'activity.g.dart';

const activitiesTableName = 'activities';

@Collection(inheritance: false)
class Activity {
  Id id;
  final String deviceName;
  final String deviceId;
  String hrmId;
  @Index()
  int start; // ms since epoch
  int end; // ms since epoch
  double distance; // m
  int elapsed; // s
  int movingTime; // ms
  int calories; // kCal
  bool uploaded;
  int stravaId;
  final String fourCC;
  String sport;
  final double powerFactor;
  double calorieFactor;
  final double hrCalorieFactor;
  double hrmCalorieFactor;
  final bool hrBasedCalories;
  final String timeZone;
  bool suuntoUploaded;
  String suuntoBlobUrl;
  String suuntoUploadIdentifier;
  String suuntoWorkoutUrl;
  bool underArmourUploaded;
  int uaWorkoutId;
  bool trainingPeaksUploaded;
  int trainingPeaksWorkoutId;
  int trainingPeaksAthleteId;

  final records = IsarLinks<Record>();

  @ignore
  DateTime? startDateTime;

  String get elapsedString => Duration(seconds: elapsed).toDisplay();
  String get movingTimeString => Duration(milliseconds: movingTime).toDisplay();

  Activity({
    this.id = Isar.autoIncrement,
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
        return "$underArmourWorkoutUrlBase$uaWorkoutId";
      case trainingPeaksChoice:
        return trainingPeaksPortalUrl;
      case stravaChoice:
      default:
        return stravaUrl;
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
    return allFourCC.contains(fourCC)
        ? DeviceFactory.getDescriptorForFourCC(fourCC)
        : DeviceFactory.genericDescriptorForSport(sport);
  }

  String uniqueIntegrationString() {
    return "$id $stravaId $suuntoUploadIdentifier $uaWorkoutId $trainingPeaksWorkoutId";
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
