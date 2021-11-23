import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/preferences_spec.dart';
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
    for (final speed in speeds) {
      final expected = speed.toStringAsFixed(2);
      test("$speed (Ride wo slowSpeed) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.Ride), expected);
      });

      test("$speed (Ride w slowSpeed) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.Ride, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and riding:", () {
    for (final speed in speeds) {
      final expected = (speed * KM2MI).toStringAsFixed(2);
      test("$speed (Ride wo slowSpeed) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.Ride), expected);
      });

      test("$speed (Ride w slowSpeed) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.Ride, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for metric system and running wo slowSpeed:", () {
    for (final speed in speeds) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 60.0 / speed;
      final expected = paceString(pace);
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.Run), expected);
      });
    }
  });

  group("speedStringByUnit for metric system and running w slowSpeed:", () {
    final slowSpeed = PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(ActivityType.Run)]!;
    for (final speed in speeds) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 60.0 / speed;
      final expected = speed < slowSpeed ? "0:00" : paceString(pace);
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.Run, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and running wo slowSpeed:", () {
    for (final speed in speeds) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 60.0 / speed / KM2MI;
      final expected = paceString(pace);
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.Run), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and running w slowSpeed:", () {
    final slowSpeed = PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(ActivityType.Run)]!;
    for (final speed in speeds) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 60.0 / speed / KM2MI;
      final expected = speed < slowSpeed ? "0:00" : paceString(pace);
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.Run, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for paddle sports wo slowSpeed:", () {
    final sports = [ActivityType.Kayaking, ActivityType.Canoeing, ActivityType.Rowing];
    for (final speed in speeds) {
      for (final sport in sports) {
        final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 30.0 / speed;
        final expected = paceString(pace);
        test("$speed ($sport) -> $expected", () async {
          // There's no imperial for water sports, it's always 500m
          expect(speedOrPaceString(speed, false, sport), expected);
          expect(speedOrPaceString(speed, true, sport), expected);
        });
      }
    }
  });

  group("speedStringByUnit for paddle sports w slowSpeed:", () {
    final sports = [ActivityType.Kayaking, ActivityType.Canoeing, ActivityType.Rowing];
    final slowSpeed = PreferencesSpec.slowSpeeds[PreferencesSpec.PADDLE_SPORT]!;
    for (final speed in speeds) {
      for (final sport in sports) {
        final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 30.0 / speed;
        final expected = speed < slowSpeed ? "0:00" : paceString(pace);
        test("$speed ($sport) -> $expected", () async {
          expect(speedOrPaceString(speed, false, sport, limitSlowSpeed: true), expected);
          expect(speedOrPaceString(speed, true, sport, limitSlowSpeed: true), expected);
        });
      }
    }
  });

  group("speedStringByUnit for swimming wo slowSpeed:", () {
    for (final speed in speeds) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 6.0 / speed;
      final expected = paceString(pace);
      test("$speed (Swim) -> $expected", () async {
        // There's no imperial for water sports, it's always 100m
        expect(speedOrPaceString(speed, false, ActivityType.Swim), expected);
        expect(speedOrPaceString(speed, true, ActivityType.Swim), expected);
      });
    }
  });

  group("speedStringByUnit for swimming w slowSpeed:", () {
    final slowSpeed = PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(ActivityType.Swim)]!;
    for (final speed in speeds) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 6.0 / speed;
      final expected = speed < slowSpeed ? "0:00" : paceString(pace);
      test("$speed (Swim) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.Swim, limitSlowSpeed: true), expected);
        expect(speedOrPaceString(speed, true, ActivityType.Swim, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for metric system and elliptical sports wo slowSpeed:", () {
    for (final speed in speeds) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 60.0 / speed;
      final expected = paceString(pace);
      test("$speed (Elliptical) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.Elliptical), expected);
      });
    }
  });

  group("speedStringByUnit for metric system and elliptical sports w slowSpeed:", () {
    final slowSpeed =
        PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(ActivityType.Elliptical)]!;
    for (final speed in speeds) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 60.0 / speed;
      final expected = speed < slowSpeed ? "0:00" : paceString(pace);
      test("$speed (Elliptical) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.Elliptical, limitSlowSpeed: true),
            expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and elliptical sports wo slowSpeed:", () {
    for (final speed in speeds) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 60.0 / speed / KM2MI;
      final expected = paceString(pace);
      test("$speed (Elliptical) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.Elliptical), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and elliptical sports w slowSpeed:", () {
    final slowSpeed =
        PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(ActivityType.Elliptical)]!;
    for (final speed in speeds) {
      final pace = speed.abs() < DISPLAY_EPS ? 0.0 : 60.0 / speed / KM2MI;
      final expected = speed < slowSpeed ? "0:00" : paceString(pace);
      test("$speed (Elliptical) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.Elliptical, limitSlowSpeed: true),
            expected);
      });
    }
  });
}
