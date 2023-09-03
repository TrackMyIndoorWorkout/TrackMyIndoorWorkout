import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/preferences/speed_spec.dart';
import 'package:track_my_indoor_exercise/preferences/sport_spec.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';
import 'package:tuple/tuple.dart';

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

  // 6mph = 10 min/mi = 9.656 kmh
  final sixMphSpeeds = [
    9.65606,
    9.656,
    9.66,
  ];

  final minPerMileMilesPerHours = [
    const Tuple2<String, double>("15:00", 4.00),
    const Tuple2<String, double>("14:49", 4.05),
    const Tuple2<String, double>("14:38", 4.10),
    const Tuple2<String, double>("14:27", 4.15),
    const Tuple2<String, double>("14:17", 4.20),
    const Tuple2<String, double>("14:07", 4.25),
    const Tuple2<String, double>("13:57", 4.30),
    const Tuple2<String, double>("13:48", 4.35),
    const Tuple2<String, double>("13:38", 4.40),
    const Tuple2<String, double>("13:29", 4.45),
    const Tuple2<String, double>("13:20", 4.50),
    const Tuple2<String, double>("13:11", 4.55),
    const Tuple2<String, double>("13:03", 4.60),
    const Tuple2<String, double>("12:54", 4.65),
    const Tuple2<String, double>("12:46", 4.70),
    const Tuple2<String, double>("12:38", 4.75),
    const Tuple2<String, double>("12:30", 4.80),
    const Tuple2<String, double>("12:22", 4.85),
    const Tuple2<String, double>("12:15", 4.90),
    const Tuple2<String, double>("12:07", 4.95),
    const Tuple2<String, double>("12:00", 5.00),
    const Tuple2<String, double>("11:53", 5.05),
    const Tuple2<String, double>("11:46", 5.10),
    const Tuple2<String, double>("11:39", 5.15),
    const Tuple2<String, double>("11:32", 5.20),
    const Tuple2<String, double>("11:26", 5.25),
    const Tuple2<String, double>("11:19", 5.30),
    const Tuple2<String, double>("11:13", 5.35),
    const Tuple2<String, double>("11:07", 5.40),
    const Tuple2<String, double>("11:01", 5.45),
    const Tuple2<String, double>("10:55", 5.50),
    const Tuple2<String, double>("10:49", 5.55),
    const Tuple2<String, double>("10:43", 5.60),
    const Tuple2<String, double>("10:37", 5.65),
    const Tuple2<String, double>("10:32", 5.70),
    const Tuple2<String, double>("10:26", 5.75),
    const Tuple2<String, double>("10:21", 5.80),
    const Tuple2<String, double>("10:15", 5.85),
    const Tuple2<String, double>("10:10", 5.90),
    const Tuple2<String, double>("10:05", 5.95),
    const Tuple2<String, double>("10:00", 6.00),
    const Tuple2<String, double>("9:55", 6.05),
    const Tuple2<String, double>("9:50", 6.10),
    const Tuple2<String, double>("9:45", 6.15),
    const Tuple2<String, double>("9:41", 6.20),
    const Tuple2<String, double>("9:36", 6.25),
    const Tuple2<String, double>("9:31", 6.30),
    const Tuple2<String, double>("9:27", 6.35),
    const Tuple2<String, double>("9:23", 6.40),
    const Tuple2<String, double>("9:18", 6.45),
    const Tuple2<String, double>("9:14", 6.50),
    const Tuple2<String, double>("9:10", 6.55),
    const Tuple2<String, double>("9:05", 6.60),
    const Tuple2<String, double>("9:01", 6.65),
    const Tuple2<String, double>("8:57", 6.70),
    const Tuple2<String, double>("8:53", 6.75),
    const Tuple2<String, double>("8:49", 6.80),
    const Tuple2<String, double>("8:46", 6.85),
    const Tuple2<String, double>("8:42", 6.90),
    const Tuple2<String, double>("8:38", 6.95),
    const Tuple2<String, double>("8:34", 7.00),
    const Tuple2<String, double>("8:31", 7.05),
    const Tuple2<String, double>("8:27", 7.10),
    const Tuple2<String, double>("8:23", 7.15),
    const Tuple2<String, double>("8:20", 7.20),
    const Tuple2<String, double>("8:17", 7.25),
    const Tuple2<String, double>("8:13", 7.30),
    const Tuple2<String, double>("8:10", 7.35),
    const Tuple2<String, double>("8:06", 7.40),
    const Tuple2<String, double>("8:03", 7.45),
    const Tuple2<String, double>("8:00", 7.50),
    const Tuple2<String, double>("7:57", 7.55),
    const Tuple2<String, double>("7:54", 7.60),
    const Tuple2<String, double>("7:51", 7.65),
    const Tuple2<String, double>("7:48", 7.70),
    const Tuple2<String, double>("7:45", 7.75),
    const Tuple2<String, double>("7:42", 7.80),
    const Tuple2<String, double>("7:39", 7.85),
    const Tuple2<String, double>("7:36", 7.90),
    const Tuple2<String, double>("7:33", 7.95),
    const Tuple2<String, double>("7:30", 8.00),
    const Tuple2<String, double>("7:27", 8.05),
    const Tuple2<String, double>("7:24", 8.10),
    const Tuple2<String, double>("7:22", 8.15),
    const Tuple2<String, double>("7:19", 8.20),
    const Tuple2<String, double>("7:16", 8.25),
    const Tuple2<String, double>("7:14", 8.30),
    const Tuple2<String, double>("7:11", 8.35),
    const Tuple2<String, double>("7:09", 8.40),
    const Tuple2<String, double>("7:06", 8.45),
    const Tuple2<String, double>("7:04", 8.50),
    const Tuple2<String, double>("7:01", 8.55),
    const Tuple2<String, double>("6:59", 8.60),
    const Tuple2<String, double>("6:56", 8.65),
    const Tuple2<String, double>("6:54", 8.70),
    const Tuple2<String, double>("6:51", 8.75),
    const Tuple2<String, double>("6:49", 8.80),
    const Tuple2<String, double>("6:47", 8.85),
    const Tuple2<String, double>("6:44", 8.90),
    const Tuple2<String, double>("6:42", 8.95),
    const Tuple2<String, double>("6:40", 9.00),
    const Tuple2<String, double>("6:38", 9.05),
    const Tuple2<String, double>("6:36", 9.10),
    const Tuple2<String, double>("6:33", 9.15),
    const Tuple2<String, double>("6:31", 9.20),
    const Tuple2<String, double>("6:29", 9.25),
    const Tuple2<String, double>("6:27", 9.30),
    const Tuple2<String, double>("6:25", 9.35),
    const Tuple2<String, double>("6:23", 9.40),
    const Tuple2<String, double>("6:21", 9.45),
    const Tuple2<String, double>("6:19", 9.50),
    const Tuple2<String, double>("6:17", 9.55),
    const Tuple2<String, double>("6:15", 9.60),
    const Tuple2<String, double>("6:13", 9.65),
    const Tuple2<String, double>("6:11", 9.70),
    const Tuple2<String, double>("6:09", 9.75),
    const Tuple2<String, double>("6:07", 9.80),
    const Tuple2<String, double>("6:05", 9.85),
    const Tuple2<String, double>("6:04", 9.90),
    const Tuple2<String, double>("6:02", 9.95),
    const Tuple2<String, double>("6:00", 10.00),
    const Tuple2<String, double>("5:58", 10.05),
    const Tuple2<String, double>("5:56", 10.10),
    const Tuple2<String, double>("5:55", 10.15),
    const Tuple2<String, double>("5:53", 10.20),
    const Tuple2<String, double>("5:51", 10.25),
    const Tuple2<String, double>("5:50", 10.30),
    const Tuple2<String, double>("5:48", 10.35),
    const Tuple2<String, double>("5:46", 10.40),
    const Tuple2<String, double>("5:44", 10.45),
    const Tuple2<String, double>("5:43", 10.50),
    const Tuple2<String, double>("5:41", 10.55),
    const Tuple2<String, double>("5:40", 10.60),
    const Tuple2<String, double>("5:38", 10.65),
    const Tuple2<String, double>("5:36", 10.70),
    const Tuple2<String, double>("5:35", 10.75),
    const Tuple2<String, double>("5:33", 10.80),
    const Tuple2<String, double>("5:32", 10.85),
    const Tuple2<String, double>("5:30", 10.90),
    const Tuple2<String, double>("5:29", 10.95),
    const Tuple2<String, double>("5:27", 11.00),
    const Tuple2<String, double>("5:26", 11.05),
    const Tuple2<String, double>("5:24", 11.10),
    const Tuple2<String, double>("5:23", 11.15),
    const Tuple2<String, double>("5:21", 11.20),
    const Tuple2<String, double>("5:20", 11.25),
    const Tuple2<String, double>("5:19", 11.30),
    const Tuple2<String, double>("5:17", 11.35),
    const Tuple2<String, double>("5:16", 11.40),
    const Tuple2<String, double>("5:14", 11.45),
    const Tuple2<String, double>("5:13", 11.50),
    const Tuple2<String, double>("5:12", 11.55),
    const Tuple2<String, double>("5:10", 11.60),
    const Tuple2<String, double>("5:09", 11.65),
    const Tuple2<String, double>("5:08", 11.70),
    const Tuple2<String, double>("5:06", 11.75),
    const Tuple2<String, double>("5:05", 11.80),
    const Tuple2<String, double>("5:04", 11.85),
    const Tuple2<String, double>("5:03", 11.90),
    const Tuple2<String, double>("5:01", 11.95),
    const Tuple2<String, double>("5:00", 12.00),
    const Tuple2<String, double>("4:59", 12.05),
    const Tuple2<String, double>("4:58", 12.10),
    const Tuple2<String, double>("4:56", 12.15),
    const Tuple2<String, double>("4:55", 12.20),
    const Tuple2<String, double>("4:54", 12.25),
    const Tuple2<String, double>("4:53", 12.30),
    const Tuple2<String, double>("4:51", 12.35),
    const Tuple2<String, double>("4:50", 12.40),
    const Tuple2<String, double>("4:49", 12.45),
    const Tuple2<String, double>("4:48", 12.50),
    const Tuple2<String, double>("4:47", 12.55),
    const Tuple2<String, double>("4:46", 12.60),
    const Tuple2<String, double>("4:45", 12.65),
    const Tuple2<String, double>("4:43", 12.70),
    const Tuple2<String, double>("4:42", 12.75),
    const Tuple2<String, double>("4:41", 12.80),
    const Tuple2<String, double>("4:40", 12.85),
    const Tuple2<String, double>("4:39", 12.90),
    const Tuple2<String, double>("4:38", 12.95),
    const Tuple2<String, double>("4:37", 13.00),
    const Tuple2<String, double>("4:36", 13.05),
    const Tuple2<String, double>("4:35", 13.10),
    const Tuple2<String, double>("4:34", 13.15),
    const Tuple2<String, double>("4:33", 13.20),
    const Tuple2<String, double>("4:32", 13.25),
    const Tuple2<String, double>("4:31", 13.30),
    const Tuple2<String, double>("4:30", 13.35),
    const Tuple2<String, double>("4:29", 13.40),
    const Tuple2<String, double>("4:28", 13.45),
    const Tuple2<String, double>("4:27", 13.50),
    const Tuple2<String, double>("4:26", 13.55),
    const Tuple2<String, double>("4:25", 13.60),
    const Tuple2<String, double>("4:24", 13.65),
    const Tuple2<String, double>("4:23", 13.70),
    const Tuple2<String, double>("4:22", 13.75),
    const Tuple2<String, double>("4:21", 13.80),
    const Tuple2<String, double>("4:20", 13.85),
    const Tuple2<String, double>("4:19", 13.90),
    const Tuple2<String, double>("4:18", 13.95),
    const Tuple2<String, double>("4:17", 14.00),
  ];

  group("speedStringByUnit for metric system and riding:", () {
    for (final speed in speeds) {
      final expected = speed.toStringAsFixed(2);
      test("$speed (Ride wo slowSpeed) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.ride), expected);
      });

      test("$speed (Ride w slowSpeed) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.ride, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and riding:", () {
    for (final speed in speeds) {
      final expected = (speed * km2miDisp).toStringAsFixed(2);
      test("$speed (Ride wo slowSpeed) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.ride), expected);
      });

      test("$speed (Ride w slowSpeed) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.ride, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for metric system and running wo slowSpeed:", () {
    for (final speed in speeds) {
      final pace = speed.abs() < displayEps ? 0.0 : 60.0 / speed;
      final expected = paceString(pace);
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.run), expected);
      });
    }
  });

  group("speedStringByUnit for metric system and running w slowSpeed:", () {
    final slowSpeed = SpeedSpec.slowSpeeds[SportSpec.sport2Sport(ActivityType.run)]!;
    for (final speed in speeds) {
      final pace = speed.abs() < displayEps ? 0.0 : 60.0 / speed;
      final expected = speed < slowSpeed ? "0:00" : paceString(pace);
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.run, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and running wo slowSpeed:", () {
    for (final speed in speeds) {
      final pace = speed.abs() < displayEps ? 0.0 : 60.0 / speed / km2miDisp;
      final expected = paceString(pace);
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.run), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and running w slowSpeed:", () {
    final slowSpeed = SpeedSpec.slowSpeeds[SportSpec.sport2Sport(ActivityType.run)]!;
    for (final speed in speeds) {
      final pace = speed.abs() < displayEps ? 0.0 : 60.0 / speed / km2miDisp;
      final expected = speed < slowSpeed ? "0:00" : paceString(pace);
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.run, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and running w 6 mph:", () {
    for (final speed in sixMphSpeeds) {
      const expected = "10:00";
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.run, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and running:", () {
    for (final minPerMileMilesPerHour in minPerMileMilesPerHours) {
      final speed = minPerMileMilesPerHour.item2;
      final pace = 60.0 / speed;
      final expected = minPerMileMilesPerHour.item1;
      test("$speed | $pace (Run) -> $expected", () async {
        expect(speedOrPaceString(speed / km2mi, false, ActivityType.run, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and running w 6 mph:", () {
    for (final speed in sixMphSpeeds) {
      const expected = "10:00";
      test("$speed (Run) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.run, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and running:", () {
    for (final minPerMileMilesPerHour in minPerMileMilesPerHours) {
      final speed = minPerMileMilesPerHour.item2;
      final pace = 60.0 / speed;
      final expected = minPerMileMilesPerHour.item1;
      test("$speed | $pace (Run) -> $expected", () async {
        expect(speedOrPaceString(speed / km2mi, false, ActivityType.run, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for paddle sports wo slowSpeed:", () {
    final sports = [ActivityType.kayaking, ActivityType.canoeing, ActivityType.rowing];
    for (final speed in speeds) {
      for (final sport in sports) {
        final pace = speed.abs() < displayEps ? 0.0 : 30.0 / speed;
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
    final sports = [ActivityType.kayaking, ActivityType.canoeing, ActivityType.rowing];
    final slowSpeed = SpeedSpec.slowSpeeds[SportSpec.paddleSport]!;
    for (final speed in speeds) {
      for (final sport in sports) {
        final pace = speed.abs() < displayEps ? 0.0 : 30.0 / speed;
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
      final pace = speed.abs() < displayEps ? 0.0 : 6.0 / speed;
      final expected = paceString(pace);
      test("$speed (Swim) -> $expected", () async {
        // There's no imperial for water sports, it's always 100m
        expect(speedOrPaceString(speed, false, ActivityType.swim), expected);
        expect(speedOrPaceString(speed, true, ActivityType.swim), expected);
      });
    }
  });

  group("speedStringByUnit for swimming w slowSpeed:", () {
    final slowSpeed = SpeedSpec.slowSpeeds[SportSpec.sport2Sport(ActivityType.swim)]!;
    for (final speed in speeds) {
      final pace = speed.abs() < displayEps ? 0.0 : 6.0 / speed;
      final expected = speed < slowSpeed ? "0:00" : paceString(pace);
      test("$speed (Swim) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.swim, limitSlowSpeed: true), expected);
        expect(speedOrPaceString(speed, true, ActivityType.swim, limitSlowSpeed: true), expected);
      });
    }
  });

  group("speedStringByUnit for metric system and elliptical sports wo slowSpeed:", () {
    for (final speed in speeds) {
      final pace = speed.abs() < displayEps ? 0.0 : 60.0 / speed;
      final expected = paceString(pace);
      test("$speed (Elliptical) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.elliptical), expected);
      });
    }
  });

  group("speedStringByUnit for metric system and elliptical sports w slowSpeed:", () {
    final slowSpeed = SpeedSpec.slowSpeeds[SportSpec.sport2Sport(ActivityType.elliptical)]!;
    for (final speed in speeds) {
      final pace = speed.abs() < displayEps ? 0.0 : 60.0 / speed;
      final expected = speed < slowSpeed ? "0:00" : paceString(pace);
      test("$speed (Elliptical) -> $expected", () async {
        expect(speedOrPaceString(speed, true, ActivityType.elliptical, limitSlowSpeed: true),
            expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and elliptical sports wo slowSpeed:", () {
    for (final speed in speeds) {
      final pace = speed.abs() < displayEps ? 0.0 : 60.0 / speed / km2miDisp;
      final expected = paceString(pace);
      test("$speed (Elliptical) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.elliptical), expected);
      });
    }
  });

  group("speedStringByUnit for imperial system and elliptical sports w slowSpeed:", () {
    final slowSpeed = SpeedSpec.slowSpeeds[SportSpec.sport2Sport(ActivityType.elliptical)]!;
    for (final speed in speeds) {
      final pace = speed.abs() < displayEps ? 0.0 : 60.0 / speed / km2miDisp;
      final expected = speed < slowSpeed ? "0:00" : paceString(pace);
      test("$speed (Elliptical) -> $expected", () async {
        expect(speedOrPaceString(speed, false, ActivityType.elliptical, limitSlowSpeed: true),
            expected);
      });
    }
  });
}
