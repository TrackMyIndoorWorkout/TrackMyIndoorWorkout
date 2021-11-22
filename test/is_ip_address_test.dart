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
  group('isIpAddress corner cases', () {
    for (final testPair in [
      const TestPair(input: "", expected: false),
      const TestPair(input: " ", expected: false),
      const TestPair(input: "*^&@%", expected: false),
      const TestPair(input: "abc", expected: false),
      const TestPair(input: " abc ", expected: false),
      const TestPair(input: " abc123 ", expected: false),
      const TestPair(input: " 123abc ", expected: false),
      const TestPair(input: "1", expected: false),
      const TestPair(input: " 1", expected: false),
      const TestPair(input: "1 ", expected: false),
      const TestPair(input: "  1  ", expected: false),
      const TestPair(input: "1.", expected: false),
      const TestPair(input: "...", expected: false),
      const TestPair(input: " . . . ", expected: false),
      const TestPair(input: "1.2", expected: false),
      const TestPair(input: "1.2.", expected: false),
      const TestPair(input: "1.2.3", expected: false),
      const TestPair(input: "1.2.3.", expected: false),
      const TestPair(input: "1.a.2.3", expected: false),
      const TestPair(input: "1.2.3.444", expected: false),
      const TestPair(input: "1111.2.3.4", expected: false),
      const TestPair(input: "1.2.3.4.5", expected: false),
      const TestPair(input: "-1.2.3.4", expected: false),
      const TestPair(input: "1.-2.3.4", expected: false),
      const TestPair(input: "1.2.3.4", expected: true),
      const TestPair(input: " 1.2.3.4 ", expected: true),
      const TestPair(input: "1.2.3.4 ", expected: true),
      const TestPair(input: "1.2. 3.4", expected: false),
      const TestPair(input: " 1 . 2 . 3 . 4 ", expected: false),
      const TestPair(input: "0.1.2.3", expected: false),
      const TestPair(input: "1.2.3.0", expected: true),
      const TestPair(input: "192.0.0.0", expected: true),
      const TestPair(input: "192.0.0.1", expected: true),
      const TestPair(input: "192.168.1.1", expected: true),
    ]) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(isIpAddress(testPair.input), testPair.expected);
      });
    }
  });

  group('isIpAddress random test', () {
    final rnd = Random();
    List.generate(REPETITION, (index) => index).forEach((index) {
      final ipParts = getRandomInts(4, 320, rnd);
      final expected =
          ipParts.fold<bool>(true, (prev, part) => prev && part < MAX_UINT8) && ipParts[0] > 0;
      final addressString = ipParts.map((part) => part.toString()).join(".");
      test('$addressString -> $expected', () async {
        expect(isIpAddress(addressString), expected);
      });
    });
  });
}
