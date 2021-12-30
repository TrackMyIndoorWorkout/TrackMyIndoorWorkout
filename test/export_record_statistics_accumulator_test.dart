import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/export_record.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/statistics_accumulator.dart';
import 'utils.dart';

void main() {
  group('StatisticsAccumulator calculates avg power when requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateAvgPower: true);
        final count = rnd.nextInt(99) + 1;
        int sum = 0;
        int actualCount = 0;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(power: number)));
          sum += number;
          if (number > 0) {
            actualCount++;
          }
        });
        test("$sport, $count ($actualCount) -> $sum", () async {
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
          expect(accu.powerCount, actualCount);
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
          expect(accu.avgPower, actualCount > 0 ? sum / actualCount : 0.0);
        });
      });
    }
  });

  group('StatisticsAccumulator calculates max power when requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMaxPower: true);
        final count = rnd.nextInt(99) + 1;
        int maximum = maxInit;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(power: number)));
          maximum = max(number, maximum);
        });
        test("$sport, $count -> $maximum", () async {
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
      });
    }
  });

  group('StatisticsAccumulator calculates min power when requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMinPower: true);
        final count = rnd.nextInt(99) + 1;
        int minimum = minInit;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(power: number)));
          if (number > 0) {
            minimum = min(number, minimum);
          }
        });
        test("$sport, $count -> $minimum", () async {
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
      });
    }
  });

  group('StatisticsAccumulator calculates avg speed when requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateAvgSpeed: true);
        final count = rnd.nextInt(99) + 1;
        double sum = 0.0;
        getRandomDoubles(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(speed: number)));
          sum += number;
        });
        test("$sport, $count -> $sum", () async {
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
          expect(accu.avgSpeed, count > 0 ? sum / count : 0.0);
        });
      });
    }
  });

  group('StatisticsAccumulator calculates max speed when requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMaxSpeed: true);
        final count = rnd.nextInt(99) + 1;
        double maximum = maxInit.toDouble();
        getRandomDoubles(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(speed: number)));
          maximum = max(number, maximum);
        });
        test("$sport, $count -> $maximum", () async {
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
          expect(accu.maxSpeed, maximum);
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
      });
    }
  });

  group('StatisticsAccumulator calculates min speed when requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMinSpeed: true);
        final count = rnd.nextInt(99) + 1;
        double minimum = minInit.toDouble();
        getRandomDoubles(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(speed: number)));
          minimum = min(number, minimum);
        });
        test("$sport, $count -> $minimum", () async {
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
          expect(accu.minSpeed, minimum);
          expect(accu.heartRateSum, 0);
          expect(accu.heartRateCount, 0);
          expect(accu.maxHeartRate, maxInit);
          expect(accu.minHeartRate, minInit);
          expect(accu.cadenceSum, 0);
          expect(accu.cadenceCount, 0);
          expect(accu.maxCadence, maxInit);
          expect(accu.minCadence, minInit);
        });
      });
    }
  });

  group('StatisticsAccumulator calculates avg hr when requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateAvgHeartRate: true);
        final count = rnd.nextInt(99) + 1;
        int sum = 0;
        int cnt = 0;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(heartRate: number)));
          sum += number;
          if (number > 0) {
            cnt++;
          }
        });
        test("$sport, $count -> $sum", () async {
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
          expect(accu.heartRateCount, cnt);
          expect(accu.maxHeartRate, maxInit);
          expect(accu.minHeartRate, minInit);
          expect(accu.cadenceSum, 0);
          expect(accu.cadenceCount, 0);
          expect(accu.maxCadence, maxInit);
          expect(accu.minCadence, minInit);
          expect(accu.avgHeartRate, cnt > 0 ? sum ~/ cnt : 0);
        });
      });
    }
  });

  group('StatisticsAccumulator calculates max hr when requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMaxHeartRate: true);
        final count = rnd.nextInt(99) + 1;
        int maximum = maxInit;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(heartRate: number)));
          maximum = max(number, maximum);
        });
        test("$sport, $count -> $maximum", () async {
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
      });
    }
  });

  group('StatisticsAccumulator calculates min hr when requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMinHeartRate: true);
        final count = rnd.nextInt(99) + 1;
        int minimum = minInit;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(heartRate: number)));
          if (number > 0) {
            minimum = min(number, minimum);
          }
        });
        test("$sport, $count -> $minimum", () async {
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
      });
    }
  });

  group('StatisticsAccumulator calculates avg cadence when requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateAvgCadence: true);
        final count = rnd.nextInt(99) + 1;
        int sum = 0;
        int cnt = 0;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(cadence: number)));
          sum += number;
          if (number > 0) {
            cnt++;
          }
        });
        test("$sport, $count -> $sum", () async {
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
          expect(accu.cadenceCount, cnt);
          expect(accu.maxCadence, maxInit);
          expect(accu.minCadence, minInit);
          expect(accu.avgCadence, cnt > 0 ? sum ~/ cnt : 0);
        });
      });
    }
  });

  group('StatisticsAccumulator initializes max cadence when max requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMaxCadence: true);
        final count = rnd.nextInt(99) + 1;
        int maximum = maxInit;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(cadence: number)));
          maximum = max(number, maximum);
        });
        test("$sport, $count -> $maximum", () async {
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
      });
    }
  });

  group('StatisticsAccumulator initializes min cadence when min requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMinCadence: true);
        final count = rnd.nextInt(99) + 1;
        int minimum = minInit;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord(record: Record(cadence: number)));
          if (number > 0) {
            minimum = min(number, minimum);
          }
        });
        test("$sport, $count -> $minimum", () async {
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
      });
    }
  });

  group('StatisticsAccumulator initializes everything when all requested', () {
    final rnd = Random();
    for (final sport in sports) {
      1.to(smallRepetition).forEach((input) {
        final accu = StatisticsAccumulator(
          si: rnd.nextBool(),
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
          accu.processExportRecord(ExportRecord(
            record: Record(
              power: powers[index],
              speed: speeds[index],
              cadence: cadences[index],
              heartRate: hrs[index],
            ),
          ));
          powerSum += powers[index];
          if (powers[index] > 0) {
            powerCount++;
            minPower = min(powers[index], minPower);
          }
          maxPower = max(powers[index], maxPower);
          speedSum += speeds[index];
          maxSpeed = max(speeds[index], maxSpeed);
          minSpeed = min(speeds[index], minSpeed);
          cadenceSum += cadences[index];
          if (cadences[index] > 0) {
            cadenceCount++;
            minCadence = min(cadences[index], minCadence);
          }
          maxCadence = max(cadences[index], maxCadence);
          hrSum += hrs[index];
          if (hrs[index] > 0) {
            minHr = min(hrs[index], minHr);
            hrCount++;
          }
          maxHr = max(hrs[index], maxHr);
          return index;
        });
        test("$sport, $count -> $powerSum, $maxPower, $minPower, $speedSum, $maxSpeed, $minSpeed",
            () async {
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
          expect(accu.speedCount, count);
          expect(accu.maxSpeed, maxSpeed);
          expect(accu.minSpeed, minSpeed);
          expect(accu.heartRateSum, hrSum);
          expect(accu.heartRateCount, hrCount);
          expect(accu.maxHeartRate, hrCount > 0 ? maxHr : maxInit);
          expect(accu.minHeartRate, hrCount > 0 ? minHr : minInit);
          expect(accu.cadenceSum, cadenceSum);
          expect(accu.cadenceCount, cadenceCount);
          expect(accu.maxCadence, cadenceCount > 0 ? maxCadence : maxInit);
          expect(accu.minCadence, cadenceCount > 0 ? minCadence : minInit);
          expect(accu.avgPower, powerCount > 0 ? powerSum / powerCount : 0.0);
          expect(accu.avgSpeed, count > 0 ? speedSum / count : 0.0);
          expect(accu.avgHeartRate, hrCount > 0 ? hrSum ~/ hrCount : 0);
          expect(accu.avgCadence, cadenceCount > 0 ? cadenceSum ~/ cadenceCount : 0);
        });
      });
    }
  });
}
