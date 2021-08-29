import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/statistics_accumulator.dart';
import 'utils.dart';

void main() {
  test('StatisticsAccumulator is empty after creation', () async {
    final accu = StatisticsAccumulator(si: Random().nextBool(), sport: ActivityType.Ride);
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateMinPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateMinSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateMinCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.calculateMinHeartRate, false);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, MAX_INIT);
    expect(accu.minPower, MIN_INIT);
    expect(accu.speedSum, 0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, MAX_INIT.toDouble());
    expect(accu.minSpeed, MIN_INIT.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.minHeartRate, MIN_INIT);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, MAX_INIT);
    expect(accu.minCadence, MIN_INIT);
  });

  test('StatisticsAccumulator initializes power variables when avg requested', () async {
    final accu = StatisticsAccumulator(
      si: Random().nextBool(),
      sport: ActivityType.Ride,
      calculateAvgPower: true,
    );
    expect(accu.calculateAvgPower, true);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateMinPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateMinSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateMinCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.calculateMinHeartRate, false);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, MAX_INIT);
    expect(accu.minPower, MIN_INIT);
    expect(accu.speedSum, 0.0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, MAX_INIT.toDouble());
    expect(accu.minSpeed, MIN_INIT.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.minHeartRate, MIN_INIT);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, MAX_INIT);
    expect(accu.minCadence, MIN_INIT);
  });

  test('StatisticsAccumulator initializes max power when max requested', () async {
    final accu = StatisticsAccumulator(
      si: Random().nextBool(),
      sport: ActivityType.Ride,
      calculateMaxPower: true,
    );
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, true);
    expect(accu.calculateMinPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateMinSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateMinCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.calculateMinHeartRate, false);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, MAX_INIT);
    expect(accu.minPower, MIN_INIT);
    expect(accu.speedSum, 0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, MAX_INIT.toDouble());
    expect(accu.minSpeed, MIN_INIT.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.minHeartRate, MIN_INIT);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, MAX_INIT);
    expect(accu.minCadence, MIN_INIT);
  });

  test('StatisticsAccumulator initializes min power when min requested', () async {
    final accu = StatisticsAccumulator(
      si: Random().nextBool(),
      sport: ActivityType.Ride,
      calculateMinPower: true,
    );
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateMinPower, true);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateMinSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateMinCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.calculateMinHeartRate, false);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, MAX_INIT);
    expect(accu.minPower, MIN_INIT);
    expect(accu.speedSum, 0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, MAX_INIT.toDouble());
    expect(accu.minSpeed, MIN_INIT.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.minHeartRate, MIN_INIT);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, MAX_INIT);
    expect(accu.minCadence, MIN_INIT);
  });

  test('StatisticsAccumulator initializes speed variables when avg requested', () async {
    final accu = StatisticsAccumulator(
      si: Random().nextBool(),
      sport: ActivityType.Ride,
      calculateAvgSpeed: true,
    );
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateMinPower, false);
    expect(accu.calculateAvgSpeed, true);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateMinSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateMinCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.calculateMinHeartRate, false);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, MAX_INIT);
    expect(accu.minPower, MIN_INIT);
    expect(accu.speedSum, 0.0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, MAX_INIT.toDouble());
    expect(accu.minSpeed, MIN_INIT.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.minHeartRate, MIN_INIT);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, MAX_INIT);
    expect(accu.minCadence, MIN_INIT);
  });

  group('StatisticsAccumulator initializes max speed when max requested', () {
    SPORTS.forEach((sport) {
      final accu = StatisticsAccumulator(
        si: Random().nextBool(),
        sport: sport,
        calculateMaxSpeed: true,
      );
      test("$sport -> ${accu.maxSpeed}", () async {
        expect(accu.sport, sport);
        expect(accu.calculateAvgPower, false);
        expect(accu.calculateMaxPower, false);
        expect(accu.calculateMinPower, false);
        expect(accu.calculateAvgSpeed, false);
        expect(accu.calculateMaxSpeed, true);
        expect(accu.calculateMinSpeed, false);
        expect(accu.calculateAvgCadence, false);
        expect(accu.calculateMaxCadence, false);
        expect(accu.calculateMinCadence, false);
        expect(accu.calculateAvgHeartRate, false);
        expect(accu.calculateMaxHeartRate, false);
        expect(accu.calculateMinHeartRate, false);
        expect(accu.powerSum, 0);
        expect(accu.powerCount, 0);
        expect(accu.maxPower, MAX_INIT);
        expect(accu.minPower, MIN_INIT);
        expect(accu.speedSum, 0.0);
        expect(accu.speedCount, 0);
        expect(accu.maxSpeed, MAX_INIT.toDouble());
        expect(accu.minSpeed, MIN_INIT.toDouble());
        expect(accu.heartRateSum, 0);
        expect(accu.heartRateCount, 0);
        expect(accu.maxHeartRate, MAX_INIT);
        expect(accu.minHeartRate, MIN_INIT);
        expect(accu.cadenceSum, 0);
        expect(accu.cadenceCount, 0);
        expect(accu.maxCadence, MAX_INIT);
        expect(accu.minCadence, MIN_INIT);
      });
    });
  });

  group('StatisticsAccumulator initializes min speed when min requested', () {
    SPORTS.forEach((sport) {
      final accu = StatisticsAccumulator(
        si: Random().nextBool(),
        sport: sport,
        calculateMinSpeed: true,
      );
      test("$sport -> ${accu.maxSpeed}", () async {
        expect(accu.sport, sport);
        expect(accu.calculateAvgPower, false);
        expect(accu.calculateMaxPower, false);
        expect(accu.calculateMinPower, false);
        expect(accu.calculateAvgSpeed, false);
        expect(accu.calculateMaxSpeed, false);
        expect(accu.calculateMinSpeed, true);
        expect(accu.calculateAvgCadence, false);
        expect(accu.calculateMaxCadence, false);
        expect(accu.calculateMinCadence, false);
        expect(accu.calculateAvgHeartRate, false);
        expect(accu.calculateMaxHeartRate, false);
        expect(accu.calculateMinHeartRate, false);
        expect(accu.powerSum, 0);
        expect(accu.powerCount, 0);
        expect(accu.maxPower, MAX_INIT);
        expect(accu.minPower, MIN_INIT);
        expect(accu.speedSum, 0.0);
        expect(accu.speedCount, 0);
        expect(accu.maxSpeed, MAX_INIT.toDouble());
        expect(accu.minSpeed, MIN_INIT.toDouble());
        expect(accu.heartRateSum, 0);
        expect(accu.heartRateCount, 0);
        expect(accu.maxHeartRate, MAX_INIT);
        expect(accu.minHeartRate, MIN_INIT);
        expect(accu.cadenceSum, 0);
        expect(accu.cadenceCount, 0);
        expect(accu.maxCadence, MAX_INIT);
        expect(accu.minCadence, MIN_INIT);
      });
    });
  });

  test('StatisticsAccumulator initializes hr variables when avg requested', () async {
    final accu = StatisticsAccumulator(
      si: Random().nextBool(),
      sport: ActivityType.Ride,
      calculateAvgHeartRate: true,
    );
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateMinPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateMinSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateMinCadence, false);
    expect(accu.calculateAvgHeartRate, true);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.calculateMinHeartRate, false);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, MAX_INIT);
    expect(accu.minPower, MIN_INIT);
    expect(accu.speedSum, 0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, MAX_INIT.toDouble());
    expect(accu.minSpeed, MIN_INIT.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.minHeartRate, MIN_INIT);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, MAX_INIT);
    expect(accu.minCadence, MIN_INIT);
  });

  test('StatisticsAccumulator initializes max hr when max requested', () async {
    final accu = StatisticsAccumulator(
      si: Random().nextBool(),
      sport: ActivityType.Ride,
      calculateMaxHeartRate: true,
    );
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateMinPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateMinSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateMinCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, true);
    expect(accu.calculateMinHeartRate, false);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, MAX_INIT);
    expect(accu.minPower, MIN_INIT);
    expect(accu.speedSum, 0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, MAX_INIT.toDouble());
    expect(accu.minSpeed, MIN_INIT.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.minHeartRate, MIN_INIT);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, MAX_INIT);
    expect(accu.minCadence, MIN_INIT);
  });

  test('StatisticsAccumulator initializes min hr when min requested', () async {
    final accu = StatisticsAccumulator(
      si: Random().nextBool(),
      sport: ActivityType.Ride,
      calculateMinHeartRate: true,
    );
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateMinPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateMinSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateMinCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.calculateMinHeartRate, true);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, MAX_INIT);
    expect(accu.minPower, MIN_INIT);
    expect(accu.speedSum, 0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, MAX_INIT.toDouble());
    expect(accu.minSpeed, MIN_INIT.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.minHeartRate, MIN_INIT);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, MAX_INIT);
    expect(accu.minCadence, MIN_INIT);
  });

  test('StatisticsAccumulator initializes cadence variables when avg requested', () async {
    final accu = StatisticsAccumulator(
      si: Random().nextBool(),
      sport: ActivityType.Ride,
      calculateAvgCadence: true,
    );
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateMinPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateMinSpeed, false);
    expect(accu.calculateAvgCadence, true);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateMinCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.calculateMinHeartRate, false);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, MAX_INIT);
    expect(accu.minPower, MIN_INIT);
    expect(accu.speedSum, 0.0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, MAX_INIT.toDouble());
    expect(accu.minSpeed, MIN_INIT.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.minHeartRate, MIN_INIT);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, MAX_INIT);
    expect(accu.minCadence, MIN_INIT);
  });

  test('StatisticsAccumulator initializes max cadence when max requested', () async {
    final accu = StatisticsAccumulator(
      si: Random().nextBool(),
      sport: ActivityType.Ride,
      calculateMaxCadence: true,
    );
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateMinPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateMinSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, true);
    expect(accu.calculateMinCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.calculateMinHeartRate, false);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, MAX_INIT);
    expect(accu.minPower, MIN_INIT);
    expect(accu.speedSum, 0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, MAX_INIT.toDouble());
    expect(accu.minSpeed, MIN_INIT.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.minHeartRate, MIN_INIT);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, MAX_INIT);
    expect(accu.minCadence, MIN_INIT);
  });

  test('StatisticsAccumulator initializes min cadence when min requested', () async {
    final accu = StatisticsAccumulator(
      si: Random().nextBool(),
      sport: ActivityType.Ride,
      calculateMinCadence: true,
    );
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateMinPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateMinSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateMinCadence, true);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.calculateMinHeartRate, false);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, MAX_INIT);
    expect(accu.minPower, MIN_INIT);
    expect(accu.speedSum, 0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, MAX_INIT.toDouble());
    expect(accu.minSpeed, MIN_INIT.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.minHeartRate, MIN_INIT);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, MAX_INIT);
    expect(accu.minCadence, MIN_INIT);
  });

  group('StatisticsAccumulator initializes everything when all requested', () {
    SPORTS.forEach((sport) {
      final accu = StatisticsAccumulator(
        si: Random().nextBool(),
        sport: sport,
        calculateAvgPower: true,
        calculateMaxPower: true,
        calculateMinPower: true,
        calculateAvgSpeed: true,
        calculateMaxSpeed: true,
        calculateMinSpeed: true,
        calculateAvgCadence: true,
        calculateMaxCadence: true,
        calculateMinCadence: true,
        calculateAvgHeartRate: true,
        calculateMaxHeartRate: true,
        calculateMinHeartRate: true,
      );
      test("$sport -> ${accu.maxSpeed}", () async {
        expect(accu.sport, sport);
        expect(accu.calculateAvgPower, true);
        expect(accu.calculateMaxPower, true);
        expect(accu.calculateMinPower, true);
        expect(accu.calculateAvgSpeed, true);
        expect(accu.calculateMaxSpeed, true);
        expect(accu.calculateMinSpeed, true);
        expect(accu.calculateAvgCadence, true);
        expect(accu.calculateMaxCadence, true);
        expect(accu.calculateMinCadence, true);
        expect(accu.calculateAvgHeartRate, true);
        expect(accu.calculateMaxHeartRate, true);
        expect(accu.calculateMinHeartRate, true);
        expect(accu.powerSum, 0);
        expect(accu.powerCount, 0);
        expect(accu.maxPower, MAX_INIT);
        expect(accu.minPower, MIN_INIT);
        expect(accu.speedSum, 0.0);
        expect(accu.speedCount, 0);
        expect(accu.maxSpeed, MAX_INIT.toDouble());
        expect(accu.minSpeed, MIN_INIT.toDouble());
        expect(accu.heartRateSum, 0);
        expect(accu.heartRateCount, 0);
        expect(accu.maxHeartRate, MAX_INIT);
        expect(accu.minHeartRate, MIN_INIT);
        expect(accu.cadenceSum, 0);
        expect(accu.cadenceCount, 0);
        expect(accu.maxCadence, MAX_INIT);
        expect(accu.minCadence, MIN_INIT);
        expect(accu.avgPower, 0);
        expect(accu.avgSpeed, 0);
        expect(accu.avgHeartRate, 0);
        expect(accu.avgCadence, 0);
      });
    });
  });
}
