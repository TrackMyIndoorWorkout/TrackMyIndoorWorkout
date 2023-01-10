import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:string_validator/string_validator.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

class TestPair {
  final String input;
  final bool expected;

  const TestPair({required this.input, required this.expected});
}

void main() {
  group('IPv4 corner cases', () {
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
      const TestPair(input: " 1.2.3.4 ", expected: false),
      const TestPair(input: "1.2.3.4 ", expected: false),
      const TestPair(input: "1.2. 3.4", expected: false),
      const TestPair(input: " 1 . 2 . 3 . 4 ", expected: false),
      const TestPair(input: "0.1.2.3", expected: true),
      const TestPair(input: "1.2.3.0", expected: true),
      const TestPair(input: "192.0.0.0", expected: true),
      const TestPair(input: "127.0.0.1", expected: true),
      const TestPair(input: "192.0.0.1", expected: true),
      const TestPair(input: "192.168.1.1", expected: true),
    ]) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(isIP(testPair.input), testPair.expected);
        expect(testPair.input.isIPv4, testPair.expected);
      });
    }
  });

  group('string_validator isIP v4 random test', () {
    final rnd = Random();
    for (var index in List<int>.generate(repetition, (index) => index)) {
      final ipParts = getRandomInts(4, 320, rnd);
      final expected =
          ipParts.fold<bool>(true, (prev, part) => prev && part < maxUint8) && ipParts[0] > 0;
      final addressString = ipParts.map((part) => part.toString()).join(".");
      test('$index.: $addressString -> $expected', () async {
        expect(isIP(addressString), expected);
      });
    }
  });

  group('IPv6 corner cases', () {
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
      const TestPair(input: ":::", expected: true),
      const TestPair(input: " : : : ", expected: false),
      const TestPair(input: "1:2", expected: true),
      const TestPair(input: "1:2:", expected: false),
      const TestPair(input: "1:2:3", expected: true),
      const TestPair(input: "1:2:3:", expected: false),
      const TestPair(input: "1:a:2:3", expected: true),
      const TestPair(input: "1:2:3:444", expected: true),
      const TestPair(input: "1:2:3::444", expected: true),
      const TestPair(input: "1:2:3:444444", expected: false),
      const TestPair(input: "111111:2:3:4", expected: false),
      const TestPair(input: "1:2:3:4:5", expected: true),
      const TestPair(input: "1:2:3:4::5", expected: true),
      const TestPair(input: " 1:2:3:4:5:6:7:8 ", expected: false),
      const TestPair(input: "1:2:3:4:5:6:7:8 ", expected: false),
      const TestPair(input: "1:2: 3:4: 5:6: 7:8", expected: false),
      const TestPair(input: "0:1:2::3", expected: true),
      const TestPair(input: "1:2:3::0", expected: true),
      const TestPair(input: "0000:0000:0000:0000:0000:0000:0000:0001", expected: true),
      const TestPair(input: "::1", expected: true),
      const TestPair(input: "::", expected: true),
    ]) {
      test("${testPair.input} -> ${testPair.expected}", () async {
        expect(isIP(testPair.input) || testPair.input.isIPv6, testPair.expected);
      });
    }
  });

  group('isIP v4 random test', () {
    final rnd = Random();
    for (var index in List<int>.generate(repetition, (index) => index)) {
      final ipParts = getRandomInts(4, 320, rnd);
      final expected = ipParts.fold<bool>(true, (prev, part) => prev && part < maxUint8);
      final addressString = ipParts.map((part) => part.toString()).join(".");
      test('$index.: $addressString -> $expected', () async {
        expect(isIP(addressString), expected);
      });
    }
  });

  group('GetUtils.isIPv4 random test', () {
    final rnd = Random();
    for (var index in List<int>.generate(repetition, (index) => index)) {
      final ipParts = getRandomInts(4, 320, rnd);
      final expected = ipParts.fold<bool>(true, (prev, part) => prev && part < maxUint8);
      final addressString = ipParts.map((part) => part.toString()).join(".");
      test('$index.: $addressString -> $expected', () async {
        expect(addressString.isIPv4, expected);
      });
    }
  });

  group('GetUtils.isIP v6 random test', () {
    final rnd = Random();
    for (var index in List<int>.generate(repetition, (index) => index)) {
      final ipParts = getRandomInts(8, maxUint16, rnd);
      final addressString = ipParts.map((part) => part.toRadixString(16)).join(":");
      test('$index.: $addressString', () async {
        expect(isIP(addressString), true);
      });
    }
  });

  group('GetUtils.isIPv6 random test', () {
    final rnd = Random();
    for (var index in List<int>.generate(repetition, (index) => index)) {
      final ipParts = getRandomInts(8, maxUint16, rnd);
      final addressString = ipParts.map((part) => part.toRadixString(16)).join(":");
      test('$index.: $addressString', () async {
        expect(addressString.isIPv6, true);
      });
    }
  });
}
