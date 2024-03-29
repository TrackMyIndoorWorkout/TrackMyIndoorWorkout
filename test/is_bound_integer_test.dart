import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/preferences.dart';

import 'utils.dart';

class TestPair {
  final String input;
  final bool expected;

  const TestPair({required this.input, required this.expected});
}

void main() {
  group('isBoundedInteger corner cases', () {
    final rnd = Random();
    for (final testPair in [
      const TestPair(input: "", expected: false),
      const TestPair(input: " ", expected: false),
      const TestPair(input: "*^&@%", expected: false),
      const TestPair(input: "abc", expected: false),
      const TestPair(input: " abc ", expected: false),
      const TestPair(input: " abc123 ", expected: false),
      const TestPair(input: " 123abc ", expected: false),
      const TestPair(input: "1", expected: true),
      const TestPair(input: " 1", expected: true),
      const TestPair(input: "1 ", expected: true),
      const TestPair(input: "  1  ", expected: true),
      const TestPair(input: "0", expected: false),
      const TestPair(input: " 0", expected: false),
      const TestPair(input: "0 ", expected: false),
      const TestPair(input: "  0  ", expected: false),
    ]) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(isBoundedInteger(testPair.input, 1, rnd.nextInt(100000)), testPair.expected);
      });
    }
  });

  group('isBoundedInteger random test', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 1000, rnd).forEach((num1) {
      final num2 = rnd.nextInt(100);
      final num3 = rnd.nextInt(2000);
      final expected = num1 <= num3 && num1 >= num2;
      test('$num2 <= $num1 <= $num3 -> $expected', () async {
        expect(isBoundedInteger("$num1", num2, num3), expected);
      });
    });
  });
}
