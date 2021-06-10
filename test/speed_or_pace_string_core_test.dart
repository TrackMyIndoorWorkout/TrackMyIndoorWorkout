import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/preferences.dart';
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
  group("speedStringByUnitCore for riding:", () {
    speeds.forEach((speed) {
      final expected = speed.toStringAsFixed(2);
      test("$speed (Ride) -> $expected", () async {
        expect(speedOrPaceStringCore(speed, ActivityType.Ride), expected);
      });
    });
  });

  group("speedOrPaceStringCore for running:", () {
    speeds.forEach((speed) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 60.0 / speed;
      final expected = paceString(pace);
      test("$pace (Run) -> $expected", () async {
        expect(speedOrPaceStringCore(pace, ActivityType.Run), expected);
      });
    });
  });

  group("speedOrPaceStringCore for paddle sports:", () {
    final sports = [ActivityType.Kayaking, ActivityType.Canoeing, ActivityType.Rowing];
    speeds.forEach((speed) {
      sports.forEach((sport) {
        final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 30.0 / speed;
        final expected = paceString(pace);
        test("$pace ($sport) -> $expected", () async {
          // There's no imperial for water sports, it's always 500m
          expect(speedOrPaceStringCore(pace, sport), expected);
        });
      });
    });
  });

  group("speedOrPaceStringCore for swimming:", () {
    speeds.forEach((speed) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 6.0 / speed;
      final expected = paceString(pace);
      test("$pace (Swim) -> $expected", () async {
        // There's no imperial for water sports, it's always 100m
        expect(speedOrPaceStringCore(pace, ActivityType.Swim), expected);
      });
    });
  });

  group("speedOrPaceStringCore for elliptical sports:", () {
    speeds.forEach((speed) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 30.0 / speed;
      final expected = paceString(pace);
      test("$pace (Elliptical) -> $expected", () async {
        // There's no imperial for water sports, it's always 500m
        expect(speedOrPaceStringCore(pace, ActivityType.Elliptical), expected);
      });
    });
  });
}
