import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

import 'utils.dart';

void main() {
  group('distanceString cobverts values as expected', () {
    final rnd = Random();
    getRandomDoubles(REPETITION, 40000, rnd).forEach((meters) {
      final expected = meters.toStringAsFixed(0);

      test("$meters -> $expected", () async {
        expect(distanceString(meters, true, true), expected);
      });

      final expected2 = (meters / 1000).toStringAsFixed(2);

      test("$meters -> $expected2", () async {
        expect(distanceString(meters, true, false), expected2);
      });

      final expected3 = (meters * M2YARD).toStringAsFixed(0);

      test("$meters -> $expected3", () async {
        expect(distanceString(meters, false, true), expected3);
      });

      final expected4 = (meters * M2MILE).toStringAsFixed(2);

      test("$meters -> $expected4", () async {
        expect(distanceString(meters, false, false), expected4);
      });
    });
  });
}
