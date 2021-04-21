import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:track_my_indoor_exercise/export/fit/binary_serializable.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

class TestSubject extends BinarySerializable {}

final fitEpochDateTime = DateTime.utc(1989, 12, 31, 0, 0, 0);

void main() {
  group('addInteger test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, MAX_UINT16, rnd).forEach((integer) {
      final expected = [integer % 256, integer ~/ 256];
      test('$integer -> $expected', () async {
        final subject = TestSubject();

        subject.addInteger(integer);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  group('addLong test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, MAX_UINT16 * MAX_UINT16, rnd).forEach((long) {
      final expected = [long % 256, long ~/ 256 % 256, long ~/ 65536 % 256, long ~/ 16777216];
      test('$long -> $expected', () async {
        final subject = TestSubject();

        subject.addLong(long);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  group('setTimeStamp test', () {
    1.to(SMALL_REPETITION).forEach((index) {
      final testDateTime = mockDate(fitEpochDateTime);
      final expected = (testDateTime.millisecondsSinceEpoch ~/ 1000 - BinarySerializable.fitEpoch);
      test('$testDateTime -> $expected', () async {
        final subject = TestSubject();

        subject.setTimeStamp(testDateTime.millisecondsSinceEpoch);

        expect(subject.timeStamp, expected);
      });
    });
  });

  group('setDateTime test', () {
    1.to(SMALL_REPETITION).forEach((index) {
      final testDateTime = mockDate(fitEpochDateTime);
      final expected = (testDateTime.millisecondsSinceEpoch ~/ 1000 - BinarySerializable.fitEpoch);
      test('$testDateTime -> $expected', () async {
        final subject = TestSubject();

        subject.setDateTime(testDateTime);

        expect(subject.timeStamp, expected);
      });
    });
  });
}
