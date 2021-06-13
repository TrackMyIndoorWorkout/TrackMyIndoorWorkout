import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/preferences.dart';

import 'utils.dart';

class TestPair {
  final String input;
  final bool expected;

  TestPair({required this.input, required this.expected});
}

void main() {
  group('isIpPart corner cases', () {
    [
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
      TestPair(input: "0", expected: false),
      TestPair(input: " 0", expected: false),
      TestPair(input: "0 ", expected: false),
      TestPair(input: "  0  ", expected: false),
    ].forEach((testPair) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(isIpPart(testPair.input, false), testPair.expected);
      });
    });
  });

  group('isIpPart corner cases when allow zero', () {
    [
      TestPair(input: "1", expected: true),
      TestPair(input: " 1", expected: true),
      TestPair(input: "1 ", expected: true),
      TestPair(input: "  1  ", expected: true),
      TestPair(input: "0", expected: true),
      TestPair(input: " 0", expected: true),
      TestPair(input: "0 ", expected: true),
      TestPair(input: "  0  ", expected: true),
    ].forEach((testPair) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(isIpPart(testPair.input, true), testPair.expected);
      });
    });
  });

  group('isIpPart random test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, 512, rnd).forEach((number) {
      bool allowZero = rnd.nextBool();
      final expected = number < MAX_UINT8 && (allowZero || number > 0);
      test('$number, $allowZero -> $expected', () async {
        expect(isIpPart("$number", allowZero), expected);
      });
    });
  });
}
