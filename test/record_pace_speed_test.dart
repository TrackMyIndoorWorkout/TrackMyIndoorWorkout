import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group("Record constructor fills speed properly if running pace is present:", () {
    final paces = [
      [0.0, 0.0],
      [3.0, 20.0],
      [3.2, 18.75],
      [3.5, 17.142857143],
      [4.0, 15],
      [4.5, 13.333333333],
      [4.8, 12.5],
      [5.0, 12.0],
      [5.5, 10.909090909],
      [6.0, 10.0],
      [6.5, 9.230769231],
      [8.0, 7.5],
      [10.0, 6.0],
      [12.0, 5.0],
      [15.0, 4.0],
    ];
    for (var pacePair in paces) {
      final expected = pacePair[1];
      for (var sport in [ActivityType.Run, ActivityType.VirtualRun]) {
        test("${pacePair[0]} -> $expected", () async {
          expect(RecordWithSport(pace: pacePair[0], sport: sport).speed, closeTo(expected, EPS));
        });
      }
    }
  });

  group("Record constructor fills speed properly if random running pace is present:", () {
    final rnd = Random();
    1.to(REPETITION).forEach((input) {
      final randomPace = rnd.nextDouble() * 20;
      final expected = 60 / randomPace;
      for (var sport in [ActivityType.Run, ActivityType.VirtualRun]) {
        test("$randomPace -> $expected", () async {
          expect(RecordWithSport(pace: randomPace, sport: sport).speed, closeTo(expected, EPS));
        });
      }
    });
  });

  group("Record constructor fills speed properly if paddling pace is present:", () {
    final paces = [
      [0.0, 0.0],
      [120.0, 15.0],
      [132.0, 13.636363637],
      [150.0, 12.0],
      [180.0, 10.0],
      [192.0, 9.375],
      [210.0, 8.571428572],
      [240.0, 7.5],
      [270.0, 6.666666667],
      [288.0, 6.25],
      [300.0, 6.0],
      [360.0, 5.0],
    ];
    for (var pacePair in paces) {
      final expected = pacePair[1];
      for (var sport in [ActivityType.Kayaking, ActivityType.Canoeing, ActivityType.Rowing]) {
        test("${pacePair[0]} -> $expected", () async {
          expect(RecordWithSport(pace: pacePair[0], sport: sport).speed, closeTo(expected, EPS));
        });
      }
    }
  });

  group("Record constructor fills speed properly if random paddling pace is present:", () {
    final rnd = Random();
    1.to(REPETITION).forEach((input) {
      final randomPace = rnd.nextDouble() * 360;
      final expected = 30.0 / (randomPace / 60.0);
      for (var sport in [ActivityType.Kayaking, ActivityType.Canoeing, ActivityType.Rowing]) {
        test("$randomPace -> $expected", () async {
          expect(RecordWithSport(pace: randomPace, sport: sport).speed, closeTo(expected, EPS));
        });
      }
    });
  });
}
