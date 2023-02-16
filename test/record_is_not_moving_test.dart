import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final String comment;
  final Record record;
  final bool expected;

  const TestPair({required this.comment, required this.record, required this.expected});
}

void main() {
  group('Record isNotMoving works as expected', () {
    final rnd = Random();
    for (final testPair in [
      TestPair(
        comment: "power moves",
        record: Record(
          power: 1,
          speed: 0.0,
          pace: null,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          cadence: 0,
        ),
        expected: false,
      ),
      TestPair(
        comment: "speed moves",
        record: Record(
          power: 0,
          speed: eps * 2,
          pace: null,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          cadence: 0,
        ),
        expected: false,
      ),
      TestPair(
        comment: "pace moves",
        record: Record(
          power: 0,
          speed: 0.0,
          pace: 10.0,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          cadence: 0,
        ),
        expected: false,
      ),
      TestPair(
        comment: "cal/h moves",
        record: Record(
          power: 0,
          speed: 0.0,
          pace: 0.0,
          caloriesPerHour: eps * 2,
          caloriesPerMinute: null,
          cadence: 0,
        ),
        expected: false,
      ),
      TestPair(
        comment: "cal/min moves",
        record: Record(
          power: 0,
          speed: 0.0,
          pace: 0.0,
          caloriesPerHour: null,
          caloriesPerMinute: eps * 2,
          cadence: 0,
        ),
        expected: false,
      ),
      TestPair(
        comment: "cadence moves",
        record: Record(
          power: 0,
          speed: 0.0,
          pace: 0.0,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          cadence: 1,
        ),
        expected: false,
      ),
      TestPair(
        comment: "slow speed stops",
        record: Record(
          power: 0,
          speed: eps / 2,
          pace: 0.0,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          cadence: 0,
        ),
        expected: true,
      ),
      TestPair(
        comment: "slow cal/h stops",
        record: Record(
          power: 0,
          speed: 0.0,
          pace: 0.0,
          caloriesPerHour: eps / 2,
          caloriesPerMinute: null,
          cadence: 0,
        ),
        expected: true,
      ),
      TestPair(
        comment: "slow cal/min stops",
        record: Record(
          power: 0,
          speed: 0.0,
          pace: 0.0,
          caloriesPerHour: null,
          caloriesPerMinute: eps / 2,
          cadence: 0,
        ),
        expected: true,
      ),
      TestPair(
        comment: "empty stops",
        record: Record(
          power: 0,
          speed: 0.0,
          pace: 0.0,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          cadence: 0,
        ),
        expected: true,
      ),
      TestPair(
        comment: "all null stops",
        record: Record(
          power: null,
          speed: null,
          pace: null,
          caloriesPerHour: null,
          caloriesPerMinute: null,
          cadence: null,
        ),
        expected: true,
      ),
      TestPair(
        comment: "all zero stops",
        record: Record(
          power: 0,
          speed: 0.0,
          pace: 0.0,
          caloriesPerHour: 0.0,
          caloriesPerMinute: 0.0,
          cadence: 0,
        ),
        expected: true,
      ),
      TestPair(
        comment: "default stops",
        record: Record(),
        expected: true,
      ),
    ]) {
      test(testPair.comment, () async {
        final record = testPair.record;
        record.elapsed = rnd.nextInt(600);
        record.distance = rnd.nextDouble() * 1000.0;
        record.calories = rnd.nextInt(600);
        expect(testPair.record.isNotMoving(), testPair.expected);
      });
    }
  });
}
