import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_serializable.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

class TestSubject extends FitSerializable {}

final fitEpochDateTime = DateTime.utc(1989, 12, 31, 0, 0, 0);

void main() {
  group('addByte test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, MAX_UINT8, rnd).forEach((byte) {
      final expected = [byte];
      test('$byte -> $expected', () async {
        final subject = TestSubject();

        subject.addByte(byte);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  group('addByte negative numbers (2 complement) test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, MAX_UINT8 ~/ 2, rnd).forEach((byte) {
      final expected = byte != 0 ? [MAX_UINT8 - byte] : [0];
      test('-$byte -> $expected', () async {
        final subject = TestSubject();

        subject.addByte(-byte);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  group('addShort test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, MAX_UINT16, rnd).forEach((short) {
      final expected = [short % 256, short ~/ 256];
      test('$short -> $expected', () async {
        final subject = TestSubject();

        subject.addShort(short);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  group('addShort negative numbers (2 complement) test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, MAX_UINT16 ~/ 2, rnd).forEach((short) {
      final complemented = MAX_UINT16 - short;
      final expected = short != 0 ? [complemented % 256, complemented ~/ 256] : [0, 0];
      test('-$short -> $expected', () async {
        final subject = TestSubject();

        subject.addShort(-short);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  group('addLong test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, MAX_UINT32, rnd).forEach((long) {
      final expected = [long % 256, long ~/ 256 % 256, long ~/ 65536 % 256, long ~/ 16777216];
      test('$long -> $expected', () async {
        final subject = TestSubject();

        subject.addLong(long);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  group('addLong negative numbers (2 complement) test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, MAX_UINT32 ~/ 2, rnd).forEach((long) {
      final comp = MAX_UINT32 - long;
      final expected = long != 0 ? [comp % 256, comp ~/ 256 % 256, comp ~/ 65536 % 256, comp ~/ 16777216] : [0, 0, 0, 0];
      test('-$long -> $expected', () async {
        final subject = TestSubject();

        subject.addLong(-long);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  group('setTimeStamp test', () {
    1.to(SMALL_REPETITION).forEach((index) {
      final testDateTime = mockDate(fitEpochDateTime);
      final expected = (testDateTime.millisecondsSinceEpoch - FitSerializable.fitEpoch) ~/ 1000;
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
      final expected = (testDateTime.millisecondsSinceEpoch - FitSerializable.fitEpoch) ~/ 1000;
      test('$testDateTime -> $expected', () async {
        final subject = TestSubject();

        subject.setDateTime(testDateTime);

        expect(subject.timeStamp, expected);
      });
    });
  });

  group('addString test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, MAX_UINT8 ~/ 4, rnd).forEach((length) {
      final string = mockString(length + 1);
      final expected = utf8.encode(string) + [0];
      test('$string -> $expected', () async {
        final subject = TestSubject();

        subject.addString(string);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });
}
