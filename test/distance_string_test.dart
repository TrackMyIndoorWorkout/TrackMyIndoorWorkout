import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

import 'utils.dart';

void main() {
  group('distanceString converts values as expected', () {
    final rnd = Random();
    for (final meters in getRandomDoubles(repetition, 40000, rnd)) {
      final expected = meters.toStringAsFixed(0);

      test("$meters -> $expected", () async {
        expect(distanceString(meters, true, true), expected);
      });

      final expected2 = (meters / 1000).toStringAsFixed(2);

      test("$meters -> $expected2", () async {
        expect(distanceString(meters, true, false), expected2);
      });

      final expected3 = (meters * m2yard).toStringAsFixed(0);

      test("$meters -> $expected3", () async {
        expect(distanceString(meters, false, true), expected3);
      });

      final expected4 = (meters * m2mile).toStringAsFixed(2);

      test("$meters -> $expected4", () async {
        expect(distanceString(meters, false, false), expected4);
      });
    }
  });
}
