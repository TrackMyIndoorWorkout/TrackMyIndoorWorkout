import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:track_my_indoor_exercise/export/activity_export.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/upload/constants.dart';
import 'package:track_my_indoor_exercise/upload/training_peaks/constants.dart';
import 'package:track_my_indoor_exercise/upload/training_peaks/training_peaks.dart';
import 'package:track_my_indoor_exercise/upload/training_peaks/training_peaks_token.dart';

class FakeActivityExport extends Fake implements ActivityExport {
  @override
  String fileExtension(bool compressed) => compressed ? ".fit.gz" : ".fit";

  @override
  String mimeType(bool compressed) => "application/vnd.ant.fit";
}

Activity createTestActivity({
  String trainingPeaksFileTrackingUuid = "",
  int trainingPeaksWorkoutId = 0,
  bool trainingPeaksUploaded = false,
}) {
  return Activity(
    deviceName: "Test Bike",
    deviceId: "00:11:22:33:44:55",
    hrmId: "",
    start: DateTime(2026, 11, 10, 10, 0, 0),
    fourCC: "IC4_",
    sport: "Ride",
    powerFactor: 1.0,
    calorieFactor: 1.0,
    hrCalorieFactor: 1.0,
    hrmCalorieFactor: 1.0,
    hrBasedCalories: false,
    timeZone: "America/Los_Angeles",
    trainingPeaksFileTrackingUuid: trainingPeaksFileTrackingUuid,
    trainingPeaksWorkoutId: trainingPeaksWorkoutId,
    trainingPeaksUploaded: trainingPeaksUploaded,
  );
}

void main() {
  group('TrainingPeaks Activity URL and Upload tests', () {
    test('workoutUrl returns portal URL', () {
      final activity = createTestActivity(
        trainingPeaksWorkoutId: 123456,
        trainingPeaksUploaded: true,
      );

      expect(activity.workoutUrl(trainingPeaksChoice), trainingPeaksPortalUrl);
      expect(activity.isSpecificWorkoutUrl(trainingPeaksChoice), isFalse);
    });

    test('clearTrainingPeaksUpload clears all upload fields', () {
      final activity = createTestActivity()
        ..markTrainingPeaksUploading("uuid-12345")
        ..markTrainingPeaksUploaded(99999);

      expect(activity.trainingPeaksUploaded, isTrue);
      expect(activity.trainingPeaksFileTrackingUuid, "uuid-12345");
      expect(activity.trainingPeaksWorkoutId, 99999);

      activity.clearTrainingPeaksUpload();

      expect(activity.trainingPeaksUploaded, isFalse);
      expect(activity.trainingPeaksFileTrackingUuid, isEmpty);
      expect(activity.trainingPeaksWorkoutId, 0);
    });
  });

  group('TrainingPeaks uploadActivity token checks', () {
    tearDown(() {
      Get.reset();
    });

    test('uploadActivity returns 401 when TrainingPeaksToken not registered', () async {
      final tp = TrainingPeaks("client_id", "secret");
      final activity = createTestActivity();
      final status = await tp.uploadActivity(
        activity,
        [1, 2, 3],
        FakeActivityExport(),
        "client_id",
      );

      expect(status, equals(401));
    });

    test('uploadActivity returns 401 when TrainingPeaksToken header is invalid', () async {
      final token = TrainingPeaksToken(accessToken: "Error");
      Get.put<TrainingPeaksToken>(token);

      final tp = TrainingPeaks("client_id", "secret");
      final activity = createTestActivity();
      final status = await tp.uploadActivity(
        activity,
        [1, 2, 3],
        FakeActivityExport(),
        "client_id",
      );

      expect(status, equals(401));
    });
  });
}
