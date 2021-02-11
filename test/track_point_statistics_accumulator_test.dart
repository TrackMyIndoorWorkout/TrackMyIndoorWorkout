import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import '../lib/tcx/tcx_model.dart';
import '../lib/utils/statistics_accumulator.dart';
import 'utils.dart';

void main() {
  test('StatisticsAccumulator calculates avg power when requested', () async {
    final accu = StatisticsAccumulator(calculateAvgPower: true);
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    double sum = 0.0;
    getRandomDoubles(count, 100, rnd).forEach((number) {
      accu.processTrackPoint(TrackPoint()..power = number);
      sum += number;
    });
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
    expect(accu.powerSum, sum);
    expect(accu.powerCount, count);
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
    expect(accu.avgPower, sum / count);
  });

  test('StatisticsAccumulator calculates max power when requested', () async {
    final accu = StatisticsAccumulator(calculateMaxPower: true);
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    double maximum = 0.0;
    getRandomDoubles(count, 100, rnd).forEach((number) {
      accu.processTrackPoint(TrackPoint()..power = number);
      maximum = max(number, maximum);
    });
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
    expect(accu.maxPower, maximum);
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

  test('StatisticsAccumulator calculates avg speed when requested', () async {
    final accu = StatisticsAccumulator(calculateAvgSpeed: true);
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    double sum = 0.0;
    getRandomDoubles(count, 100, rnd).forEach((number) {
      accu.processTrackPoint(TrackPoint()..speed = number);
      sum += number;
    });
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
    expect(accu.speedSum, sum);
    expect(accu.speedCount, count);
    expect(accu.maxSpeed, null);
    expect(accu.heartRateSum, null);
    expect(accu.heartRateCount, null);
    expect(accu.maxHeartRate, null);
    expect(accu.cadenceSum, null);
    expect(accu.cadenceCount, null);
    expect(accu.maxCadence, null);
    expect(accu.avgSpeed, sum / count);
  });

  test('StatisticsAccumulator calculates max speed when requested', () async {
    final accu = StatisticsAccumulator(calculateMaxSpeed: true);
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    double maximum = 0.0;
    getRandomDoubles(count, 100, rnd).forEach((number) {
      accu.processTrackPoint(TrackPoint()..speed = number);
      maximum = max(number, maximum);
    });
    expect(accu.si, null);
    expect(accu.sport, null);
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
    expect(accu.maxSpeed, maximum);
    expect(accu.heartRateSum, null);
    expect(accu.heartRateCount, null);
    expect(accu.maxHeartRate, null);
    expect(accu.cadenceSum, null);
    expect(accu.cadenceCount, null);
    expect(accu.maxCadence, null);
  });

  test('StatisticsAccumulator calculates avg hr when requested', () async {
    final accu = StatisticsAccumulator(calculateAvgHeartRate: true);
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    int sum = 0;
    int cnt = 0;
    getRandomInts(count, 100, rnd).forEach((number) {
      accu.processTrackPoint(TrackPoint()..heartRate = number);
      sum += number;
      if (number > 0) {
        cnt += 1;
      }
    });
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
    expect(accu.heartRateSum, sum);
    expect(accu.heartRateCount, cnt);
    expect(accu.maxHeartRate, null);
    expect(accu.cadenceSum, null);
    expect(accu.cadenceCount, null);
    expect(accu.maxCadence, null);
    expect(accu.avgHeartRate, sum ~/ cnt);
  });

  test('StatisticsAccumulator calculates max hr when requested', () async {
    final accu = StatisticsAccumulator(calculateMaxHeartRate: true);
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    int maximum = 0;
    getRandomInts(count, 100, rnd).forEach((number) {
      accu.processTrackPoint(TrackPoint()..heartRate = number);
      maximum = max(number, maximum);
    });
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
    expect(accu.maxHeartRate, maximum);
    expect(accu.cadenceSum, null);
    expect(accu.cadenceCount, null);
    expect(accu.maxCadence, null);
  });

  test('StatisticsAccumulator calculates avg cadence when requested', () async {
    final accu = StatisticsAccumulator(calculateAvgCadence: true);
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    int sum = 0;
    int cnt = 0;
    getRandomInts(count, 100, rnd).forEach((number) {
      accu.processTrackPoint(TrackPoint()..cadence = number);
      sum += number;
      if (number > 0) {
        cnt += 1;
      }
    });
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
    expect(accu.cadenceSum, sum);
    expect(accu.cadenceCount, cnt);
    expect(accu.maxCadence, null);
    expect(accu.avgCadence, sum ~/ cnt);
  });

  test('StatisticsAccumulator initializes max cadence when max requested', () async {
    final accu = StatisticsAccumulator(calculateMaxCadence: true);
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    int maximum = 0;
    getRandomInts(count, 100, rnd).forEach((number) {
      accu.processTrackPoint(TrackPoint()..cadence = number);
      maximum = max(number, maximum);
    });
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
    expect(accu.maxCadence, maximum);
  });

  test('StatisticsAccumulator initializes everything when all requested', () async {
    final accu = StatisticsAccumulator(
      calculateAvgPower: true,
      calculateMaxPower: true,
      calculateAvgSpeed: true,
      calculateMaxSpeed: true,
      calculateAvgCadence: true,
      calculateMaxCadence: true,
      calculateAvgHeartRate: true,
      calculateMaxHeartRate: true,
    );
    final rnd = Random();
    final count = rnd.nextInt(99) + 1;
    double powerSum = 0.0;
    double maxPower = 0.0;
    final powers = getRandomDoubles(count, 100, rnd);
    double speedSum = 0.0;
    double maxSpeed = 0.0;
    final speeds = getRandomDoubles(count, 100, rnd);
    int cadenceSum = 0;
    int cadenceCount = 0;
    int maxCadence = 0;
    final cadences = getRandomInts(count, 100, rnd);
    int hrSum = 0;
    int hrCount = 0;
    int maxHr = 0;
    final hrs = getRandomInts(count, 100, rnd);
    List<int>.generate(count, (index) {
      accu.processTrackPoint(TrackPoint()
        ..power = powers[index]
        ..speed = speeds[index]
        ..cadence = cadences[index]
        ..heartRate = hrs[index]);
      powerSum += powers[index];
      maxPower = max(powers[index], maxPower);
      speedSum += speeds[index];
      maxSpeed = max(speeds[index], maxSpeed);
      cadenceSum += cadences[index];
      if (cadences[index] > 0) {
        cadenceCount += 1;
      }
      maxCadence = max(cadences[index], maxCadence);
      hrSum += hrs[index];
      if (hrs[index] > 0) {
        hrCount += 1;
      }
      maxHr = max(hrs[index], maxHr);
      return index;
    });

    expect(accu.si, null);
    expect(accu.sport, null);
    expect(accu.calculateAvgPower, true);
    expect(accu.calculateMaxPower, true);
    expect(accu.calculateAvgSpeed, true);
    expect(accu.calculateMaxSpeed, true);
    expect(accu.calculateAvgCadence, true);
    expect(accu.calculateMaxCadence, true);
    expect(accu.calculateAvgHeartRate, true);
    expect(accu.calculateMaxHeartRate, true);
    expect(accu.powerSum, powerSum);
    expect(accu.powerCount, count);
    expect(accu.maxPower, maxPower);
    expect(accu.speedSum, speedSum);
    expect(accu.speedCount, count);
    expect(accu.maxSpeed, maxSpeed);
    expect(accu.heartRateSum, hrSum);
    expect(accu.heartRateCount, hrCount);
    expect(accu.maxHeartRate, maxHr);
    expect(accu.cadenceSum, cadenceSum);
    expect(accu.cadenceCount, cadenceCount);
    expect(accu.maxCadence, maxCadence);
    expect(accu.avgPower, powerSum / count);
    expect(accu.avgSpeed, speedSum / count);
    expect(accu.avgHeartRate, hrSum ~/ hrCount);
    expect(accu.avgCadence, cadenceSum ~/ cadenceCount);
  });
}
