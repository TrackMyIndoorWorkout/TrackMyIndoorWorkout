import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/floor/models/record.dart';
import 'package:track_my_indoor_exercise/preferences/log_level.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  group("Record distance enforcement survives nulls and zeros:", () {
    final distances = [
      [null, 0.0],
      [null, 111.0],
      [0.0, null],
      [111.0, null],
      [0.0, 0.0],
      [111.0, 0.0],
    ];
    for (var distancePair in distances) {
      test("${distancePair[0]}, ${distancePair[1]}", () async {
        final record = Record(distance: distancePair[0]);
        final lastRecord = Record(distance: distancePair[1]);

        record.cumulativeDistanceEnforcement(lastRecord, logLevelNone, false, false);

        expect(record.distance, distancePair[0]);
      });
    }
  });

  group("Forced Record distance enforcement survives nulls and zeros:", () {
    final distances = [
      [0.0, 0.0],
      [111.0, 111.0],
      [0.0, null],
      [111.0, null],
      [0.0, 0.0],
      [111.0, 0.0],
    ];
    for (var distancePair in distances) {
      test("${distancePair[0]}, ${distancePair[1]}", () async {
        final record = Record(distance: distancePair[0]);
        final lastRecord = Record(distance: distancePair[1]);

        record.cumulativeDistanceEnforcement(lastRecord, logLevelNone, false, true);

        expect(record.distance, closeTo(distancePair[0]!, eps));
      });
    }
  });

  group("Record distance enforcement makes sure it never decreases:", () {
    final rnd = Random();
    for (final meters in getRandomDoubles(repetition, 40000, rnd)) {
      final lastMeters = rnd.nextDouble() * 40000;
      test("$meters, $lastMeters", () async {
        final record = Record(distance: meters);
        final lastRecord = Record(distance: lastMeters);

        record.cumulativeDistanceEnforcement(lastRecord, logLevelNone, false, true);

        expect(record.distance, max(meters, lastMeters));
      });
    }
  });

  group("Record elapsed time enforcement survives nulls and zeros:", () {
    final elapsedTimes = [
      [null, 0],
      [null, 111],
      [0, null],
      [111, null],
      [0, 0],
      [111, 0],
    ];
    for (var elapsedTimePair in elapsedTimes) {
      test("${elapsedTimePair[0]}, ${elapsedTimePair[1]}", () async {
        final record = Record(elapsed: elapsedTimePair[0]);
        final lastRecord = Record(elapsed: elapsedTimePair[1]);

        record.cumulativeElapsedTimeEnforcement(lastRecord, logLevelNone, false, false);

        expect(record.elapsed, elapsedTimePair[0]);
      });
    }
  });

  group("Forced Record elapsed time enforcement survives nulls and zeros:", () {
    final elapsedTimes = [
      [0, 0],
      [111, 111],
      [0, null],
      [111, null],
      [0, 0],
      [111, 0],
    ];
    for (var elapsedTimePair in elapsedTimes) {
      test("${elapsedTimePair[0]}, ${elapsedTimePair[1]}", () async {
        final record = Record(elapsed: elapsedTimePair[0]);
        final lastRecord = Record(elapsed: elapsedTimePair[1]);

        record.cumulativeElapsedTimeEnforcement(lastRecord, logLevelNone, false, true);

        expect(record.elapsed, elapsedTimePair[0]);
      });
    }
  });

  group("Record elapsed time enforcement makes sure it never decreases:", () {
    final rnd = Random();
    for (final seconds in getRandomInts(repetition, 600, rnd)) {
      final lastElapsed = rnd.nextInt(600);
      test("$seconds, $lastElapsed", () async {
        final record = Record(elapsed: seconds);
        final lastRecord = Record(elapsed: lastElapsed);

        record.cumulativeElapsedTimeEnforcement(lastRecord, logLevelNone, false, true);

        expect(record.elapsed, max(seconds, lastElapsed));
      });
    }
  });

  group("Record moving time enforcement survives zeros:", () {
    final movingTimes = [
      [0, 0],
      [111, 0],
    ];
    for (var movingTimePair in movingTimes) {
      test("${movingTimePair[0]}, ${movingTimePair[1]}", () async {
        final record = Record()..movingTime = movingTimePair[0];
        final lastRecord = Record()..movingTime = movingTimePair[1];

        record.cumulativeMovingTimeEnforcement(lastRecord, logLevelNone, false);

        expect(record.movingTime, movingTimePair[0]);
      });
    }
  });

  group("Record moving time enforcement makes sure it never decreases:", () {
    final rnd = Random();
    for (final seconds in getRandomInts(repetition, 600000, rnd)) {
      final lastMoving = rnd.nextInt(600000);
      test("$seconds, $lastMoving", () async {
        final record = Record()..movingTime = seconds;
        final lastRecord = Record()..movingTime = lastMoving;

        record.cumulativeMovingTimeEnforcement(lastRecord, logLevelNone, false);

        expect(record.movingTime, max(seconds, lastMoving));
      });
    }
  });

  group("Record calories enforcement survives nulls and zeros:", () {
    final calories = [
      [null, 0],
      [null, 111],
      [0, null],
      [111, null],
      [0, 0],
      [111, 0],
    ];
    for (var caloriePair in calories) {
      test("${caloriePair[0]}, ${caloriePair[1]}", () async {
        final record = Record(calories: caloriePair[0]);
        final lastRecord = Record(calories: caloriePair[1]);

        record.cumulativeCaloriesEnforcement(lastRecord, logLevelNone, false, false);

        expect(record.calories, caloriePair[0]);
      });
    }
  });

  group("Forced Record calories enforcement survives nulls and zeros:", () {
    final calories = [
      [0, 0],
      [111, 111],
      [0, null],
      [111, null],
      [0, 0],
      [111, 0],
    ];
    for (var caloriePair in calories) {
      test("${caloriePair[0]}, ${caloriePair[1]}", () async {
        final record = Record(calories: caloriePair[0]);
        final lastRecord = Record(calories: caloriePair[1]);

        record.cumulativeCaloriesEnforcement(lastRecord, logLevelNone, false, true);

        expect(record.calories, caloriePair[0]);
      });
    }
  });

  group("Record calories enforcement makes sure it never decreases:", () {
    final rnd = Random();
    for (final calories in getRandomInts(repetition, 600, rnd)) {
      final lastCalories = rnd.nextInt(600);
      test("$calories, $lastCalories", () async {
        final record = Record(calories: calories);
        final lastRecord = Record(calories: lastCalories);

        record.cumulativeCaloriesEnforcement(lastRecord, logLevelNone, false, true);

        expect(record.calories, max(calories, lastCalories));
      });
    }
  });
}
