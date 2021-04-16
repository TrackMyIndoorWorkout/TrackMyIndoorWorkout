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
  group('isIpPart corner cases', () {
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
        expect(isIpPart(testPair.input), testPair.expected);
      });
    });
  });

  group('isIpPart random test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, 512, rnd).forEach((number) {
      final expected = number <= 256;
      test('$number -> $expected', () async {
        expect(isIpPart("$number"), expected);
      });
    });
  });
}
