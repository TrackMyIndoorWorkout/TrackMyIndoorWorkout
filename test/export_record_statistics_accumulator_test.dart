import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/export_record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/statistics_accumulator.dart';
import 'utils.dart';

void main() {
  group('StatisticsAccumulator calculates avg power when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateAvgPower: true);
        final count = rnd.nextInt(99) + 1;
        double sum = 0.0;
        getRandomDoubles(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord()..power = number);
          sum += number;
        });
        test("$sport, $count -> $sum", () async {
          expect(accu.sport, sport);
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
          expect(accu.maxPower, MAX_INIT.toDouble());
          expect(accu.speedSum, 0);
          expect(accu.speedCount, 0);
          expect(accu.maxSpeed, MAX_INIT.toDouble());
          expect(accu.heartRateSum, 0);
          expect(accu.heartRateCount, 0);
          expect(accu.maxHeartRate, MAX_INIT);
          expect(accu.cadenceSum, 0);
          expect(accu.cadenceCount, 0);
          expect(accu.maxCadence, MAX_INIT);
          expect(accu.avgPower, sum / count);
        });
      });
    });
  });

  group('StatisticsAccumulator calculates max power when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMaxPower: true);
        final count = rnd.nextInt(99) + 1;
        double maximum = MAX_INIT.toDouble();
        getRandomDoubles(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord()..power = number);
          maximum = max(number, maximum);
        });
        test("$sport, $count -> $maximum", () async {
          expect(accu.sport, sport);
          expect(accu.calculateAvgPower, false);
          expect(accu.calculateMaxPower, true);
          expect(accu.calculateAvgSpeed, false);
          expect(accu.calculateMaxSpeed, false);
          expect(accu.calculateAvgCadence, false);
          expect(accu.calculateMaxCadence, false);
          expect(accu.calculateAvgHeartRate, false);
          expect(accu.calculateMaxHeartRate, false);
          expect(accu.powerSum, 0);
          expect(accu.powerCount, 0);
          expect(accu.maxPower, maximum);
          expect(accu.speedSum, 0);
          expect(accu.speedCount, 0);
          expect(accu.maxSpeed, MAX_INIT.toDouble());
          expect(accu.heartRateSum, 0);
          expect(accu.heartRateCount, 0);
          expect(accu.maxHeartRate, MAX_INIT);
          expect(accu.cadenceSum, 0);
          expect(accu.cadenceCount, 0);
          expect(accu.maxCadence, MAX_INIT);
        });
      });
    });
  });

  group('StatisticsAccumulator calculates avg speed when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateAvgSpeed: true);
        final count = rnd.nextInt(99) + 1;
        double sum = 0.0;
        getRandomDoubles(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord()..speed = number);
          sum += number;
        });
        test("$sport, $count -> $sum", () async {
          expect(accu.sport, sport);
          expect(accu.calculateAvgPower, false);
          expect(accu.calculateMaxPower, false);
          expect(accu.calculateAvgSpeed, true);
          expect(accu.calculateMaxSpeed, false);
          expect(accu.calculateAvgCadence, false);
          expect(accu.calculateMaxCadence, false);
          expect(accu.calculateAvgHeartRate, false);
          expect(accu.calculateMaxHeartRate, false);
          expect(accu.powerSum, 0);
          expect(accu.powerCount, 0);
          expect(accu.maxPower, MAX_INIT.toDouble());
          expect(accu.speedSum, sum);
          expect(accu.speedCount, count);
          expect(accu.maxSpeed, MAX_INIT.toDouble());
          expect(accu.heartRateSum, 0);
          expect(accu.heartRateCount, 0);
          expect(accu.maxHeartRate, MAX_INIT);
          expect(accu.cadenceSum, 0);
          expect(accu.cadenceCount, 0);
          expect(accu.maxCadence, MAX_INIT);
          expect(accu.avgSpeed, sum / count);
        });
      });
    });
  });

  group('StatisticsAccumulator calculates max speed when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMaxSpeed: true);
        final count = rnd.nextInt(99) + 1;
        double maximum = sport == ActivityType.Ride ? MAX_INIT.toDouble() : MIN_INIT.toDouble();
        getRandomDoubles(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord()..speed = number);
          if (sport == ActivityType.Ride) {
            maximum = max(number, maximum);
          } else {
            maximum = min(number, maximum);
          }
        });
        test("$sport, $count -> $maximum", () async {
          expect(accu.sport, sport);
          expect(accu.calculateAvgPower, false);
          expect(accu.calculateMaxPower, false);
          expect(accu.calculateAvgSpeed, false);
          expect(accu.calculateMaxSpeed, true);
          expect(accu.calculateAvgCadence, false);
          expect(accu.calculateMaxCadence, false);
          expect(accu.calculateAvgHeartRate, false);
          expect(accu.calculateMaxHeartRate, false);
          expect(accu.powerSum, 0);
          expect(accu.powerCount, 0);
          expect(accu.maxPower, MAX_INIT.toDouble());
          expect(accu.speedSum, 0);
          expect(accu.speedCount, 0);
          expect(accu.maxSpeed, maximum);
          expect(accu.heartRateSum, 0);
          expect(accu.heartRateCount, 0);
          expect(accu.maxHeartRate, MAX_INIT);
          expect(accu.cadenceSum, 0);
          expect(accu.cadenceCount, 0);
          expect(accu.maxCadence, MAX_INIT);
        });
      });
    });
  });

  group('StatisticsAccumulator calculates avg hr when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateAvgHeartRate: true);
        final count = rnd.nextInt(99) + 1;
        int sum = 0;
        int cnt = 0;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord()..heartRate = number);
          sum += number;
          if (number > 0) {
            cnt++;
          }
        });
        test("$sport, $count -> $sum", () async {
          expect(accu.sport, sport);
          expect(accu.calculateAvgPower, false);
          expect(accu.calculateMaxPower, false);
          expect(accu.calculateAvgSpeed, false);
          expect(accu.calculateMaxSpeed, false);
          expect(accu.calculateAvgCadence, false);
          expect(accu.calculateMaxCadence, false);
          expect(accu.calculateAvgHeartRate, true);
          expect(accu.calculateMaxHeartRate, false);
          expect(accu.powerSum, 0);
          expect(accu.powerCount, 0);
          expect(accu.maxPower, MAX_INIT.toDouble());
          expect(accu.speedSum, 0);
          expect(accu.speedCount, 0);
          expect(accu.maxSpeed, MAX_INIT.toDouble());
          expect(accu.heartRateSum, sum);
          expect(accu.heartRateCount, cnt);
          expect(accu.maxHeartRate, MAX_INIT);
          expect(accu.cadenceSum, 0);
          expect(accu.cadenceCount, 0);
          expect(accu.maxCadence, MAX_INIT);
          expect(accu.avgHeartRate, cnt > 0 ? sum ~/ cnt : 0);
        });
      });
    });
  });

  group('StatisticsAccumulator calculates max hr when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMaxHeartRate: true);
        final count = rnd.nextInt(99) + 1;
        int maximum = MAX_INIT;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord()..heartRate = number);
          maximum = max(number, maximum);
        });
        test("$sport, $count -> $maximum", () async {
          expect(accu.sport, sport);
          expect(accu.calculateAvgPower, false);
          expect(accu.calculateMaxPower, false);
          expect(accu.calculateAvgSpeed, false);
          expect(accu.calculateMaxSpeed, false);
          expect(accu.calculateAvgCadence, false);
          expect(accu.calculateMaxCadence, false);
          expect(accu.calculateAvgHeartRate, false);
          expect(accu.calculateMaxHeartRate, true);
          expect(accu.powerSum, 0);
          expect(accu.powerCount, 0);
          expect(accu.maxPower, MAX_INIT.toDouble());
          expect(accu.speedSum, 0);
          expect(accu.speedCount, 0);
          expect(accu.maxSpeed, MAX_INIT.toDouble());
          expect(accu.heartRateSum, 0);
          expect(accu.heartRateCount, 0);
          expect(accu.maxHeartRate, maximum);
          expect(accu.cadenceSum, 0);
          expect(accu.cadenceCount, 0);
          expect(accu.maxCadence, MAX_INIT);
        });
      });
    });
  });

  group('StatisticsAccumulator calculates avg cadence when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateAvgCadence: true);
        final count = rnd.nextInt(99) + 1;
        int sum = 0;
        int cnt = 0;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord()..cadence = number);
          sum += number;
          if (number > 0) {
            cnt++;
          }
        });
        test("$sport, $count -> $sum", () async {
          expect(accu.sport, sport);
          expect(accu.calculateAvgPower, false);
          expect(accu.calculateMaxPower, false);
          expect(accu.calculateAvgSpeed, false);
          expect(accu.calculateMaxSpeed, false);
          expect(accu.calculateAvgCadence, true);
          expect(accu.calculateMaxCadence, false);
          expect(accu.calculateAvgHeartRate, false);
          expect(accu.calculateMaxHeartRate, false);
          expect(accu.powerSum, 0);
          expect(accu.powerCount, 0);
          expect(accu.maxPower, MAX_INIT.toDouble());
          expect(accu.speedSum, 0);
          expect(accu.speedCount, 0);
          expect(accu.maxSpeed, MAX_INIT.toDouble());
          expect(accu.heartRateSum, 0);
          expect(accu.heartRateCount, 0);
          expect(accu.maxHeartRate, MAX_INIT);
          expect(accu.cadenceSum, sum);
          expect(accu.cadenceCount, cnt);
          expect(accu.maxCadence, MAX_INIT);
          expect(accu.avgCadence, cnt > 0 ? sum ~/ cnt : 0);
        });
      });
    });
  });

  group('StatisticsAccumulator initializes max cadence when max requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu =
            StatisticsAccumulator(si: rnd.nextBool(), sport: sport, calculateMaxCadence: true);
        final count = rnd.nextInt(99) + 1;
        int maximum = MAX_INIT;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processExportRecord(ExportRecord()..cadence = number);
          maximum = max(number, maximum);
        });
        test("$sport, $count -> $maximum", () async {
          expect(accu.sport, sport);
          expect(accu.calculateAvgPower, false);
          expect(accu.calculateMaxPower, false);
          expect(accu.calculateAvgSpeed, false);
          expect(accu.calculateMaxSpeed, false);
          expect(accu.calculateAvgCadence, false);
          expect(accu.calculateMaxCadence, true);
          expect(accu.calculateAvgHeartRate, false);
          expect(accu.calculateMaxHeartRate, false);
          expect(accu.powerSum, 0);
          expect(accu.powerCount, 0);
          expect(accu.maxPower, MAX_INIT.toDouble());
          expect(accu.speedSum, 0);
          expect(accu.speedCount, 0);
          expect(accu.maxSpeed, MAX_INIT.toDouble());
          expect(accu.heartRateSum, 0);
          expect(accu.heartRateCount, 0);
          expect(accu.maxHeartRate, MAX_INIT);
          expect(accu.cadenceSum, 0);
          expect(accu.cadenceCount, 0);
          expect(accu.maxCadence, maximum);
        });
      });
    });
  });

  group('StatisticsAccumulator initializes everything when all requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu = StatisticsAccumulator(
          si: rnd.nextBool(),
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
        final count = rnd.nextInt(99) + 1;
        double powerSum = 0.0;
        double maxPower = MAX_INIT.toDouble();
        final powers = getRandomDoubles(count, 100, rnd);
        double speedSum = 0.0;
        double maxSpeed = sport == ActivityType.Ride ? MAX_INIT.toDouble() : MIN_INIT.toDouble();
        final speeds = getRandomDoubles(count, 100, rnd);
        int cadenceSum = 0;
        int cadenceCount = 0;
        int maxCadence = MAX_INIT;
        final cadences = getRandomInts(count, 100, rnd);
        int hrSum = 0;
        int hrCount = 0;
        int maxHr = MAX_INIT;
        final hrs = getRandomInts(count, 100, rnd);
        List<int>.generate(count, (index) {
          accu.processExportRecord(ExportRecord()
            ..power = powers[index]
            ..speed = speeds[index]
            ..cadence = cadences[index]
            ..heartRate = hrs[index]);
          powerSum += powers[index];
          maxPower = max(powers[index], maxPower);
          speedSum += speeds[index];
          if (sport == ActivityType.Ride) {
            maxSpeed = max(speeds[index], maxSpeed);
          } else {
            maxSpeed = min(speeds[index], maxSpeed);
          }
          cadenceSum += cadences[index];
          if (cadences[index] > 0) {
            cadenceCount++;
          }
          maxCadence = max(cadences[index], maxCadence);
          hrSum += hrs[index];
          if (hrs[index] > 0) {
            hrCount++;
          }
          maxHr = max(hrs[index], maxHr);
          return index;
        });
        test("$sport, $count -> $powerSum, $maxPower, $speedSum, $maxSpeed", () async {
          expect(accu.sport, sport);
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
          expect(accu.maxHeartRate, hrCount > 0 ? maxHr : MAX_INIT);
          expect(accu.cadenceSum, cadenceSum);
          expect(accu.cadenceCount, cadenceCount);
          expect(accu.maxCadence, cadenceCount > 0 ? maxCadence : MAX_INIT);
          expect(accu.avgPower, powerSum / count);
          expect(accu.avgSpeed, speedSum / count);
          expect(accu.avgHeartRate, hrSum ~/ hrCount);
          expect(accu.avgCadence, cadenceSum ~/ cadenceCount);
        });
      });
    });
  });
}
