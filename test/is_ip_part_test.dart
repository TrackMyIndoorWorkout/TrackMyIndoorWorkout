import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/preferences.dart';

import 'utils.dart';

class TestPair {
  final String input;
  final bool expected;

  const TestPair({required this.input, required this.expected});
}

void main() {
  group('isIpPart corner cases', () {
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
        expect(isIpPart(testPair.input, false), testPair.expected);
      });
    }
  });

  group('isIpPart corner cases when allow zero', () {
    for (final testPair in [
      const TestPair(input: "1", expected: true),
      const TestPair(input: " 1", expected: true),
      const TestPair(input: "1 ", expected: true),
      const TestPair(input: "  1  ", expected: true),
      const TestPair(input: "0", expected: true),
      const TestPair(input: " 0", expected: true),
      const TestPair(input: "0 ", expected: true),
      const TestPair(input: "  0  ", expected: true),
    ]) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(isIpPart(testPair.input, true), testPair.expected);
      });
    }
  });

  group('isIpPart random test', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 512, rnd).forEach((number) {
      bool allowZero = rnd.nextBool();
      final expected = number < maxUint8 && (allowZero || number > 0);
      test('$number, $allowZero -> $expected', () async {
        expect(isIpPart("$number", allowZero), expected);
      });
    });
  });
}
