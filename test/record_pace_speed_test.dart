import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/tcx/activity_type.dart';
import '../lib/persistence/models/record.dart';
import 'utils.dart';

String paceString(double pace) {
  final minutes = pace.truncate();
  final seconds = ((pace - minutes) * 60.0).truncate();
  return "$minutes:" + seconds.toString().padLeft(2, "0");
}

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
    paces.forEach((pacePair) {
      final expected = pacePair[1];
      [ActivityType.Run, ActivityType.VirtualRun].forEach((sport) {
        test("${pacePair[0]} -> $expected", () {
          expect(Record(pace: pacePair[0], sport: sport).speed, closeTo(expected, 1e-6));
        });
      });
    });
  });

  group("Record constructor fills speed properly if random running pace is present:", () {
    final rnd = Random();
    1.to(REPETITION).forEach((input) {
      final randomPace = rnd.nextDouble() * 20;
      final expected = 60 / randomPace;
      [ActivityType.Run, ActivityType.VirtualRun].forEach((sport) {
        test("$randomPace -> $expected", () {
          expect(Record(pace: randomPace, sport: sport).speed, closeTo(expected, 1e-6));
        });
      });
    });
  });
}
