import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

void main() {
  group('Record merge over nulls', () {
    final rnd = Random();
    for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
      final rndDistance = rnd.nextDouble() * 1000;
      final rndElapsed = rnd.nextInt(600);
      final rndCaloriesPerMinute = rnd.nextDouble() * 12;
      final rndCaloriesPerHour = rnd.nextDouble() * 500;
      final rndRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
        ..distance = rndDistance
        ..elapsed = rndElapsed
        ..caloriesPerMinute = rndCaloriesPerMinute
        ..caloriesPerHour = rndCaloriesPerHour;
      test(
          "$idx: ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
          () async {
        final blankRecord = RecordWithSport(sport: ActivityType.ride);
        final merged = blankRecord.merge(rndRecord);

        expect(merged.distance, closeTo(rndDistance, eps));
        expect(merged.elapsed, rndElapsed);
        expect(merged.calories, rndRecord.calories!);
        expect(merged.power, rndRecord.power);
        expect(merged.speed, closeTo(rndRecord.speed!, eps));
        expect(merged.cadence, rndRecord.cadence);
        expect(merged.heartRate, rndRecord.heartRate!);
        expect(merged.caloriesPerMinute, null);
        expect(merged.caloriesPerHour, null);
      });
    }
  });

  group('Record does not merge over zeros', () {
    final rnd = Random();
    for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
      final rndDistance = rnd.nextDouble() * 1000;
      final rndElapsed = rnd.nextInt(600);
      final rndCaloriesPerMinute = rnd.nextDouble() * 12;
      final rndCaloriesPerHour = rnd.nextDouble() * 500;
      final rndRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
        ..distance = rndDistance
        ..elapsed = rndElapsed
        ..caloriesPerMinute = rndCaloriesPerMinute
        ..caloriesPerHour = rndCaloriesPerHour;
      test(
          "$idx: ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
          () async {
        final blankRecord = RecordWithSport.getZero(ActivityType.ride)
          ..caloriesPerHour = 0.0
          ..caloriesPerMinute = 0.0;
        final merged = blankRecord.merge(rndRecord);

        expect(merged.distance, closeTo(0.0, eps));
        expect(merged.elapsed, 0);
        expect(merged.calories, 0);
        expect(merged.power, 0);
        expect(merged.speed, closeTo(0.0, eps));
        expect(merged.cadence, 0);
        expect(merged.heartRate, 0);
        expect(merged.caloriesPerMinute, closeTo(0.0, eps));
        expect(merged.caloriesPerHour, closeTo(0.0, eps));
      });
    }
  });

  group('Record merge does not override', () {
    final rnd = Random();
    for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
      final rndDistance = rnd.nextDouble() * 1000;
      final rndElapsed = rnd.nextInt(600);
      final rndCaloriesPerMinute = rnd.nextDouble() * 12;
      final rndCaloriesPerHour = rnd.nextDouble() * 500;
      final rndRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
        ..distance = rndDistance
        ..elapsed = rndElapsed
        ..caloriesPerMinute = rndCaloriesPerMinute
        ..caloriesPerHour = rndCaloriesPerHour;
      test(
          "$idx: ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
          () async {
        final targetDistance = rnd.nextDouble() * 1000;
        final targetElapsed = rnd.nextInt(600);
        final targetCaloriesPerMinute = rnd.nextDouble() * 12;
        final targetCaloriesPerHour = rnd.nextDouble() * 500;
        final targetRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
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
        expect(merged.cadence, targetRecord.cadence!);
        expect(merged.heartRate, targetRecord.heartRate!);
        expect(merged.caloriesPerMinute, closeTo(targetCaloriesPerMinute, eps));
        expect(merged.caloriesPerHour, closeTo(targetCaloriesPerHour, eps));
      });
    }
  });

  group('Record merge does not override with nulls', () {
    final rnd = Random();
    for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
      final blankRecord = RecordWithSport(sport: ActivityType.ride);
      final rndDistance = rnd.nextDouble() * 1000;
      final rndElapsed = rnd.nextInt(600);
      final rndCaloriesPerMinute = rnd.nextDouble() * 12;
      final rndCaloriesPerHour = rnd.nextDouble() * 500;
      final targetRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
        ..distance = rndDistance
        ..elapsed = rndElapsed
        ..caloriesPerMinute = rndCaloriesPerMinute
        ..caloriesPerHour = rndCaloriesPerHour;
      test(
          "$idx: ${targetRecord.calories} ${targetRecord.power} ${targetRecord.speed} ${targetRecord.cadence} ${targetRecord.heartRate} ${targetRecord.distance} ${targetRecord.elapsed}",
          () async {
        final merged = targetRecord.merge(blankRecord);

        expect(merged.distance, closeTo(rndDistance, eps));
        expect(merged.elapsed, rndElapsed);
        expect(merged.calories, targetRecord.calories!);
        expect(merged.power, targetRecord.power!);
        expect(merged.speed, closeTo(targetRecord.speed!, eps));
        expect(merged.cadence, targetRecord.cadence!);
        expect(merged.heartRate, targetRecord.heartRate!);
        expect(merged.caloriesPerMinute, closeTo(rndCaloriesPerMinute, eps));
        expect(merged.caloriesPerHour, closeTo(rndCaloriesPerHour, eps));
      });
    }
  });

  group('Record merge does not override with zeros', () {
    final rnd = Random();
    for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
      final blankRecord = RecordWithSport.getZero(ActivityType.ride)
        ..caloriesPerHour = 0.0
        ..caloriesPerMinute = 0.0;
      final rndDistance = rnd.nextDouble() * 1000;
      final rndElapsed = rnd.nextInt(600);
      final rndCaloriesPerMinute = rnd.nextDouble() * 12;
      final rndCaloriesPerHour = rnd.nextDouble() * 500;
      final targetRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
        ..distance = rndDistance
        ..elapsed = rndElapsed
        ..caloriesPerMinute = rndCaloriesPerMinute
        ..caloriesPerHour = rndCaloriesPerHour;
      test(
          "$idx: ${targetRecord.calories} ${targetRecord.power} ${targetRecord.speed} ${targetRecord.cadence} ${targetRecord.heartRate} ${targetRecord.distance} ${targetRecord.elapsed}",
          () async {
        final merged = targetRecord.merge(blankRecord);

        expect(merged.distance, closeTo(rndDistance, eps));
        expect(merged.elapsed, rndElapsed);
        expect(merged.calories, targetRecord.calories!);
        expect(merged.power, targetRecord.power!);
        expect(merged.speed, closeTo(targetRecord.speed!, eps));
        expect(merged.cadence, targetRecord.cadence!);
        expect(merged.heartRate, targetRecord.heartRate!);
        expect(merged.caloriesPerMinute, closeTo(rndCaloriesPerMinute, eps));
        expect(merged.caloriesPerHour, closeTo(rndCaloriesPerHour, eps));
      });
    }
  });
}
