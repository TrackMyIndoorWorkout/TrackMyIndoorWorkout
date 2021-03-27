import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/preferences.dart';
import 'package:track_my_indoor_exercise/tcx/activity_type.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

void main() {
  final speeds = [
    0.0,
    0.2,
    0.3,
    0.5,
    1.0,
    1.2,
    1.3,
    1.5,
    2.0,
    5.0,
    10.0,
    12.0,
    15.0,
    20.0,
  ];
  group("speedStringByUnit for metric system and riding:", () {
    speeds.forEach((speed) {
      final expected = speed.toStringAsFixed(2);
      test("$speed (Ride) -> $expected", () {
        expect(speedOrPaceString(speed, true, ActivityType.Ride), expected);
      });
    });
  });

  group("speedStringByUnit for imperial system and riding:", () {
    speeds.forEach((speed) {
      final expected = (speed * KM2MI).toStringAsFixed(2);
      test("$speed (Ride) -> $expected", () {
        expect(speedOrPaceString(speed, false, ActivityType.Ride), expected);
      });
    });
  });

  group("speedStringByUnit for metric system and running:", () {
    speeds.forEach((speed) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 60.0 / speed;
      final expected = paceString(pace);
      // final expected
      test("$speed (Run) -> $expected", () {
        expect(speedOrPaceString(speed, true, ActivityType.Run), expected);
      });
    });
  });

  group("speedStringByUnit for imperial system and running:", () {
    speeds.forEach((speed) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 60.0 / speed / KM2MI;
      final expected = paceString(pace);
      test("$speed (Run) -> $expected", () {
        expect(speedOrPaceString(speed, false, ActivityType.Run), expected);
      });
    });
  });

  group("speedStringByUnit for paddle sports:", () {
    final sports = [ActivityType.Kayaking, ActivityType.Canoeing, ActivityType.Rowing];
    speeds.forEach((speed) {
      sports.forEach((sport) {
        final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 30.0 / speed;
        final expected = paceString(pace);
        test("$speed ($sport) -> $expected", () {
          // There's no imperial for water sports, it's always 500m
          expect(speedOrPaceString(speed, false, sport), expected);
          expect(speedOrPaceString(speed, true, sport), expected);
        });
      });
    });
  });

  group("speedStringByUnit for swimming:", () {
    speeds.forEach((speed) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 6.0 / speed;
      final expected = paceString(pace);
      test("$speed (Swim) -> $expected", () {
        // There's no imperial for water sports, it's always 100m
        expect(speedOrPaceString(speed, false, ActivityType.Swim), expected);
        expect(speedOrPaceString(speed, true, ActivityType.Swim), expected);
      });
    });
  });

  group("speedStringByUnit for elliptical sports:", () {
    speeds.forEach((speed) {
      final expected = speed.toStringAsFixed(2);
      test("$speed (Elliptical) -> $expected", () {
        // There's no imperial for water sports, it's always 500m
        expect(speedOrPaceString(speed, false, ActivityType.Elliptical), expected);
        expect(speedOrPaceString(speed, true, ActivityType.Elliptical), expected);
      });
    });
  });
}
