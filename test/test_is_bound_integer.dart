import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/preferences.dart';

import 'utils.dart';

class TestPair {
  final String input;
  final bool expected;

  TestPair({this.input, this.expected});
}

void main() {
  group('isBoundedInteger corner cases', () {
    final rnd = Random();
    [
      TestPair(input: null, expected: false),
      TestPair(input: "", expected: false),
      TestPair(input: " ", expected: false),
      TestPair(input: "*^&@%", expected: false),
      TestPair(input: "abc", expected: false),
      TestPair(input: " abc ", expected: false),
      TestPair(input: " abc123 ", expected: false),
      TestPair(input: " 123abc ", expected: false),
      TestPair(input: "1", expected: true),
      TestPair(input: " 1", expected: true),
      TestPair(input: "1 ", expected: true),
      TestPair(input: "  1  ", expected: true),
    ].forEach((testPair) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(isBoundedInteger(testPair.input, rnd.nextInt(100000)), testPair.expected);
      });
    });
  });

  group('isBoundedInteger random test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, 1000, rnd).forEach((num1) {
      final num2 = rnd.nextInt(2000);
      final expected = num1 <= num2;
      test('$num1 <= $num2 -> $expected', () async {
        expect(isBoundedInteger("$num1", num2), expected);
      });
    });
  });
}
