import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

void main() {
  final speeds = [0.0, 0.2, 0.3, 0.5, 1.0, 1.2, 1.3, 1.5, 2.0, 5.0, 10.0, 12.0, 15.0, 20.0];
  group("speedOrPace for metric system and riding:", () {
    for (final speed in speeds) {
      final expected = speed;
      test("$speed (Ride) -> $expected", () async {
        expect(speedOrPace(speed, true, ActivityType.ride), expected);
      });
    }
  });

  group("speedOrPace for imperial system and riding:", () {
    for (final speed in speeds) {
      final expected = speed * km2mi;
      test("$speed (Ride) -> $expected", () async {
        expect(speedOrPace(speed, false, ActivityType.ride), expected);
      });
    }
  });

  group("speedOrPace for metric system and running:", () {
    for (final speed in speeds) {
      final expected = speed.abs() < displayEps ? 0.0 : 60.0 / speed;
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPace(speed, true, ActivityType.run), expected);
      });
    }
  });

  group("speedOrPace for imperial system and running:", () {
    for (final speed in speeds) {
      final expected = speed.abs() < displayEps ? 0.0 : 60.0 / speed / km2mi;
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPace(speed, false, ActivityType.run), expected);
      });
    }
  });

  group("speedOrPace for paddle sports:", () {
    final sports = [ActivityType.kayaking, ActivityType.canoeing, ActivityType.rowing];
    for (final speed in speeds) {
      for (final sport in sports) {
        final expected = speed.abs() < displayEps ? 0.0 : 30.0 / speed;
        test("$speed ($sport) -> $expected", () async {
          // There's no imperial for water sports, it's always 500m
          expect(speedOrPace(speed, false, sport), expected);
          expect(speedOrPace(speed, true, sport), expected);
        });
      }
    }
  });

  group("speedOrPace for metric system and swimming:", () {
    for (final speed in speeds) {
      final expected = speed.abs() < displayEps ? 0.0 : 6.0 / speed;
      test("$speed (Swim) -> $expected", () async {
        expect(speedOrPace(speed, false, ActivityType.swim), expected);
        expect(speedOrPace(speed, true, ActivityType.swim), expected);
      });
    }
  });

  group("speedOrPace for metric system and elliptical:", () {
    for (final speed in speeds) {
      final expected = speed.abs() < displayEps ? 0.0 : 60.0 / speed;
      test("$speed (Elliptical) -> $expected", () async {
        expect(speedOrPace(speed, true, ActivityType.elliptical), expected);
      });
    }
  });

  group("speedOrPace for imperial system and elliptical:", () {
    for (final speed in speeds) {
      final expected = speed.abs() < displayEps ? 0.0 : 60.0 / speed / km2mi;
      test("$speed (Elliptical) -> $expected", () async {
        expect(speedOrPace(speed, false, ActivityType.elliptical), expected);
      });
    }
  });
}
