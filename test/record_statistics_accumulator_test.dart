import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import '../lib/persistence/models/record.dart';
import '../lib/tcx/activity_type.dart';
import '../lib/utils/constants.dart';
import '../lib/utils/display.dart';
import '../lib/utils/statistics_accumulator.dart';
import 'utils.dart';

void main() {
  group('StatisticsAccumulator calculates avg power when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      final accu = StatisticsAccumulator(sport: sport, calculateAvgPower: true);
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
      test("$count ($sport) -> $sum", () {
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
        expect(accu.avgPower, count > 0 ? sum / count : 0);
      });
    });
  });

  group('StatisticsAccumulator calculates max power when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      final accu = StatisticsAccumulator(sport: sport, calculateMaxPower: true);
      final count = rnd.nextInt(99) + 1;
      int maximum = MAX_INIT;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(power: number, sport: sport));
        maximum = max(number, maximum);
      });
      test("$count ($sport) -> $maximum", () {
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

  group('StatisticsAccumulator calculates avg speed when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateAvgSpeed: true);
      var count = rnd.nextInt(99) + 1;
      double sum = 0.0;
      getRandomDoubles(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(speed: number, sport: sport));
        if (number > 0) {
          sum += speedOrPace(number, si, sport);
        } else {
          count--;
        }
      });
      test("$count ($sport) -> $sum", () {
        expect(accu.si, si);
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
        expect(accu.avgSpeed, count > 0 ? sum / count : 0);
      });
    });
  });

  group('StatisticsAccumulator calculates max speed when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateMaxSpeed: true);
      final count = rnd.nextInt(99) + 1;
      double maximum = sport == ActivityType.Ride ? MAX_INIT.toDouble() : MIN_INIT.toDouble();
      getRandomDoubles(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(speed: number, sport: sport));
        final speed = speedOrPace(number, si, sport);
        if (sport == ActivityType.Ride) {
          maximum = max(speed, maximum);
        } else {
          maximum = min(speed, maximum);
        }
      });
      test("$count ($sport) -> $maximum", () {
        expect(accu.si, si);
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

  group('StatisticsAccumulator calculates avg hr when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
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
      test("$count ($sport) -> $sum", () {
        expect(accu.si, si);
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
        expect(accu.heartRateCount, count);
        expect(accu.maxHeartRate, null);
        expect(accu.cadenceSum, null);
        expect(accu.cadenceCount, null);
        expect(accu.maxCadence, null);
        expect(accu.avgHeartRate, count > 0 ? sum ~/ count : 0);
      });
    });
  });

  group('StatisticsAccumulator calculates max hr when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateMaxHeartRate: true);
      final count = rnd.nextInt(99) + 1;
      int maximum = MAX_INIT;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(heartRate: number, sport: sport));
        maximum = max(number, maximum);
      });
      test("$count ($sport) -> $maximum", () {
        expect(accu.si, si);
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

  group('StatisticsAccumulator calculates avg cadence when requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
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
      test("$count ($sport) -> $sum", () {
        expect(accu.si, si);
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
        expect(accu.cadenceCount, count);
        expect(accu.maxCadence, null);
        expect(accu.avgCadence, count > 0 ? sum ~/ count : 0);
      });
    });
  });

  group('StatisticsAccumulator calculates max cadence when max requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(si: si, sport: sport, calculateMaxCadence: true);
      final count = rnd.nextInt(99) + 1;
      int maximum = MAX_INIT;
      getRandomInts(count, 100, rnd).forEach((number) {
        accu.processRecord(RecordWithSport(cadence: number, sport: sport));
        maximum = max(number, maximum);
      });
      test("$count ($sport) -> $maximum", () {
        expect(accu.si, si);
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

  group('StatisticsAccumulator calculates everything when all requested', () {
    final rnd = Random();
    SPORTS.forEach((sport) {
      final si = rnd.nextBool();
      final accu = StatisticsAccumulator(
        si: si,
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
      int powerSum = 0;
      int powerCount = 0;
      int maxPower = MAX_INIT;
      final powers = getRandomInts(count, 100, rnd);
      double speedSum = 0.0;
      int speedCount = 0;
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
        final speed = speedOrPace(speeds[index], si, sport);
        speedSum += speed;
        if (speed > 0) {
          speedCount++;
        }
        if (sport == ActivityType.Ride) {
          maxSpeed = max(speed, maxSpeed);
        } else {
          maxSpeed = min(speed, maxSpeed);
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
      test("$count ($sport) -> $powerSum, $maxPower, $speedSum, $maxSpeed", () {
        expect(accu.si, si);
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
        expect(accu.powerCount, powerCount);
        expect(accu.maxPower, maxPower);
        expect(accu.speedSum, speedSum);
        expect(accu.speedCount, speedCount);
        expect(accu.maxSpeed, maxSpeed);
        expect(accu.heartRateSum, hrSum);
        expect(accu.heartRateCount, hrCount);
        expect(accu.maxHeartRate, maxHr);
        expect(accu.cadenceSum, cadenceSum);
        expect(accu.cadenceCount, cadenceCount);
        expect(accu.maxCadence, maxCadence);
        expect(accu.avgPower, powerCount > 0 ? powerSum / powerCount : 0);
        expect(accu.avgSpeed, speedCount > 0 ? speedSum / speedCount : 0);
        expect(accu.avgHeartRate, hrCount > 0 ? hrSum ~/ hrCount : 0);
        expect(accu.avgCadence, cadenceCount > 0 ? cadenceSum ~/ cadenceCount : 0);
      });
    });
  });
}
