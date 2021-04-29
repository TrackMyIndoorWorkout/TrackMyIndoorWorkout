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

        subject.addByte(-byte, signed: true);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  test('addByte of unsigned null serializes invalid value', () async {
    final subject = TestSubject();

    subject.addByte(null);

    expect(listEquals(subject.output, [0xFF]), true);
  });

  test('addByte of signed null serializes invalid value', () async {
    final subject = TestSubject();

    subject.addByte(null, signed: true);

    expect(listEquals(subject.output, [0x7F]), true);
  });

  group('addShort test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, MAX_UINT16, rnd).forEach((short) {
      final expected = [short % MAX_UINT8, short ~/ MAX_UINT8];
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
      final expected = short != 0 ? [complemented % MAX_UINT8, complemented ~/ MAX_UINT8] : [0, 0];
      test('-$short -> $expected', () async {
        final subject = TestSubject();

        subject.addShort(-short, signed: true);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  test('addShort of unsigned null serializes invalid value', () async {
    final subject = TestSubject();

    subject.addShort(null);

    expect(listEquals(subject.output, [0xFF, 0xFF]), true);
  });

  test('addShort of signed null serializes invalid value', () async {
    final subject = TestSubject();

    subject.addShort(null, signed: true);

    expect(listEquals(subject.output, [0xFF, 0x7F]), true);
  });

  group('addLong test', () {
    final rnd = Random();
    getRandomInts(SMALL_REPETITION, MAX_UINT32, rnd).forEach((long) {
      final expected = [
        long % MAX_UINT8,
        long ~/ MAX_UINT8 % MAX_UINT8,
        long ~/ MAX_UINT16 % MAX_UINT8,
        long ~/ MAX_UINT24
      ];
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
      final expected = long != 0
          ? [
              comp % MAX_UINT8,
              comp ~/ MAX_UINT8 % MAX_UINT8,
              comp ~/ MAX_UINT16 % MAX_UINT8,
              comp ~/ MAX_UINT24
            ]
          : [0, 0, 0, 0];
      test('-$long -> $expected', () async {
        final subject = TestSubject();

        subject.addLong(-long, signed: true);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  test('addLong of unsigned null serializes invalid value', () async {
    final subject = TestSubject();

    subject.addLong(null);

    expect(listEquals(subject.output, [0xFF, 0xFF, 0xFF, 0xFF]), true);
  });

  test('addLong of signed null serializes invalid value', () async {
    final subject = TestSubject();

    subject.addLong(null, signed: true);

    expect(listEquals(subject.output, [0xFF, 0xFF, 0xFF, 0x7F]), true);
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

  group('addGpsCoordinate test', () {
    final rnd = Random();
    getRandomDoubles(SMALL_REPETITION, 360.0, rnd).forEach((degree) {
      final coordinate = degree - 180.0;
      final coordinateInt = (coordinate * DEG_TO_FIT_GPS).round();
      final subject1 = TestSubject();

      subject1.addLong(coordinateInt);

      test('$coordinate -> ${subject1.output}', () async {
        final subject2 = TestSubject();

        subject2.addGpsCoordinate(coordinate);

        expect(subject2.output, subject1.output);
      });
    });
  });

  group('fitTimeStamp test', () {
    1.to(SMALL_REPETITION).forEach((index) {
      final testDateTime = mockDate(fitEpochDateTime);
      final expected =
          (testDateTime.millisecondsSinceEpoch - fitEpochDateTime.millisecondsSinceEpoch) ~/ 1000;
      test('$testDateTime -> $expected', () async {
        final timeStamp = FitSerializable.fitTimeStamp(testDateTime.millisecondsSinceEpoch);

        expect(timeStamp, expected);
      });
    });
  });

  group('fitDateTime test', () {
    1.to(SMALL_REPETITION).forEach((index) {
      final testDateTime = mockDate(fitEpochDateTime);
      final expected =
          (testDateTime.millisecondsSinceEpoch - fitEpochDateTime.millisecondsSinceEpoch) ~/ 1000;
      test('$testDateTime -> $expected', () async {
        final timeStamp = FitSerializable.fitDateTime(testDateTime);

        expect(timeStamp, expected);
      });
    });
  });
}
