import 'package:flutter_test/flutter_test.dart';
import '../lib/persistence/models/record.dart';
import '../lib/persistence/preferences.dart';
import '../lib/tcx/activity_type.dart';

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
    final sports = [ActivityType.Ride, ActivityType.VirtualRide];
    speeds.forEach((speed) {
      sports.forEach((sport) {
        final expected = speed.toStringAsFixed(2);
        test("$speed ($sport) -> $expected", () {
          final record = Record(speed: speed, sport: sport);
          expect(record.speedStringByUnit(true, sport), expected);
        });
      });
    });
  });

  group("speedStringByUnit for imperial system and riding:", () {
    final sports = [ActivityType.Ride, ActivityType.VirtualRide];
    speeds.forEach((speed) {
      sports.forEach((sport) {
        final expected = (speed * KM2MI).toStringAsFixed(2);
        test("$speed ($sport) -> $expected", () {
          final record = Record(speed: speed, sport: sport);
          expect(record.speedStringByUnit(false, sport), expected);
        });
      });
    });
  });

  group("speedStringByUnit for metric system and running:", () {
    final sports = [ActivityType.Run, ActivityType.VirtualRun];
    speeds.forEach((speed) {
      sports.forEach((sport) {
        final pace = speed.abs() < 10e-4 ? 0.0 : 60.0 / speed;
        final expected = Record.paceString(pace);
        // final expected
        test("$speed ($sport) -> $expected", () {
          final record = Record(speed: speed, sport: sport);
          expect(record.speedStringByUnit(true, sport), expected);
        });
      });
    });
  });

  group("speedStringByUnit for imperial system and running:", () {
    final sports = [ActivityType.Run, ActivityType.VirtualRun];
    speeds.forEach((speed) {
      sports.forEach((sport) {
        final pace = speed.abs() < 10e-4 ? 0.0 : 60.0 / speed / KM2MI;
        final expected = Record.paceString(pace);
        test("$speed ($sport) -> $expected", () {
          final record = Record(speed: speed, sport: sport);
          expect(record.speedStringByUnit(false, sport), expected);
        });
      });
    });
  });

  group("speedStringByUnit for water sports:", () {
    final sports = [ActivityType.Kayaking, ActivityType.Canoeing, ActivityType.Rowing];
    speeds.forEach((speed) {
      sports.forEach((sport) {
        final pace = speed.abs() < 10e-4 ? 0.0 : 30.0 / speed;
        final expected = Record.paceString(pace);
        test("$speed ($sport) -> $expected", () {
          final record = Record(speed: speed, sport: sport);
          // There's no imperial for water sports, it's always 500m
          expect(record.speedStringByUnit(false, sport), expected);
          expect(record.speedStringByUnit(true, sport), expected);
        });
      });
    });
  });

  group("speedStringByUnit for elliptical sports:", () {
    speeds.forEach((speed) {
      final expected = speed.toStringAsFixed(2);
      test("$speed (Elliptical) -> $expected", () {
        final record = Record(speed: speed, sport: ActivityType.Elliptical);
        // There's no imperial for water sports, it's always 500m
        expect(record.speedStringByUnit(false, ActivityType.Elliptical), expected);
        expect(record.speedStringByUnit(true, ActivityType.Elliptical), expected);
      });
    });
  });
}
