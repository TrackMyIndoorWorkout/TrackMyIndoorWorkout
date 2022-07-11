import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  test('adjustRecord survives null values', () async {
    final descriptor = DeviceFactory.getSchwinnIcBike();
    final record = RecordWithSport(sport: descriptor.defaultSport);
    final rnd = Random();
    final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
    final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;

    record.adjustByFactors(powerFactor, calorieFactor, true);

    expect(record.power, null);
    expect(record.speed, null);
    expect(record.distance, null);
    expect(record.pace, null);
    expect(record.calories, null);
    expect(record.caloriesPerHour, null);
    expect(record.caloriesPerMinute, null);
  });

  group('adjustRecord adjusts power', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 500, rnd).forEach((pow) {
      final descriptor = DeviceFactory.getSchwinnIcBike();
      final powerFactor = rnd.nextDouble() * 2.0 + 0.1;
      final calorieFactor = rnd.nextDouble() * 2.0 + 0.1;
      final extendTuning = rnd.nextBool();
      final power = (pow * powerFactor).round();
      test('$power = $pow * $powerFactor', () async {
        final record = RecordWithSport(sport: descriptor.defaultSport, power: pow);

        record.adjustByFactors(powerFactor, calorieFactor, extendTuning);

        expect(record.power, power);
      });
    });
  });

  group('adjustRecord adjusts extended metrics', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 500, rnd).forEach((power) {
      final descriptor = DeviceFactory.getSchwinnIcBike();
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

        record.adjustByFactors(powerFactor, calorieFactor, true);

        expect(record.power, (power * powerFactor).round());
        expect(record.speed, speed * powerFactor);
        expect(record.distance, distance * powerFactor);
        expect(record.pace, pace / powerFactor);
      });
    });
  });

  group('adjustRecord does not adjust extended metrics if not extendTuning', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 500, rnd).forEach((power) {
      final descriptor = DeviceFactory.getSchwinnIcBike();
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

        record.adjustByFactors(powerFactor, calorieFactor, false);

        expect(record.power, (power * powerFactor).round());
        expect(record.speed, closeTo(speed, eps));
        expect(record.distance, closeTo(distance, eps));
        expect(record.pace, closeTo(pace, eps));
      });
    });
  });

  group('adjustRecord adjusts calories', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 1000, rnd).forEach((calories) {
      final descriptor = DeviceFactory.getSchwinnIcBike();
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

        record.adjustByFactors(powerFactor, calorieFactor, extendTuning);

        expect(record.calories, (calories * calorieFactor).round());
        expect(record.caloriesPerHour, closeTo(caloriesPerHour * calorieFactor, eps));
        expect(record.caloriesPerMinute, closeTo(caloriesPerMinute * calorieFactor, eps));
      });
    });
  });
}
