import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:track_my_indoor_exercise/export/activity_export.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/upload/constants.dart';
import 'package:track_my_indoor_exercise/upload/strava/constants.dart';
import 'package:track_my_indoor_exercise/upload/strava/strava.dart';
import 'package:track_my_indoor_exercise/upload/strava/strava_status_code.dart';
import 'package:track_my_indoor_exercise/upload/strava/strava_token.dart';

class FakeActivityExport extends Fake implements ActivityExport {
  @override
  String fileExtension(bool compressed) => compressed ? ".fit.gz" : ".fit";

  @override
  String mimeType(bool compressed) => "application/vnd.ant.fit";
}

Activity createTestActivity({int stravaId = 0, int stravaActivityId = 0, bool uploaded = false}) {
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
    stravaId: stravaId,
    stravaActivityId: stravaActivityId,
    uploaded: uploaded,
  );
}

void main() {
  group('Strava Activity URL tests', () {
    test('workoutUrl returns specific Strava URL when stravaActivityId > 0', () {
      final activity = createTestActivity(stravaActivityId: 123456789, uploaded: true);

      expect(activity.workoutUrl(stravaChoice), equals("${stravaActivityUrlBase}123456789"));
      expect(activity.isSpecificWorkoutUrl(stravaChoice), isTrue);
    });

    test('workoutUrl falls back to generic stravaUrl when stravaActivityId == 0', () {
      final activity = createTestActivity(stravaId: 987654);

      expect(activity.workoutUrl(stravaChoice), equals(stravaUrl));
      expect(activity.isSpecificWorkoutUrl(stravaChoice), isFalse);
    });

    test('clearStravaUpload clears all Strava state', () {
      final activity = createTestActivity(stravaId: 1111, stravaActivityId: 2222, uploaded: true);

      activity.clearStravaUpload();
      expect(activity.stravaId, equals(0));
      expect(activity.stravaActivityId, equals(0));
      expect(activity.uploaded, isFalse);
    });
  });

  group('Strava uploadActivity token checks', () {
    tearDown(() {
      Get.reset();
    });

    test('uploadActivity returns statusTokenNotKnownYet when StravaToken not registered', () async {
      final strava = Strava("client_id", "secret");
      final activity = createTestActivity();
      final fault = await strava.uploadActivity(activity, [1, 2, 3], FakeActivityExport());

      expect(fault.statusCode, equals(StravaStatusCode.statusTokenNotKnownYet));
    });

    test('uploadActivity returns statusTokenNotKnownYet when StravaToken is invalid', () async {
      final token = StravaToken(accessToken: "Error");
      Get.put<StravaToken>(token);

      final strava = Strava("client_id", "secret");
      final activity = createTestActivity();
      final fault = await strava.uploadActivity(activity, [1, 2, 3], FakeActivityExport());

      expect(fault.statusCode, equals(StravaStatusCode.statusTokenNotKnownYet));
    });
  });
}
