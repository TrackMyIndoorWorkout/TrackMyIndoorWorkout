import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/statistics_accumulator.dart';

void main() {
  test('StatisticsAccumulator is empty after creation', () async {
    final accu = StatisticsAccumulator(si: Random().nextBool(), sport: ActivityType.ride);
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
    expect(accu.maxPower, maxInit);
    expect(accu.minPower, minInit);
    expect(accu.speedSum, 0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, maxInit.toDouble());
    expect(accu.minSpeed, minInit.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, maxInit);
    expect(accu.minHeartRate, minInit);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, maxInit);
    expect(accu.minCadence, minInit);
  });

  test("StatisticsAccumulator doesn't display extremes after creation", () async {
    final accu = StatisticsAccumulator(si: Random().nextBool(), sport: ActivityType.ride);
    expect(accu.maxPowerDisplay, 0);
    expect(accu.minPowerDisplay, 0);
    expect(accu.maxSpeedDisplay, closeTo(0.0, eps));
    expect(accu.minSpeedDisplay, closeTo(0.0, eps));
    expect(accu.maxHeartRateDisplay, 0);
    expect(accu.minHeartRateDisplay, 0);
    expect(accu.maxCadenceDisplay, 0);
    expect(accu.minCadenceDisplay, 0);
  });

  test('StatisticsAccumulator reset resets all values', () async {
    final accu = StatisticsAccumulator(si: Random().nextBool(), sport: ActivityType.ride)
      ..powerSum = 42
      ..powerCount = 42
      ..maxPower = 42
      ..minPower = 42
      ..speedSum = 42.0
      ..speedCount = 42
      ..maxSpeed = 42.0
      ..minSpeed = 42.0
      ..heartRateSum = 42
      ..heartRateCount = 42
      ..maxHeartRate = 42
      ..minHeartRate = 42
      ..cadenceSum = 42
      ..cadenceCount = 42
      ..maxCadence = 42
      ..minCadence = 42;

    accu.reset();

    expect(accu.powerSum, 0);
    expect(accu.powerCount, 0);
    expect(accu.maxPower, maxInit);
    expect(accu.minPower, minInit);
    expect(accu.speedSum, 0);
    expect(accu.speedCount, 0);
    expect(accu.maxSpeed, maxInit.toDouble());
    expect(accu.minSpeed, minInit.toDouble());
    expect(accu.heartRateSum, 0);
    expect(accu.heartRateCount, 0);
    expect(accu.maxHeartRate, maxInit);
    expect(accu.minHeartRate, minInit);
    expect(accu.cadenceSum, 0);
    expect(accu.cadenceCount, 0);
    expect(accu.maxCadence, maxInit);
    expect(accu.minCadence, minInit);
  });

  group('StatisticsAccumulator initializes everything regardless requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final bool calcAvgPower = rnd.nextBool();
      final bool calcMaxPower = rnd.nextBool();
      final bool calcMinPower = rnd.nextBool();
      final bool calcAvgSpeed = rnd.nextBool();
      final bool calcMaxSpeed = rnd.nextBool();
      final bool calcMinSpeed = rnd.nextBool();
      final bool calcAvgCadence = rnd.nextBool();
      final bool calcMaxCadence = rnd.nextBool();
      final bool calcMinCadence = rnd.nextBool();
      final bool calcAvgHeartRate = rnd.nextBool();
      final bool calcMaxHeartRate = rnd.nextBool();
      final bool calcMinHeartRate = rnd.nextBool();
      final accu = StatisticsAccumulator(
        si: Random().nextBool(),
        sport: sport,
        calculateAvgPower: calcAvgPower,
        calculateMaxPower: calcMaxPower,
        calculateMinPower: calcMinPower,
        calculateAvgSpeed: calcAvgSpeed,
        calculateMaxSpeed: calcMaxSpeed,
        calculateMinSpeed: calcMinSpeed,
        calculateAvgCadence: calcAvgCadence,
        calculateMaxCadence: calcMaxCadence,
        calculateMinCadence: calcMinCadence,
        calculateAvgHeartRate: calcAvgHeartRate,
        calculateMaxHeartRate: calcMaxHeartRate,
        calculateMinHeartRate: calcMinHeartRate,
      );
      test("$sport -> ${accu.maxSpeed}", () async {
        expect(accu.sport, sport);
        expect(accu.calculateAvgPower, calcAvgPower);
        expect(accu.calculateMaxPower, calcMaxPower);
        expect(accu.calculateMinPower, calcMinPower);
        expect(accu.calculateAvgSpeed, calcAvgSpeed);
        expect(accu.calculateMaxSpeed, calcMaxSpeed);
        expect(accu.calculateMinSpeed, calcMinSpeed);
        expect(accu.calculateAvgCadence, calcAvgCadence);
        expect(accu.calculateMaxCadence, calcMaxCadence);
        expect(accu.calculateMinCadence, calcMinCadence);
        expect(accu.calculateAvgHeartRate, calcAvgHeartRate);
        expect(accu.calculateMaxHeartRate, calcMaxHeartRate);
        expect(accu.calculateMinHeartRate, calcMinHeartRate);
        expect(accu.powerSum, 0);
        expect(accu.powerCount, 0);
        expect(accu.maxPower, maxInit);
        expect(accu.minPower, minInit);
        expect(accu.speedSum, 0.0);
        expect(accu.speedCount, 0);
        expect(accu.maxSpeed, maxInit.toDouble());
        expect(accu.minSpeed, minInit.toDouble());
        expect(accu.heartRateSum, 0);
        expect(accu.heartRateCount, 0);
        expect(accu.maxHeartRate, maxInit);
        expect(accu.minHeartRate, minInit);
        expect(accu.cadenceSum, 0);
        expect(accu.cadenceCount, 0);
        expect(accu.maxCadence, maxInit);
        expect(accu.minCadence, minInit);
        expect(accu.avgPower, 0);
        expect(accu.avgSpeed, 0);
        expect(accu.avgHeartRate, 0);
        expect(accu.avgCadence, 0);
      });
    }
  });
}
