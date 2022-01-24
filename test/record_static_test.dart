import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group("Record getBlank provides blank:", () {
    for (final sport in sports) {
      test("for $sport", () async {
        final blank = RecordWithSport.getBlank(sport);
        expect(blank.timeStamp, closeTo(DateTime.now().millisecondsSinceEpoch, 50));
        expect(blank.distance, closeTo(0.0, eps));
        expect(blank.elapsed, 0);
        expect(blank.calories, 0);
        expect(blank.power, 0);
        expect(blank.speed, closeTo(0.0, eps));
        expect(blank.cadence, 0);
        expect(blank.heartRate, 0);
        expect(blank.elapsedMillis, 0);
        expect(blank.sport, sport);
        expect(blank.pace, null);
        expect(blank.strokeCount, null);
        expect(blank.caloriesPerHour, null);
        expect(blank.caloriesPerMinute, null);
      });
    }
  });

  group("Record getRandom provides random:", () {
    final rnd = Random();
    for (final sport in sports) {
      test("for $sport", () async {
        final random = RecordWithSport.getRandom(sport, rnd);
        expect(random.timeStamp, closeTo(DateTime.now().millisecondsSinceEpoch, 50));
        expect(random.distance, null);
        expect(random.elapsed, null);
        expect(random.calories, inInclusiveRange(0, 1500));
        expect(random.power, inInclusiveRange(50, 550));
        expect(random.speed, inInclusiveRange(30.0, 40.0));
        expect(random.cadence, inInclusiveRange(30, 130));
        expect(random.heartRate, inInclusiveRange(60, 180));
        expect(random.elapsedMillis, null);
        expect(random.sport, sport);
        expect(random.pace, null);
        expect(random.strokeCount, null);
        expect(random.caloriesPerHour, null);
        expect(random.caloriesPerMinute, null);
      });
    }
  });
}
