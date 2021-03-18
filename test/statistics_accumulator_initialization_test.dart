import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/tcx/activity_type.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/statistics_accumulator.dart';
import 'utils.dart';

void main() {
  test('StatisticsAccumulator is empty after creation', () async {
    final accu = StatisticsAccumulator();
    expect(accu.si, null);
    expect(accu.sport, null);
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.powerSum, null);
    expect(accu.powerCount, null);
    expect(accu.maxPower, null);
    expect(accu.speedSum, null);
    expect(accu.speedCount, null);
    expect(accu.maxSpeed, null);
    expect(accu.heartRateSum, null);
    expect(accu.heartRateCount, null);
    expect(accu.maxHeartRate, null);
    expect(accu.cadenceSum, null);
    expect(accu.cadenceCount, null);
    expect(accu.maxCadence, null);
  });

  test('StatisticsAccumulator initializes power variables when avg requested', () async {
    final accu = StatisticsAccumulator(calculateAvgPower: true);
    expect(accu.si, null);
    expect(accu.sport, null);
    expect(accu.calculateAvgPower, true);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, null);
    expect(accu.speedSum, null);
    expect(accu.speedCount, null);
    expect(accu.maxSpeed, null);
    expect(accu.heartRateSum, null);
    expect(accu.heartRateCount, null);
    expect(accu.maxHeartRate, null);
    expect(accu.cadenceSum, null);
    expect(accu.cadenceCount, null);
    expect(accu.maxCadence, null);
  });

  test('StatisticsAccumulator initializes max power when max requested', () async {
    final accu = StatisticsAccumulator(calculateMaxPower: true);
    expect(accu.si, null);
    expect(accu.sport, null);
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, true);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.powerSum, null);
    expect(accu.powerCount, null);
    expect(accu.maxPower, MAX_INIT.toDouble());
    expect(accu.speedSum, null);
    expect(accu.speedCount, null);
    expect(accu.maxSpeed, null);
    expect(accu.heartRateSum, null);
    expect(accu.heartRateCount, null);
    expect(accu.maxHeartRate, null);
    expect(accu.cadenceSum, null);
    expect(accu.cadenceCount, null);
    expect(accu.maxCadence, null);
  });

  test('StatisticsAccumulator initializes speed variables when avg requested', () async {
    final accu = StatisticsAccumulator(calculateAvgSpeed: true);
    expect(accu.si, null);
    expect(accu.sport, null);
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateAvgSpeed, true);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.powerSum, null);
    expect(accu.powerCount, null);
    expect(accu.maxPower, null);
    expect(accu.speedSum, 0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, null);
    expect(accu.heartRateSum, null);
    expect(accu.heartRateCount, null);
    expect(accu.maxHeartRate, null);
    expect(accu.cadenceSum, null);
    expect(accu.cadenceCount, null);
    expect(accu.maxCadence, null);
  });

  group('StatisticsAccumulator initializes max speed when max requested', () {
    SPORTS.forEach((sport) {
      final accu = StatisticsAccumulator(sport: sport, calculateMaxSpeed: true);
      test("$sport -> ${accu.maxSpeed}", () {
        expect(accu.si, null);
        expect(accu.sport, sport);
        expect(accu.calculateAvgPower, false);
        expect(accu.calculateMaxPower, false);
        expect(accu.calculateAvgSpeed, false);
        expect(accu.calculateMaxSpeed, true);
        expect(accu.calculateAvgCadence, false);
        expect(accu.calculateMaxCadence, false);
        expect(accu.calculateAvgHeartRate, false);
        expect(accu.calculateMaxHeartRate, false);
        expect(accu.powerSum, null);
        expect(accu.powerCount, null);
        expect(accu.maxPower, null);
        expect(accu.speedSum, null);
        expect(accu.speedCount, null);
        expect(
            accu.maxSpeed, sport == ActivityType.Ride ? MAX_INIT.toDouble() : MIN_INIT.toDouble());
        expect(accu.heartRateSum, null);
        expect(accu.heartRateCount, null);
        expect(accu.maxHeartRate, null);
        expect(accu.cadenceSum, null);
        expect(accu.cadenceCount, null);
        expect(accu.maxCadence, null);
      });
    });
  });

  test('StatisticsAccumulator initializes hr variables when avg requested', () async {
    final accu = StatisticsAccumulator(calculateAvgHeartRate: true);
    expect(accu.si, null);
    expect(accu.sport, null);
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateAvgHeartRate, true);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.powerSum, null);
    expect(accu.powerCount, null);
    expect(accu.maxPower, null);
    expect(accu.speedSum, null);
    expect(accu.speedCount, null);
    expect(accu.maxSpeed, null);
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, null);
    expect(accu.cadenceSum, null);
    expect(accu.cadenceCount, null);
    expect(accu.maxCadence, null);
  });

  test('StatisticsAccumulator initializes max hr when max requested', () async {
    final accu = StatisticsAccumulator(calculateMaxHeartRate: true);
    expect(accu.si, null);
    expect(accu.sport, null);
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, true);
    expect(accu.powerSum, null);
    expect(accu.powerCount, null);
    expect(accu.maxPower, null);
    expect(accu.speedSum, null);
    expect(accu.speedCount, null);
    expect(accu.maxSpeed, null);
    expect(accu.heartRateSum, null);
    expect(accu.heartRateCount, null);
    expect(accu.maxHeartRate, MAX_INIT);
    expect(accu.cadenceSum, null);
    expect(accu.cadenceCount, null);
    expect(accu.maxCadence, null);
  });

  test('StatisticsAccumulator initializes cadence variables when avg requested', () async {
    final accu = StatisticsAccumulator(calculateAvgCadence: true);
    expect(accu.si, null);
    expect(accu.sport, null);
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateAvgCadence, true);
    expect(accu.calculateMaxCadence, false);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.powerSum, null);
    expect(accu.powerCount, null);
    expect(accu.maxPower, null);
    expect(accu.speedSum, null);
    expect(accu.speedCount, null);
    expect(accu.maxSpeed, null);
    expect(accu.heartRateSum, null);
    expect(accu.heartRateCount, null);
    expect(accu.maxHeartRate, null);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, null);
  });

  test('StatisticsAccumulator initializes max cadence when max requested', () async {
    final accu = StatisticsAccumulator(calculateMaxCadence: true);
    expect(accu.si, null);
    expect(accu.sport, null);
    expect(accu.calculateAvgPower, false);
    expect(accu.calculateMaxPower, false);
    expect(accu.calculateAvgSpeed, false);
    expect(accu.calculateMaxSpeed, false);
    expect(accu.calculateAvgCadence, false);
    expect(accu.calculateMaxCadence, true);
    expect(accu.calculateAvgHeartRate, false);
    expect(accu.calculateMaxHeartRate, false);
    expect(accu.powerSum, null);
    expect(accu.powerCount, null);
    expect(accu.maxPower, null);
    expect(accu.speedSum, null);
    expect(accu.speedCount, null);
    expect(accu.maxSpeed, null);
    expect(accu.heartRateSum, null);
    expect(accu.heartRateCount, null);
    expect(accu.maxHeartRate, null);
    expect(accu.cadenceSum, null);
    expect(accu.cadenceCount, null);
    expect(accu.maxCadence, MAX_INIT);
  });

  group('StatisticsAccumulator initializes everything when all requested', () {
    SPORTS.forEach((sport) {
      final accu = StatisticsAccumulator(
        sport: sport,
        calculateAvgPower: true,
        calculateMaxPower: true,
        calculateAvgSpeed: true,
        calculateMaxSpeed: true,
        calculateAvgCadence: true,
        calculateMaxCadence: true,
        calculateAvgHeartRate: true,
        calculateMaxHeartRate: true,
      );
      test("$sport -> ${accu.maxSpeed}", () {
        expect(accu.si, null);
        expect(accu.sport, sport);
        expect(accu.calculateAvgPower, true);
        expect(accu.calculateMaxPower, true);
        expect(accu.calculateAvgSpeed, true);
        expect(accu.calculateMaxSpeed, true);
        expect(accu.calculateAvgCadence, true);
        expect(accu.calculateMaxCadence, true);
        expect(accu.calculateAvgHeartRate, true);
        expect(accu.calculateMaxHeartRate, true);
        expect(accu.powerSum, 0);
        expect(accu.powerCount, 0);
        expect(accu.maxPower, MAX_INIT.toDouble());
        expect(accu.speedSum, 0);
        expect(accu.speedCount, 0);
        expect(
            accu.maxSpeed, sport == ActivityType.Ride ? MAX_INIT.toDouble() : MIN_INIT.toDouble());
        expect(accu.heartRateSum, 0);
        expect(accu.heartRateCount, 0);
        expect(accu.maxHeartRate, MAX_INIT);
        expect(accu.cadenceSum, 0);
        expect(accu.cadenceCount, 0);
        expect(accu.maxCadence, MAX_INIT);
        expect(accu.avgPower, 0);
        expect(accu.avgSpeed, 0);
        expect(accu.avgHeartRate, 0);
        expect(accu.avgCadence, 0);
      });
    });
  });
}
