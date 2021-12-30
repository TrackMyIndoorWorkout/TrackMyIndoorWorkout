import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  test('adjustRecord survives null values', () async {
    final descriptor = deviceMap["SIC4"]!;
    final record = RecordWithSport(sport: descriptor.defaultSport);
    final rnd = Random();
    final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
    final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
    final adjustedRecord = descriptor.adjustRecord(record, powerFactor, calorieFactor, true);

    expect(adjustedRecord.power, null);
    expect(adjustedRecord.speed, null);
    expect(adjustedRecord.distance, null);
    expect(adjustedRecord.pace, null);
    expect(adjustedRecord.calories, null);
    expect(adjustedRecord.caloriesPerHour, null);
    expect(adjustedRecord.caloriesPerMinute, null);
  });

  group('adjustRecord adjusts power', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 500, rnd).forEach((pow) {
      final descriptor = deviceMap["SIC4"]!;
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final extendTuning = rnd.nextBool();
      final power = (pow * powerFactor).round();
      test('$power = $pow * $powerFactor', () async {
        final record = RecordWithSport(sport: descriptor.defaultSport, power: pow);

        final adjustedRecord =
            descriptor.adjustRecord(record, powerFactor, calorieFactor, extendTuning);

        expect(adjustedRecord.power, power);
      });
    });
  });

  group('adjustRecord adjusts extended metrics', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 500, rnd).forEach((power) {
      final descriptor = deviceMap["SIC4"]!;
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final speed = rnd.nextDouble() * 20.0;
      final distance = rnd.nextDouble() * 1000.0;
      final pace = rnd.nextDouble() * 10.0;
      test('$powerFactor | $power, $speed, $distance, $pace', () async {
        final record = RecordWithSport(
          sport: descriptor.defaultSport,
          power: power,
          speed: speed,
          distance: distance,
          pace: pace,
        );

        final adjustedRecord = descriptor.adjustRecord(record, powerFactor, calorieFactor, true);

        expect(adjustedRecord.power, (power * powerFactor).round());
        expect(adjustedRecord.speed, speed * powerFactor);
        expect(adjustedRecord.distance, distance * powerFactor);
        expect(adjustedRecord.pace, pace / powerFactor);
      });
    });
  });

  group('adjustRecord does not adjust extended metrics if not extendTuning', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 500, rnd).forEach((power) {
      final descriptor = deviceMap["SIC4"]!;
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final speed = rnd.nextDouble() * 20.0;
      final distance = rnd.nextDouble() * 1000.0;
      final pace = rnd.nextDouble() * 10.0;
      test('$powerFactor | $power, $speed, $distance, $pace', () async {
        final record = RecordWithSport(
          sport: descriptor.defaultSport,
          power: power,
          speed: speed,
          distance: distance,
          pace: pace,
        );

        final adjustedRecord = descriptor.adjustRecord(record, powerFactor, calorieFactor, false);

        expect(adjustedRecord.power, (power * powerFactor).round());
        expect(adjustedRecord.speed, closeTo(speed, eps));
        expect(adjustedRecord.distance, closeTo(distance, eps));
        expect(adjustedRecord.pace, closeTo(pace, eps));
      });
    });
  });

  group('adjustRecord adjusts calories', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 1000, rnd).forEach((calories) {
      final descriptor = deviceMap["SIC4"]!;
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final extendTuning = rnd.nextBool();
      final caloriesPerHour = rnd.nextDouble() * 200.0;
      final caloriesPerMinute = rnd.nextDouble() * 10.0;
      test('$calories, $calorieFactor', () async {
        final record = RecordWithSport(
          sport: descriptor.defaultSport,
          calories: calories,
          caloriesPerHour: caloriesPerHour,
          caloriesPerMinute: caloriesPerMinute,
        );

        final adjustedRecord =
            descriptor.adjustRecord(record, powerFactor, calorieFactor, extendTuning);

        expect(adjustedRecord.calories, (calories * calorieFactor).round());
        expect(adjustedRecord.caloriesPerHour, closeTo(caloriesPerHour * calorieFactor, eps));
        expect(adjustedRecord.caloriesPerMinute, closeTo(caloriesPerMinute * calorieFactor, eps));
      });
    });
  });
}
