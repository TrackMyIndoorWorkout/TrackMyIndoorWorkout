import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/tcx/activity_type.dart';
import 'package:track_my_indoor_exercise/tcx/tcx_model.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/statistics_accumulator.dart';
import 'utils.dart';

void main() {
  group('StatisticsAccumulator calculates avg power when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu = StatisticsAccumulator(sport: sport, calculateAvgPower: true);
        final count = rnd.nextInt(99) + 1;
        double sum = 0.0;
        getRandomDoubles(count, 100, rnd).forEach((number) {
          accu.processTrackPoint(TrackPoint()..power = number);
          sum += number;
        });
        test("$sport, $count -> $sum", () {
          expect(accu.si, null);
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
      });
    });
  });

  group('StatisticsAccumulator calculates max power when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu = StatisticsAccumulator(sport: sport, calculateMaxPower: true);
        final count = rnd.nextInt(99) + 1;
        double maximum = MAX_INIT.toDouble();
        getRandomDoubles(count, 100, rnd).forEach((number) {
          accu.processTrackPoint(TrackPoint()..power = number);
          maximum = max(number, maximum);
        });
        test("$sport, $count -> $maximum", () {
          expect(accu.si, null);
          expect(accu.sport, sport);
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
      });
    });
  });

  group('StatisticsAccumulator calculates avg speed when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu = StatisticsAccumulator(sport: sport, calculateAvgSpeed: true);
        final count = rnd.nextInt(99) + 1;
        double sum = 0.0;
        getRandomDoubles(count, 100, rnd).forEach((number) {
          accu.processTrackPoint(TrackPoint()..speed = number);
          sum += number;
        });
        test("$sport, $count -> $sum", () {
          expect(accu.si, null);
          expect(accu.sport, sport);
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
      });
    });
  });

  group('StatisticsAccumulator calculates max speed when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu = StatisticsAccumulator(sport: sport, calculateMaxSpeed: true);
        final count = rnd.nextInt(99) + 1;
        double maximum = sport == ActivityType.Ride ? MAX_INIT.toDouble() : MIN_INIT.toDouble();
        getRandomDoubles(count, 100, rnd).forEach((number) {
          accu.processTrackPoint(TrackPoint()..speed = number);
          if (sport == ActivityType.Ride) {
            maximum = max(number, maximum);
          } else {
            maximum = min(number, maximum);
          }
        });
        test("$sport, $count -> $maximum", () {
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
          expect(accu.maxSpeed, maximum);
          expect(accu.heartRateSum, null);
          expect(accu.heartRateCount, null);
          expect(accu.maxHeartRate, null);
          expect(accu.cadenceSum, null);
          expect(accu.cadenceCount, null);
          expect(accu.maxCadence, null);
        });
      });
    });
  });

  group('StatisticsAccumulator calculates avg hr when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu = StatisticsAccumulator(sport: sport, calculateAvgHeartRate: true);
        final count = rnd.nextInt(99) + 1;
        int sum = 0;
        int cnt = 0;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processTrackPoint(TrackPoint()..heartRate = number);
          sum += number;
          if (number > 0) {
            cnt++;
          }
        });
        test("$sport, $count -> $sum", () {
          expect(accu.si, null);
          expect(accu.sport, sport);
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
          expect(accu.avgHeartRate, cnt > 0 ? sum ~/ cnt : 0);
        });
      });
    });
  });

  group('StatisticsAccumulator calculates max hr when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu = StatisticsAccumulator(sport: sport, calculateMaxHeartRate: true);
        final count = rnd.nextInt(99) + 1;
        int maximum = MAX_INIT;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processTrackPoint(TrackPoint()..heartRate = number);
          maximum = max(number, maximum);
        });
        test("$sport, $count -> $maximum", () {
          expect(accu.si, null);
          expect(accu.sport, sport);
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
      });
    });
  });

  group('StatisticsAccumulator calculates avg cadence when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu = StatisticsAccumulator(sport: sport, calculateAvgCadence: true);
        final count = rnd.nextInt(99) + 1;
        int sum = 0;
        int cnt = 0;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processTrackPoint(TrackPoint()..cadence = number);
          sum += number;
          if (number > 0) {
            cnt++;
          }
        });
        test("$sport, $count -> $sum", () {
          expect(accu.si, null);
          expect(accu.sport, sport);
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
          expect(accu.avgCadence, cnt > 0 ? sum ~/ cnt : 0);
        });
      });
    });
  });

  group('StatisticsAccumulator initializes max cadence when max requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
        final accu = StatisticsAccumulator(sport: sport, calculateMaxCadence: true);
        final count = rnd.nextInt(99) + 1;
        int maximum = MAX_INIT;
        getRandomInts(count, 100, rnd).forEach((number) {
          accu.processTrackPoint(TrackPoint()..cadence = number);
          maximum = max(number, maximum);
        });
        test("$sport, $count -> $maximum", () {
          expect(accu.si, null);
          expect(accu.sport, sport);
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
      });
    });
  });

  group('StatisticsAccumulator initializes everything when all requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      1.to(SMALL_REPETITION).forEach((input) {
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
          accu.processTrackPoint(TrackPoint()
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
        test("$sport, $count -> $powerSum, $maxPower, $speedSum, $maxSpeed", () {
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
      });
    });
  });
}
