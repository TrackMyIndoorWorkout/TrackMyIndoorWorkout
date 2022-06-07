import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

void main() {
  group("RecordWithSport null by default:", () {
    for (final sport in allSports) {
      test("for $sport", () async {
        final blank = RecordWithSport(sport: sport);
        expect(blank.timeStamp, closeTo(DateTime.now().millisecondsSinceEpoch, 50));
        expect(blank.distance, null);
        expect(blank.elapsed, null);
        expect(blank.calories, null);
        expect(blank.power, null);
        expect(blank.speed, null);
        expect(blank.cadence, null);
        expect(blank.heartRate, null);
        expect(blank.elapsedMillis, null);
        expect(blank.sport, sport);
        expect(blank.pace, null);
        expect(blank.strokeCount, null);
        expect(blank.caloriesPerHour, null);
        expect(blank.caloriesPerMinute, null);
      });
    }
  });

  group("Record getBlank provides blank:", () {
    for (final sport in allSports) {
      test("for $sport", () async {
        final blank = RecordWithSport.getZero(sport);
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
    for (final sport in allSports) {
      test("for $sport", () async {
        final speedLow = sport == ActivityType.run ? 8.0 : 30.0;
        final speedHigh = sport == ActivityType.run ? 20.0 : 40.0;
        final random = RecordWithSport.getRandom(sport, rnd);
        expect(random.timeStamp, closeTo(DateTime.now().millisecondsSinceEpoch, 50));
        expect(random.distance, null);
        expect(random.elapsed, null);
        expect(random.calories, inInclusiveRange(0, 1500));
        expect(random.power, inInclusiveRange(50, 550));
        expect(random.speed, inInclusiveRange(speedLow, speedHigh));
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
