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
  group('isPortNumber corner cases', () {
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
    ].forEach((testPair) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(isPortNumber(testPair.input), testPair.expected);
      });
    });
  });

  group('isPortNumber random test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, 131072, rnd).forEach((number) {
      final expected = number < MAX_UINT16;
      test('$number -> $expected', () async {
        expect(isPortNumber("$number"), expected);
      });
    });
  });
}
