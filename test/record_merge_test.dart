import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

void main() {
  group('Record merge over nulls', () {
    final rnd = Random();
    for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
      final rndRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
        ..distance = rnd.nextDouble() * 1000
        ..elapsed = rnd.nextInt(600)
        ..caloriesPerMinute = rnd.nextDouble() * 12
        ..caloriesPerHour = rnd.nextDouble() * 500;
      final mergeCadence = rnd.nextBool();
      final mergeHr = rnd.nextBool();
      test(
          "$idx: $mergeCadence $mergeHr ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
          () async {
        final blankRecord = RecordWithSport(sport: ActivityType.ride);
        final merged = blankRecord.merge(rndRecord, mergeCadence, mergeHr);

        expect(merged.distance, closeTo(rndRecord.distance!, eps));
        expect(merged.elapsed, rndRecord.elapsed!);
        expect(merged.calories, rndRecord.calories!);
        expect(merged.power, rndRecord.power!);
        expect(merged.speed, closeTo(rndRecord.speed!, eps));
        expect(merged.cadence, mergeCadence ? rndRecord.cadence! : null);
        expect(merged.heartRate, mergeHr ? rndRecord.heartRate! : null);
        expect(merged.caloriesPerMinute, null);
        expect(merged.caloriesPerHour, null);
      });
    }
  });

  group('Record does not merge over zeros', () {
    final rnd = Random();
    for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
      final rndRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
        ..distance = rnd.nextDouble() * 1000
        ..elapsed = rnd.nextInt(600)
        ..caloriesPerMinute = rnd.nextDouble() * 12
        ..caloriesPerHour = rnd.nextDouble() * 500;
      final mergeCadence = rnd.nextBool();
      final mergeHr = rnd.nextBool();
      test(
          "$idx: $mergeCadence $mergeHr ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
          () async {
        final blankRecord = RecordWithSport.getBlank(ActivityType.ride)
          ..caloriesPerHour = 0.0
          ..caloriesPerMinute = 0.0;
        final merged = blankRecord.merge(rndRecord, mergeCadence, mergeHr);

        expect(merged.distance, closeTo(blankRecord.distance!, eps));
        expect(merged.elapsed, blankRecord.elapsed!);
        expect(merged.calories, blankRecord.calories!);
        expect(merged.power, blankRecord.power!);
        expect(merged.speed, closeTo(blankRecord.speed!, eps));
        expect(merged.cadence, blankRecord.cadence!);
        expect(merged.heartRate, blankRecord.heartRate!);
        expect(merged.caloriesPerMinute, closeTo(blankRecord.caloriesPerMinute!, eps));
        expect(merged.caloriesPerHour, closeTo(blankRecord.caloriesPerHour!, eps));
      });
    }
  });

  group('Record merge does not override', () {
    final rnd = Random();
    for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
      final rndRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
        ..distance = rnd.nextDouble() * 1000
        ..elapsed = rnd.nextInt(600)
        ..caloriesPerMinute = rnd.nextDouble() * 12
        ..caloriesPerHour = rnd.nextDouble() * 500;
      final mergeCadence = rnd.nextBool();
      final mergeHr = rnd.nextBool();
      test(
          "$idx: $mergeCadence $mergeHr ${rndRecord.calories} ${rndRecord.power} ${rndRecord.speed} ${rndRecord.cadence} ${rndRecord.heartRate} ${rndRecord.distance} ${rndRecord.elapsed}",
          () async {
        final targetRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
          ..distance = rnd.nextDouble() * 1000
          ..elapsed = rnd.nextInt(600)
          ..caloriesPerMinute = rnd.nextDouble() * 12
          ..caloriesPerHour = rnd.nextDouble() * 500;
        final merged = targetRecord.merge(rndRecord, mergeCadence, mergeHr);

        expect(merged.distance, closeTo(targetRecord.distance!, eps));
        expect(merged.elapsed, targetRecord.elapsed!);
        expect(merged.calories, targetRecord.calories!);
        expect(merged.power, targetRecord.power!);
        expect(merged.speed, closeTo(targetRecord.speed!, eps));
        expect(merged.cadence, targetRecord.cadence!);
        expect(merged.heartRate, targetRecord.heartRate!);
        expect(merged.caloriesPerMinute, closeTo(targetRecord.caloriesPerMinute!, eps));
        expect(merged.caloriesPerHour, closeTo(targetRecord.caloriesPerHour!, eps));
      });
    }
  });

  group('Record merge does not override with nulls', () {
    final rnd = Random();
    for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
      final blankRecord = RecordWithSport(sport: ActivityType.ride);
      final mergeCadence = rnd.nextBool();
      final mergeHr = rnd.nextBool();
      final targetRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
        ..distance = rnd.nextDouble() * 1000
        ..elapsed = rnd.nextInt(600)
        ..caloriesPerMinute = rnd.nextDouble() * 12
        ..caloriesPerHour = rnd.nextDouble() * 500;
      test(
          "$idx: $mergeCadence $mergeHr ${targetRecord.calories} ${targetRecord.power} ${targetRecord.speed} ${targetRecord.cadence} ${targetRecord.heartRate} ${targetRecord.distance} ${targetRecord.elapsed}",
          () async {
        final merged = targetRecord.merge(blankRecord, mergeCadence, mergeHr);

        expect(merged.distance, closeTo(targetRecord.distance!, eps));
        expect(merged.elapsed, targetRecord.elapsed!);
        expect(merged.calories, targetRecord.calories!);
        expect(merged.power, targetRecord.power!);
        expect(merged.speed, closeTo(targetRecord.speed!, eps));
        expect(merged.cadence, targetRecord.cadence!);
        expect(merged.heartRate, targetRecord.heartRate!);
        expect(merged.caloriesPerMinute, closeTo(targetRecord.caloriesPerMinute!, eps));
        expect(merged.caloriesPerHour, closeTo(targetRecord.caloriesPerHour!, eps));
      });
    }
  });

  group('Record merge does not override with zeros', () {
    final rnd = Random();
    for (var idx in List<int>.generate(smallRepetition, (index) => index)) {
      final blankRecord = RecordWithSport.getBlank(ActivityType.ride)
        ..caloriesPerHour = 0.0
        ..caloriesPerMinute = 0.0;
      final mergeCadence = rnd.nextBool();
      final mergeHr = rnd.nextBool();
      final targetRecord = RecordWithSport.getRandom(ActivityType.ride, rnd)
        ..distance = rnd.nextDouble() * 1000
        ..elapsed = rnd.nextInt(600)
        ..caloriesPerMinute = rnd.nextDouble() * 12
        ..caloriesPerHour = rnd.nextDouble() * 500;
      test(
          "$idx: $mergeCadence $mergeHr ${targetRecord.calories} ${targetRecord.power} ${targetRecord.speed} ${targetRecord.cadence} ${targetRecord.heartRate} ${targetRecord.distance} ${targetRecord.elapsed}",
          () async {
        final merged = targetRecord.merge(blankRecord, mergeCadence, mergeHr);

        expect(merged.distance, closeTo(targetRecord.distance!, eps));
        expect(merged.elapsed, targetRecord.elapsed!);
        expect(merged.calories, targetRecord.calories!);
        expect(merged.power, targetRecord.power!);
        expect(merged.speed, closeTo(targetRecord.speed!, eps));
        expect(merged.cadence, targetRecord.cadence!);
        expect(merged.heartRate, targetRecord.heartRate!);
        expect(merged.caloriesPerMinute, closeTo(targetRecord.caloriesPerMinute!, eps));
        expect(merged.caloriesPerHour, closeTo(targetRecord.caloriesPerHour!, eps));
      });
    }
  });
}
