import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

void main() {
  group('Record merge over nulls', () {
    final rnd = Random();
    for (final sport in allSports) {
      for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
        final rndDistance = rnd.nextDouble() * 1000;
        final rndElapsed = rnd.nextInt(600);
        final rndCaloriesPerMinute = rnd.nextDouble() * 12;
        final rndCaloriesPerHour = rnd.nextDouble() * 500;
        final rndPace = rnd.nextDouble() * 600;
        final rndRecord = RecordWithSport.getRandom(sport, rnd)
          ..pace = rndPace
          ..distance = rndDistance
          ..elapsed = rndElapsed
          ..caloriesPerMinute = rndCaloriesPerMinute
          ..caloriesPerHour = rndCaloriesPerHour;
        test(
            "$sport $idx: ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.pace} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
            () async {
          final blankRecord = RecordWithSport(sport: sport);
          final merged = blankRecord.merge(rndRecord);

          expect(merged.distance, closeTo(rndDistance, eps));
          expect(merged.elapsed, rndElapsed);
          expect(merged.calories, rndRecord.calories!);
          expect(merged.power, rndRecord.power);
          expect(merged.speed, closeTo(rndRecord.speed!, eps));
          expect(merged.pace, closeTo(rndRecord.pace!, eps));
          expect(merged.cadence, rndRecord.cadence);
          expect(merged.heartRate, rndRecord.heartRate!);
          expect(merged.caloriesPerMinute, rndRecord.caloriesPerMinute);
          expect(merged.caloriesPerHour, rndRecord.caloriesPerHour);
        });
      }
    }
  });

  group('Record does not merge over zeros', () {
    final rnd = Random();
    for (final sport in allSports) {
      for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
        final rndDistance = rnd.nextDouble() * 1000 + 1;
        final rndElapsed = rnd.nextInt(600) + 1;
        final rndCaloriesPerMinute = rnd.nextDouble() * 12 + 1;
        final rndCaloriesPerHour = rnd.nextDouble() * 500 + 1;
        final rndPace = rnd.nextDouble() * 600 + 1;
        final rndRecord = RecordWithSport.getRandom(sport, rnd)
          ..pace = rndPace
          ..distance = rndDistance
          ..elapsed = rndElapsed
          ..caloriesPerMinute = rndCaloriesPerMinute
          ..caloriesPerHour = rndCaloriesPerHour;
        test(
            "$sport $idx: ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.pace} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
            () async {
          final blankRecord = RecordWithSport.getZero(sport)
            ..caloriesPerHour = 0.0
            ..caloriesPerMinute = 0.0;
          final merged = blankRecord.merge(rndRecord);

          expect(merged.distance, closeTo(0.0, eps));
          expect(merged.elapsed, 0);
          expect(merged.calories, 0);
          expect(merged.power, 0);
          expect(merged.speed, closeTo(0.0, eps));
          expect(merged.pace, closeTo(sport == ActivityType.ride ? rndPace : 0.0, eps));
          expect(merged.cadence, 0);
          expect(merged.heartRate, 0);
          expect(merged.caloriesPerMinute, closeTo(0.0, eps));
          expect(merged.caloriesPerHour, closeTo(0.0, eps));
        });
      }
    }
  });

  group('Record merge does not override', () {
    final rnd = Random();
    for (final sport in allSports) {
      for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
        final rndDistance = rnd.nextDouble() * 1000;
        final rndElapsed = rnd.nextInt(600);
        final rndCaloriesPerMinute = rnd.nextDouble() * 12;
        final rndCaloriesPerHour = rnd.nextDouble() * 500;
        final rndPace = rnd.nextDouble() * 600;
        final rndRecord = RecordWithSport.getRandom(sport, rnd)
          ..pace = rndPace
          ..distance = rndDistance
          ..elapsed = rndElapsed
          ..caloriesPerMinute = rndCaloriesPerMinute
          ..caloriesPerHour = rndCaloriesPerHour;
        test(
            "$sport $idx: ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.pace} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
            () async {
          final targetDistance = rnd.nextDouble() * 1000;
          final targetElapsed = rnd.nextInt(600);
          final targetCaloriesPerMinute = rnd.nextDouble() * 12;
          final targetCaloriesPerHour = rnd.nextDouble() * 500;
          final targetPace = rnd.nextDouble() * 600 + 1;
          final targetRecord = RecordWithSport.getRandom(sport, rnd)
            ..pace = targetPace
            ..distance = targetDistance
            ..elapsed = targetElapsed
            ..caloriesPerMinute = targetCaloriesPerMinute
            ..caloriesPerHour = targetCaloriesPerHour;
          final merged = targetRecord.merge(rndRecord);

          expect(merged.distance, closeTo(targetDistance, eps));
          expect(merged.elapsed, targetElapsed);
          expect(merged.calories, targetRecord.calories!);
          expect(merged.power, targetRecord.power!);
          expect(merged.speed, closeTo(targetRecord.speed!, eps));
          expect(merged.pace, closeTo(targetRecord.pace!, eps));
          expect(merged.cadence, targetRecord.cadence!);
          expect(merged.heartRate, targetRecord.heartRate!);
          expect(merged.caloriesPerMinute, closeTo(targetCaloriesPerMinute, eps));
          expect(merged.caloriesPerHour, closeTo(targetCaloriesPerHour, eps));
        });
      }
    }
  });

  group('Record merge does not override with nulls', () {
    final rnd = Random();
    for (final sport in allSports) {
      for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
        final blankRecord = RecordWithSport(sport: sport);
        final rndDistance = rnd.nextDouble() * 1000;
        final rndElapsed = rnd.nextInt(600);
        final rndCaloriesPerMinute = rnd.nextDouble() * 12;
        final rndCaloriesPerHour = rnd.nextDouble() * 500;
        final rndPace = rnd.nextDouble() * 600;
        final targetRecord = RecordWithSport.getRandom(sport, rnd)
          ..pace = rndPace
          ..distance = rndDistance
          ..elapsed = rndElapsed
          ..caloriesPerMinute = rndCaloriesPerMinute
          ..caloriesPerHour = rndCaloriesPerHour;
        test(
            "$sport $idx: ${targetRecord.calories} ${targetRecord.power} ${targetRecord.speed} ${targetRecord.pace} ${targetRecord.cadence} ${targetRecord.heartRate} ${targetRecord.distance} ${targetRecord.elapsed}",
            () async {
          final merged = targetRecord.merge(blankRecord);

          expect(merged.distance, closeTo(rndDistance, eps));
          expect(merged.elapsed, rndElapsed);
          expect(merged.calories, targetRecord.calories!);
          expect(merged.power, targetRecord.power!);
          expect(merged.speed, closeTo(targetRecord.speed!, eps));
          expect(merged.pace, closeTo(targetRecord.pace!, eps));
          expect(merged.cadence, targetRecord.cadence!);
          expect(merged.heartRate, targetRecord.heartRate!);
          expect(merged.caloriesPerMinute, closeTo(rndCaloriesPerMinute, eps));
          expect(merged.caloriesPerHour, closeTo(rndCaloriesPerHour, eps));
        });
      }
    }
  });

  group('Record merge does not override with zeros', () {
    final rnd = Random();
    for (final sport in allSports) {
      for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
        final blankRecord = RecordWithSport.getZero(sport)
          ..caloriesPerHour = 0.0
          ..caloriesPerMinute = 0.0;
        final rndDistance = rnd.nextDouble() * 1000;
        final rndElapsed = rnd.nextInt(600);
        final rndCaloriesPerMinute = rnd.nextDouble() * 12;
        final rndCaloriesPerHour = rnd.nextDouble() * 500;
        final rndPace = rnd.nextDouble() * 600;
        final targetRecord = RecordWithSport.getRandom(sport, rnd)
          ..pace = rndPace
          ..distance = rndDistance
          ..elapsed = rndElapsed
          ..caloriesPerMinute = rndCaloriesPerMinute
          ..caloriesPerHour = rndCaloriesPerHour;
        test(
            "$sport $idx: ${targetRecord.calories} ${targetRecord.power} ${targetRecord.speed} ${targetRecord.pace} ${targetRecord.cadence} ${targetRecord.heartRate} ${targetRecord.distance} ${targetRecord.elapsed}",
            () async {
          final merged = targetRecord.merge(blankRecord);

          expect(merged.distance, closeTo(rndDistance, eps));
          expect(merged.elapsed, rndElapsed);
          expect(merged.calories, targetRecord.calories!);
          expect(merged.power, targetRecord.power!);
          expect(merged.speed, closeTo(targetRecord.speed!, eps));
          expect(merged.pace, closeTo(targetRecord.pace!, eps));
          expect(merged.cadence, targetRecord.cadence!);
          expect(merged.heartRate, targetRecord.heartRate!);
          expect(merged.caloriesPerMinute, closeTo(rndCaloriesPerMinute, eps));
          expect(merged.caloriesPerHour, closeTo(rndCaloriesPerHour, eps));
        });
      }
    }
  });
}
