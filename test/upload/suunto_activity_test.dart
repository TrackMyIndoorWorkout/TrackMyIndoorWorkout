import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:track_my_indoor_exercise/export/activity_export.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/upload/constants.dart';
import 'package:track_my_indoor_exercise/upload/suunto/constants.dart';
import 'package:track_my_indoor_exercise/upload/suunto/suunto.dart';
import 'package:track_my_indoor_exercise/upload/suunto/suunto_token.dart';

class FakeActivityExport extends Fake implements ActivityExport {
  @override
  String fileExtension(bool compressed) => compressed ? ".fit.gz" : ".fit";

  @override
  String mimeType(bool compressed) => "application/vnd.ant.fit";
}

Activity createTestActivity({
  String suuntoUploadIdentifier = "",
  String suuntoWorkoutUrl = "",
  bool suuntoUploaded = false,
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
    suuntoUploadIdentifier: suuntoUploadIdentifier,
    suuntoWorkoutUrl: suuntoWorkoutUrl,
    suuntoUploaded: suuntoUploaded,
  );
}

void main() {
  group('Suunto Activity URL and Upload tests', () {
    test('workoutUrl returns full Suunto webUrl when set', () {
      final activity = createTestActivity(
        suuntoUploadIdentifier: "6af12350c9b8da09e5c28ce1",
        suuntoWorkoutUrl: "https://maps.suunto.com/move/csabatoth530/6af1235123519d0e50ccb827",
      );

      expect(
        activity.workoutUrl(suuntoChoice),
        "https://maps.suunto.com/move/csabatoth530/6af1235123519d0e50ccb827",
      );
      expect(activity.isSpecificWorkoutUrl(suuntoChoice), isTrue);
    });

    test('workoutUrl appends uploadIdentifier if suuntoWorkoutUrl ends with slash', () {
      final activity = createTestActivity(
        suuntoUploadIdentifier: "6af12350c9b8da09e5c28ce1",
        suuntoWorkoutUrl: "https://maps.suunto.com/move/csabatoth530/",
      );

      expect(
        activity.workoutUrl(suuntoChoice),
        "https://maps.suunto.com/move/csabatoth530/6af12350c9b8da09e5c28ce1",
      );
      expect(activity.isSpecificWorkoutUrl(suuntoChoice), isTrue);
    });

    test('workoutUrl falls back to move URL or portal URL', () {
      final activityWithId = createTestActivity(suuntoUploadIdentifier: "6af12350c9b8da09e5c28ce1");
      expect(
        activityWithId.workoutUrl(suuntoChoice),
        "https://maps.suunto.com/move/6af12350c9b8da09e5c28ce1",
      );

      final emptyActivity = createTestActivity();
      expect(emptyActivity.workoutUrl(suuntoChoice), suuntoPortalUrl);
      expect(emptyActivity.isSpecificWorkoutUrl(suuntoChoice), isFalse);
    });

    test('clearSuuntoUpload clears all upload fields', () {
      final activity = createTestActivity()
        ..suuntoUploadInitiated("id123", "https://blob.url")
        ..markSuuntoUploaded("https://maps.suunto.com/move/test/123");

      expect(activity.suuntoUploaded, isTrue);
      expect(activity.suuntoUploadIdentifier, "id123");
      expect(activity.suuntoBlobUrl, "https://blob.url");
      expect(activity.suuntoWorkoutUrl, "https://maps.suunto.com/move/test/123");

      activity.clearSuuntoUpload();

      expect(activity.suuntoUploaded, isFalse);
      expect(activity.suuntoUploadIdentifier, isEmpty);
      expect(activity.suuntoBlobUrl, isEmpty);
      expect(activity.suuntoWorkoutUrl, isEmpty);
    });
  });

  group('Suunto uploadActivity token checks', () {
    tearDown(() {
      Get.reset();
    });

    test('uploadActivity returns 401 when SuuntoToken not registered', () async {
      final suunto = Suunto("client_id", "secret", "sub_key");
      final activity = createTestActivity();
      final status = await suunto.uploadActivity(activity, [1, 2, 3], FakeActivityExport());

      expect(status, equals(401));
    });

    test('uploadActivity returns 401 when SuuntoToken accessToken is null', () async {
      final token = SuuntoToken(accessToken: null);
      Get.put<SuuntoToken>(token);

      final suunto = Suunto("client_id", "secret", "sub_key");
      final activity = createTestActivity();
      final status = await suunto.uploadActivity(activity, [1, 2, 3], FakeActivityExport());

      expect(status, equals(401));
    });

    test('uploadActivity returns 401 when SuuntoToken header is invalid', () async {
      final token = SuuntoToken(accessToken: "Error");
      Get.put<SuuntoToken>(token);

      final suunto = Suunto("client_id", "secret", "sub_key");
      final activity = createTestActivity();
      final status = await suunto.uploadActivity(activity, [1, 2, 3], FakeActivityExport());

      expect(status, equals(401));
    });
  });
}
