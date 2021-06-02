import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/preferences.dart';

import 'utils.dart';

class TestPair {
  final String input;
  final bool expected;

  TestPair({this.input, this.expected});
}

void main() {
  group('isIpAddress corner cases', () {
    [
      TestPair(input: null, expected: false),
      TestPair(input: "", expected: false),
      TestPair(input: " ", expected: false),
      TestPair(input: "*^&@%", expected: false),
      TestPair(input: "abc", expected: false),
      TestPair(input: " abc ", expected: false),
      TestPair(input: " abc123 ", expected: false),
      TestPair(input: " 123abc ", expected: false),
      TestPair(input: "1", expected: false),
      TestPair(input: " 1", expected: false),
      TestPair(input: "1 ", expected: false),
      TestPair(input: "  1  ", expected: false),
      TestPair(input: "1.", expected: false),
      TestPair(input: "...", expected: false),
      TestPair(input: " . . . ", expected: false),
      TestPair(input: "1.2", expected: false),
      TestPair(input: "1.2.", expected: false),
      TestPair(input: "1.2.3", expected: false),
      TestPair(input: "1.2.3.", expected: false),
      TestPair(input: "1.a.2.3", expected: false),
      TestPair(input: "1.2.3.444", expected: false),
      TestPair(input: "1111.2.3.4", expected: false),
      TestPair(input: "1.2.3.4.5", expected: false),
      TestPair(input: "-1.2.3.4", expected: false),
      TestPair(input: "1.-2.3.4", expected: false),
      TestPair(input: "1.2.3.4", expected: true),
      TestPair(input: " 1.2.3.4 ", expected: true),
      TestPair(input: "1.2.3.4 ", expected: true),
      TestPair(input: "1.2. 3.4", expected: false),
      TestPair(input: " 1 . 2 . 3 . 4 ", expected: false),
      TestPair(input: "0.1.2.3", expected: false),
      TestPair(input: "1.2.3.0", expected: true),
      TestPair(input: "192.0.0.0", expected: true),
      TestPair(input: "192.0.0.1", expected: true),
      TestPair(input: "192.168.1.1", expected: true),
    ].forEach((testPair) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(isIpAddress(testPair.input), testPair.expected);
      });
    });
  });

  group('isIpAddress random test', () {
    final rnd = Random();
    List.generate(REPETITION, (index) => index).forEach((index) {
      final ipParts = getRandomInts(4, 320, rnd);
      final expected =
          ipParts.fold(true, (prev, part) => prev && part < MAX_UINT8) && ipParts[0] > 0;
      final addressString = ipParts.map((part) => part.toString()).join(".");
      test('$addressString -> $expected', () async {
        expect(isIpAddress(addressString), expected);
      });
    });
  });
}
