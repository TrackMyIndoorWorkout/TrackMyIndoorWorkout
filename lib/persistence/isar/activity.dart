import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:pref/pref.dart';
import '../../devices/device_factory.dart';
import '../../devices/device_fourcc.dart';
import '../../devices/device_descriptors/device_descriptor.dart';
import '../../upload/constants.dart';
import '../../upload/strava/constants.dart';
import '../../upload/training_peaks/constants.dart';
import '../../upload/under_armour/constants.dart';
import '../../preferences/activity_upload_description.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart' as display;
import 'workout_summary.dart';

part 'activity.g.dart';

@Collection(inheritance: false)
class Activity {
  Id id;
  final String deviceName;
  final String deviceId;
  String hrmId;
  @Index()
  DateTime start;
  DateTime? end;
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
  String trainingPeaksFileTrackingUuid;
  int stravaActivityId;

  String get elapsedString => Duration(seconds: elapsed).toDisplay();
  String get movingTimeString => Duration(milliseconds: movingTime).toDisplay();

  Activity({
    this.id = Isar.autoIncrement,
    required this.deviceName,
    required this.deviceId,
    required this.hrmId,
    required this.start,
    this.end,
    this.distance = 0.0,
    this.elapsed = 0,
    this.movingTime = 0,
    this.calories = 0,
    this.uploaded = false,
    this.stravaId = 0,
    this.stravaActivityId = 0,
    this.suuntoUploaded = false,
    this.suuntoBlobUrl = "",
    this.suuntoUploadIdentifier = "",
    this.suuntoWorkoutUrl = "",
    this.underArmourUploaded = false,
    this.uaWorkoutId = 0,
    this.trainingPeaksUploaded = false,
    this.trainingPeaksWorkoutId = 0,
    this.trainingPeaksFileTrackingUuid = "",
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
    end = DateTime.now();
    this.distance = distance ?? 0.0;
    this.elapsed = elapsed ?? 0;
    this.calories = calories ?? 0;
    this.movingTime = movingTime;
  }

  void markStravaUploadInitiated(int uploadId) {
    stravaId = uploadId;
    uploaded = true;
  }

  void markStravaUploaded(int activityId) {
    stravaActivityId = activityId;
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

  void clearSuuntoUpload() {
    suuntoUploadInitiated("", "");
    suuntoWorkoutUrl = "";
    suuntoUploaded = false;
  }

  void markTrainingPeaksUploading(String fileTrackingUuid) {
    trainingPeaksFileTrackingUuid = fileTrackingUuid;
    trainingPeaksUploaded = false;
  }

  void markTrainingPeaksUploaded(int workoutId) {
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
      case anyChoice:
        return uploaded || suuntoUploaded || underArmourUploaded || trainingPeaksUploaded;
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
        return stravaActivityId > 0;
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
        if (stravaActivityId > 0) {
          return "$stravaActivityUrlBase$stravaActivityId";
        } else {
          return stravaUrl;
        }
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

  String substituteTemplate(String template, moderated) {
    return template
        .replaceAll("{sport}", sport)
        .replaceAll("{bt_name}", deviceName)
        .replaceAll("{bt_address}", deviceId)
        .replaceAll("{app}", moderated ? appDomainCore : appUrl)
        .replaceAll("{date}", DateFormat.yMd().format(start))
        .replaceAll("{time}", DateFormat.Hms().format(start));
  }

  String getTitle() {
    final dateString = DateFormat.yMd().format(start);
    final timeString = DateFormat.Hms().format(start);
    return '$sport at $dateString $timeString';
  }

  String getDescription(bool moderated) {
    String description = Get.find<BasePrefService>().get<String>(activityUploadDescriptionTag) ??
        activityUploadDescriptionDefault;
    if (description.isEmpty) {
      description = activityUploadDescriptionDefault;
    }

    return substituteTemplate(description, moderated);
  }

  String getFileNameStub() {
    final dateString = DateFormat.yMd().format(start);
    final timeString = DateFormat.Hms().format(start);
    return 'Activity_${dateString}_$timeString.'.replaceAll('/', '-').replaceAll(':', '-');
  }
}
