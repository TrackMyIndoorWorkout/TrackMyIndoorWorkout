import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/floor/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/statistics_accumulator.dart';
import 'utils.dart';

void main() {
  group('StatisticsAccumulator calculates avg power when requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final accu = StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateAvgPower: true);
      var count = rnd.nextInt(99) + 1;
      double sum = 0.0;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(power: number, sport: sport));
        if (number > 0) {
          sum += number;
        } else {
          count--;
        }
      });
      test("$count ($sport) -> $sum", () async {
        expect(accu.sport, sport);
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
        expect(accu.powerSum, sum);
        expect(accu.powerCount, count);
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
        expect(accu.avgPower, count > 0 ? sum / count : 0);
      });
    }
  });

  group('StatisticsAccumulator calculates max power when requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final accu = StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMaxPower: true);
      final count = rnd.nextInt(99) + 1;
      int maximum = maxInit;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(power: number, sport: sport));
        maximum = max(number, maximum);
      });
      test("$count ($sport) -> $maximum", () async {
        expect(accu.sport, sport);
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
        expect(accu.maxPower, maximum);
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
    }
  });

  group('StatisticsAccumulator calculates min power when requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final accu = StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMinPower: true);
      final count = rnd.nextInt(99) + 1;
      int minimum = minInit;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(power: number, sport: sport));
        minimum = min(number, minimum);
      });
      test("$count ($sport) -> $minimum", () async {
        expect(accu.sport, sport);
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
        expect(accu.maxPower, maxInit);
        expect(accu.minPower, minimum);
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
    }
  });

  group('StatisticsAccumulator calculates avg speed when requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateAvgSpeed: true);
      var count = rnd.nextInt(99) + 1;
      double sum = 0.0;
      getRandomDoubles(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(speed: number, sport: sport));
        if (number > 0) {
          sum += number;
        } else {
          count--;
        }
      });
      test("$count ($sport) -> $sum", () async {
        expect(accu.si, si);
        expect(accu.sport, sport);
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
        expect(accu.maxPower, maxInit);
        expect(accu.minPower, minInit);
        expect(accu.speedSum, sum);
        expect(accu.speedCount, count);
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
        expect(accu.avgSpeed, closeTo(count > 0 ? sum / count : 0, eps));
      });
    }
  });

  group('StatisticsAccumulator calculates max speed when requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateMaxSpeed: true);
      final count = rnd.nextInt(99) + 1;
      double maximum = maxInit.toDouble();
      getRandomDoubles(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(speed: number, sport: sport));
        maximum = max(number, maximum);
      });
      test("$count ($sport) -> $maximum", () async {
        expect(accu.si, si);
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
        expect(accu.maxPower, maxInit);
        expect(accu.minPower, minInit);
        expect(accu.speedSum, 0);
        expect(accu.speedCount, 0);
        expect(accu.maxSpeed, closeTo(maximum, eps));
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
    }
  });

  group('StatisticsAccumulator calculates min speed when requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateMinSpeed: true);
      final count = rnd.nextInt(99) + 1;
      double minimum = minInit.toDouble();
      getRandomDoubles(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(speed: number, sport: sport));
        minimum = min(number, minimum);
      });
      test("$count ($sport) -> $minimum", () async {
        expect(accu.si, si);
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
        expect(accu.maxPower, maxInit);
        expect(accu.minPower, minInit);
        expect(accu.speedSum, 0);
        expect(accu.speedCount, 0);
        expect(accu.maxSpeed, maxInit.toDouble());
        expect(accu.minSpeed, closeTo(minimum, eps));
        expect(accu.heartRateSum, 0);
        expect(accu.heartRateCount, 0);
        expect(accu.maxHeartRate, maxInit);
        expect(accu.minHeartRate, minInit);
        expect(accu.cadenceSum, 0);
        expect(accu.cadenceCount, 0);
        expect(accu.maxCadence, maxInit);
        expect(accu.minCadence, minInit);
      });
    }
  });

  group('StatisticsAccumulator calculates avg hr when requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(
        si: si,
        sport: sport,
        calculateAvgHeartRate: true,
      );
      var count = rnd.nextInt(99) + 1;
      int sum = 0;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(heartRate: number, sport: sport));
        if (number > 0) {
          sum += number;
        } else {
          count--;
        }
      });
      test("$count ($sport) -> $sum", () async {
        expect(accu.si, si);
        expect(accu.sport, sport);
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
        expect(accu.maxPower, maxInit);
        expect(accu.minPower, minInit);
        expect(accu.speedSum, 0);
        expect(accu.speedCount, 0);
        expect(accu.maxSpeed, maxInit.toDouble());
        expect(accu.minSpeed, minInit.toDouble());
        expect(accu.heartRateSum, sum);
        expect(accu.heartRateCount, count);
        expect(accu.maxHeartRate, maxInit);
        expect(accu.minHeartRate, minInit);
        expect(accu.cadenceSum, 0);
        expect(accu.cadenceCount, 0);
        expect(accu.maxCadence, maxInit);
        expect(accu.minCadence, minInit);
        expect(accu.avgHeartRate, count > 0 ? sum ~/ count : 0);
      });
    }
  });

  group('StatisticsAccumulator calculates max hr when requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateMaxHeartRate: true);
      final count = rnd.nextInt(99) + 1;
      int maximum = maxInit;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(heartRate: number, sport: sport));
        if (number > 0) {
          maximum = max(number, maximum);
        }
      });
      test("$count ($sport) -> $maximum", () async {
        expect(accu.si, si);
        expect(accu.sport, sport);
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
        expect(accu.maxPower, maxInit);
        expect(accu.minPower, minInit);
        expect(accu.speedSum, 0);
        expect(accu.speedCount, 0);
        expect(accu.maxSpeed, maxInit.toDouble());
        expect(accu.minSpeed, minInit.toDouble());
        expect(accu.heartRateSum, 0);
        expect(accu.heartRateCount, 0);
        expect(accu.maxHeartRate, maximum);
        expect(accu.minHeartRate, minInit);
        expect(accu.cadenceSum, 0);
        expect(accu.cadenceCount, 0);
        expect(accu.maxCadence, maxInit);
        expect(accu.minCadence, minInit);
      });
    }
  });

  group('StatisticsAccumulator calculates min hr when requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateMinHeartRate: true);
      final count = rnd.nextInt(99) + 1;
      int minimum = minInit;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(heartRate: number, sport: sport));
        if (number > 0) {
          minimum = min(number, minimum);
        }
      });
      test("$count ($sport) -> $minimum", () async {
        expect(accu.si, si);
        expect(accu.sport, sport);
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
        expect(accu.maxPower, maxInit);
        expect(accu.minPower, minInit);
        expect(accu.speedSum, 0);
        expect(accu.speedCount, 0);
        expect(accu.maxSpeed, maxInit.toDouble());
        expect(accu.minSpeed, minInit.toDouble());
        expect(accu.heartRateSum, 0);
        expect(accu.heartRateCount, 0);
        expect(accu.maxHeartRate, maxInit);
        expect(accu.minHeartRate, minimum);
        expect(accu.cadenceSum, 0);
        expect(accu.cadenceCount, 0);
        expect(accu.maxCadence, maxInit);
        expect(accu.minCadence, minInit);
      });
    }
  });

  group('StatisticsAccumulator calculates avg cadence when requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateAvgCadence: true);
      var count = rnd.nextInt(99) + 1;
      int sum = 0;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(cadence: number, sport: sport));
        if (number > 0) {
          sum += number;
        } else {
          count--;
        }
      });
      test("$count ($sport) -> $sum", () async {
        expect(accu.si, si);
        expect(accu.sport, sport);
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
        expect(accu.cadenceSum, sum);
        expect(accu.cadenceCount, count);
        expect(accu.maxCadence, maxInit);
        expect(accu.minCadence, minInit);
        expect(accu.avgCadence, count > 0 ? sum ~/ count : 0);
      });
    }
  });

  group('StatisticsAccumulator calculates max cadence when max requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateMaxCadence: true);
      final count = rnd.nextInt(99) + 1;
      int maximum = maxInit;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(cadence: number, sport: sport));
        maximum = max(number, maximum);
      });
      test("$count ($sport) -> $maximum", () async {
        expect(accu.si, si);
        expect(accu.sport, sport);
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
        expect(accu.maxCadence, maximum);
        expect(accu.minCadence, minInit);
      });
    }
  });

  group('StatisticsAccumulator calculates min cadence when min requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateMinCadence: true);
      final count = rnd.nextInt(99) + 1;
      int minimum = minInit;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(cadence: number, sport: sport));
        minimum = min(number, minimum);
      });
      test("$count ($sport) -> $minimum", () async {
        expect(accu.si, si);
        expect(accu.sport, sport);
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
        expect(accu.minCadence, minimum);
      });
    }
  });

  group('StatisticsAccumulator calculates everything when all requested', () {
    final rnd = Random();
    for (final sport in allSports) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(
        si: si,
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
      final count = rnd.nextInt(99) + 1;
      int powerSum = 0;
      int powerCount = 0;
      int maxPower = maxInit;
      int minPower = minInit;
      final powers = getRandomInts(count, 100, rnd);
      double speedSum = 0.0;
      int speedCount = 0;
      double maxSpeed = maxInit.toDouble();
      double minSpeed = minInit.toDouble();
      final speeds = getRandomDoubles(count, 100, rnd);
      int cadenceSum = 0;
      int cadenceCount = 0;
      int maxCadence = maxInit;
      int minCadence = minInit;
      final cadences = getRandomInts(count, 100, rnd);
      int hrSum = 0;
      int hrCount = 0;
      int maxHr = maxInit;
      int minHr = minInit;
      final hrs = getRandomInts(count, 100, rnd);
      List<int>.generate(count, (index) {
        accu.processRecord(RecordWithSport(
          power: powers[index],
          speed: speeds[index],
          cadence: cadences[index],
          heartRate: hrs[index],
          sport: sport,
        ));
        powerSum += powers[index];
        if (powers[index] > 0) {
          powerCount++;
        }
        maxPower = max(powers[index], maxPower);
        minPower = min(powers[index], minPower);
        speedSum += speeds[index];
        if (speeds[index] > 0) {
          speedCount++;
        }
        maxSpeed = max(speeds[index], maxSpeed);
        minSpeed = min(speeds[index], minSpeed);
        cadenceSum += cadences[index];
        if (cadences[index] > 0) {
          cadenceCount++;
        }
        maxCadence = max(cadences[index], maxCadence);
        minCadence = min(cadences[index], minCadence);
        hrSum += hrs[index];
        if (hrs[index] > 0) {
          hrCount++;
          minHr = min(hrs[index], minHr);
          maxHr = max(hrs[index], maxHr);
        }
        return index;
      });
      test("$count ($sport) -> $powerSum, $maxPower, $minPower, $speedSum, $maxSpeed, $minSpeed",
          () async {
        expect(accu.si, si);
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
        expect(accu.powerSum, powerSum);
        expect(accu.powerCount, powerCount);
        expect(accu.maxPower, maxPower);
        expect(accu.minPower, minPower);
        expect(accu.speedSum, speedSum);
        expect(accu.speedCount, speedCount);
        expect(accu.maxSpeed, maxSpeed);
        expect(accu.minSpeed, minSpeed);
        expect(accu.heartRateSum, hrSum);
        expect(accu.heartRateCount, hrCount);
        expect(accu.maxHeartRate, maxHr);
        expect(accu.minHeartRate, minHr);
        expect(accu.cadenceSum, cadenceSum);
        expect(accu.cadenceCount, cadenceCount);
        expect(accu.maxCadence, maxCadence);
        expect(accu.minCadence, minCadence);
        expect(accu.avgPower, powerCount > 0 ? powerSum / powerCount : 0);
        expect(accu.avgSpeed, speedCount > 0 ? speedSum / speedCount : 0);
        expect(accu.avgHeartRate, hrCount > 0 ? hrSum ~/ hrCount : 0);
        expect(accu.avgCadence, cadenceCount > 0 ? cadenceSum ~/ cadenceCount : 0);
      });
    }
  });
}
