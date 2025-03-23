import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

void main() {
  group('Record merges best over nulls', () {
    final rnd = Random();
    for (final sport in allSports) {
      for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
        final rndDistance = rnd.nextDouble() * 1000;
        final rndElapsed = rnd.nextInt(600);
        final rndCaloriesPerMinute = rnd.nextDouble() * 12;
        final rndCaloriesPerHour = rnd.nextDouble() * 500;
        final rndPace = rnd.nextDouble() * 600;
        final rndRecord =
            RecordWithSport.getRandom(sport, rnd)
              ..pace = rndPace
              ..distance = rndDistance
              ..elapsed = rndElapsed
              ..caloriesPerMinute = rndCaloriesPerMinute
              ..caloriesPerHour = rndCaloriesPerHour;
        test(
          "$sport $idx: ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.pace} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
          () async {
            final blankRecord = RecordWithSport(sport: sport);
            final merged = blankRecord.mergeBest(rndRecord);

            expect(merged.distance, closeTo(rndDistance, eps));
            expect(merged.elapsed, rndElapsed);
            expect(merged.calories, rndRecord.calories!);
            expect(merged.power, rndRecord.power);
            expect(merged.speed, closeTo(rndRecord.speed!, eps));
            expect(merged.pace, closeTo(rndRecord.pace!, eps));
            expect(merged.cadence, rndRecord.cadence);
            expect(merged.heartRate, rndRecord.heartRate!);
            expect(merged.caloriesPerMinute, merged.caloriesPerMinute);
            expect(merged.caloriesPerHour, merged.caloriesPerHour);
          },
        );
      }
    }
  });

  group('Record merge best does not merge over zeros', () {
    final rnd = Random();
    for (final sport in allSports) {
      for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
        final rndDistance = rnd.nextDouble() * 1000 + 1;
        final rndElapsed = rnd.nextInt(600) + 1;
        final rndCaloriesPerMinute = rnd.nextDouble() * 12 + 1;
        final rndCaloriesPerHour = rnd.nextDouble() * 500 + 1;
        final rndPace = rnd.nextDouble() * 600 + 1;
        final rndRecord =
            RecordWithSport.getRandom(sport, rnd)
              ..pace = rndPace
              ..distance = rndDistance
              ..elapsed = rndElapsed
              ..caloriesPerMinute = rndCaloriesPerMinute
              ..caloriesPerHour = rndCaloriesPerHour;
        test(
          "$sport $idx: ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.pace} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
          () async {
            final blankRecord =
                RecordWithSport.getZero(sport)
                  ..caloriesPerHour = 0.0
                  ..caloriesPerMinute = 0.0;
            final merged = blankRecord.mergeBest(rndRecord);

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
          },
        );
      }
    }
  });

  group('Record merge best overrides with best', () {
    final rnd = Random();
    for (final sport in allSports) {
      for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
        final rndDistance = rnd.nextDouble() * 1000 + 1;
        final rndElapsed = rnd.nextInt(600) + 1;
        final rndCaloriesPerMinute = rnd.nextDouble() * 12 + 1;
        final rndCaloriesPerHour = rnd.nextDouble() * 500 + 1;
        final rndPace = rnd.nextDouble() * 600 + 1;
        final rndRecord =
            RecordWithSport.getRandom(sport, rnd)
              ..pace = rndPace
              ..distance = rndDistance
              ..elapsed = rndElapsed
              ..caloriesPerMinute = rndCaloriesPerMinute
              ..caloriesPerHour = rndCaloriesPerHour;
        test(
          "$sport $idx: ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.pace} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
          () async {
            final targetDistance = rnd.nextDouble() * 1000 + 1;
            final targetElapsed = rnd.nextInt(600) + 1;
            final targetCaloriesPerMinute = rnd.nextDouble() * 12 + 1;
            final targetCaloriesPerHour = rnd.nextDouble() * 500 + 1;
            final targetPace = rnd.nextDouble() * 600 + 1;
            final targetRecord =
                RecordWithSport.getRandom(sport, rnd)
                  ..pace = targetPace
                  ..distance = targetDistance
                  ..elapsed = targetElapsed
                  ..caloriesPerMinute = targetCaloriesPerMinute
                  ..caloriesPerHour = targetCaloriesPerHour;
            final merged = targetRecord.mergeBest(rndRecord);

            expect(merged.distance, closeTo(max(rndDistance, targetDistance), eps));
            expect(merged.elapsed, max(rndElapsed, targetElapsed));
            expect(merged.calories, max(rndRecord.calories!, targetRecord.calories!));
            expect(merged.power, max(rndRecord.power!, targetRecord.power!));
            expect(merged.speed, closeTo(max(rndRecord.speed!, targetRecord.speed!), eps));
            expect(merged.pace, closeTo(min(rndRecord.pace!, targetRecord.pace!), eps));
            expect(merged.cadence, max(rndRecord.cadence!, targetRecord.cadence!));
            expect(merged.heartRate, max(rndRecord.heartRate!, targetRecord.heartRate!));
            expect(
              merged.caloriesPerMinute,
              closeTo(max(rndCaloriesPerMinute, targetCaloriesPerMinute), eps),
            );
            expect(
              merged.caloriesPerHour,
              closeTo(max(rndCaloriesPerHour, targetCaloriesPerHour), eps),
            );
          },
        );
      }
    }
  });

  group('Record merge best does not override with nulls', () {
    final rnd = Random();
    for (final sport in allSports) {
      for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
        final blankRecord = RecordWithSport(sport: sport);
        final rndDistance = rnd.nextDouble() * 1000;
        final rndElapsed = rnd.nextInt(600);
        final rndCaloriesPerMinute = rnd.nextDouble() * 12;
        final rndCaloriesPerHour = rnd.nextDouble() * 500;
        final rndPace = rnd.nextDouble() * 600;
        final targetRecord =
            RecordWithSport.getRandom(sport, rnd)
              ..pace = rndPace
              ..distance = rndDistance
              ..elapsed = rndElapsed
              ..caloriesPerMinute = rndCaloriesPerMinute
              ..caloriesPerHour = rndCaloriesPerHour;
        test(
          "$sport $idx: ${targetRecord.calories} ${targetRecord.power} ${targetRecord.speed} ${targetRecord.pace} ${targetRecord.cadence} ${targetRecord.heartRate} ${targetRecord.distance} ${targetRecord.elapsed}",
          () async {
            final merged = targetRecord.mergeBest(blankRecord);

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
          },
        );
      }
    }
  });

  group('Record merge best does not override with zeros', () {
    final rnd = Random();
    for (final sport in allSports) {
      for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
        final blankRecord =
            RecordWithSport.getZero(sport)
              ..caloriesPerHour = 0.0
              ..caloriesPerMinute = 0.0;
        final rndDistance = rnd.nextDouble() * 1000;
        final rndElapsed = rnd.nextInt(600);
        final rndCaloriesPerMinute = rnd.nextDouble() * 12;
        final rndCaloriesPerHour = rnd.nextDouble() * 500;
        final rndPace = rnd.nextDouble() * 600;
        final targetRecord =
            RecordWithSport.getRandom(sport, rnd)
              ..pace = rndPace
              ..distance = rndDistance
              ..elapsed = rndElapsed
              ..caloriesPerMinute = rndCaloriesPerMinute
              ..caloriesPerHour = rndCaloriesPerHour;
        test(
          "$sport $idx: ${targetRecord.calories} ${targetRecord.power} ${targetRecord.speed} ${targetRecord.pace} ${targetRecord.cadence} ${targetRecord.heartRate} ${targetRecord.distance} ${targetRecord.elapsed}",
          () async {
            final merged = targetRecord.mergeBest(blankRecord);

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
          },
        );
      }
    }
  });
}
