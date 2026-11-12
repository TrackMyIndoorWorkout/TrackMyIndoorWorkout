import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:track_my_indoor_exercise/export/activity_export.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/upload/constants.dart';
import 'package:track_my_indoor_exercise/upload/under_armour/constants.dart';
import 'package:track_my_indoor_exercise/upload/under_armour/under_armour.dart';
import 'package:track_my_indoor_exercise/upload/under_armour/under_armour_token.dart';

class FakeActivityExport extends Fake implements ActivityExport {
  @override
  String fileExtension(bool compressed) => compressed ? ".json.gz" : ".json";

  @override
  String mimeType(bool compressed) => "application/json";
}

Activity createTestActivity({int uaWorkoutId = 0, bool underArmourUploaded = false}) {
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
    uaWorkoutId: uaWorkoutId,
    underArmourUploaded: underArmourUploaded,
  );
}

void main() {
  group('UnderArmour Activity URL and Upload tests', () {
    test('workoutUrl returns specific UA workout URL when uaWorkoutId > 0', () {
      final activity = createTestActivity(uaWorkoutId: 12345678, underArmourUploaded: true);

      expect(activity.workoutUrl(underArmourChoice), "${underArmourWorkoutUrlBase}12345678");
      expect(activity.isSpecificWorkoutUrl(underArmourChoice), isTrue);
    });

    test('workoutUrl falls back when uaWorkoutId is 0', () {
      final activity = createTestActivity();

      expect(activity.isSpecificWorkoutUrl(underArmourChoice), isFalse);
    });

    test('clearUnderArmourUpload clears all upload fields', () {
      final activity = createTestActivity()..markUnderArmourUploaded(87654321);

      expect(activity.underArmourUploaded, isTrue);
      expect(activity.uaWorkoutId, 87654321);

      activity.clearUnderArmourUpload();

      expect(activity.underArmourUploaded, isFalse);
      expect(activity.uaWorkoutId, 0);
    });
  });

  group('UnderArmour uploadActivity token checks', () {
    tearDown(() {
      Get.reset();
    });

    test('uploadActivity returns 401 when UnderArmourToken not registered', () async {
      final ua = UnderArmour("client_id", "secret");
      final activity = createTestActivity();
      final status = await ua.uploadActivity(
        activity,
        [1, 2, 3],
        FakeActivityExport(),
        "client_id",
      );

      expect(status, equals(401));
    });

    test('uploadActivity returns 401 when UnderArmourToken header is invalid', () async {
      final token = UnderArmourToken(accessToken: "Error");
      Get.put<UnderArmourToken>(token);

      final ua = UnderArmour("client_id", "secret");
      final activity = createTestActivity();
      final status = await ua.uploadActivity(
        activity,
        [1, 2, 3],
        FakeActivityExport(),
        "client_id",
      );

      expect(status, equals(401));
    });
  });
}
