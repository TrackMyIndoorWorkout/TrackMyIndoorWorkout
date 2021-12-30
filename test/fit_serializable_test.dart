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
    getRandomInts(smallRepetition, maxUint8, rnd).forEach((byte) {
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
    getRandomInts(smallRepetition, maxUint8 ~/ 2, rnd).forEach((byte) {
      final expected = byte != 0 ? [maxUint8 - byte] : [0];
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
    getRandomInts(smallRepetition, maxUint16, rnd).forEach((short) {
      final expected = [short % maxUint8, short ~/ maxUint8];
      test('$short -> $expected', () async {
        final subject = TestSubject();

        subject.addShort(short);

        expect(listEquals(subject.output, expected), true);
      });
    });
  });

  group('addShort negative numbers (2 complement) test', () {
    final rnd = Random();
    getRandomInts(smallRepetition, maxUint16 ~/ 2, rnd).forEach((short) {
      final complemented = maxUint16 - short;
      final expected = short != 0 ? [complemented % maxUint8, complemented ~/ maxUint8] : [0, 0];
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
    getRandomInts(smallRepetition, maxUint32, rnd).forEach((long) {
      final expected = [
        long % maxUint8,
        long ~/ maxUint8 % maxUint8,
        long ~/ maxUint16 % maxUint8,
        long ~/ maxUint24
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
    getRandomInts(smallRepetition, maxUint32 ~/ 2, rnd).forEach((long) {
      final comp = maxUint32 - long;
      final expected = long != 0
          ? [
              comp % maxUint8,
              comp ~/ maxUint8 % maxUint8,
              comp ~/ maxUint16 % maxUint8,
              comp ~/ maxUint24
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
    getRandomInts(smallRepetition, maxUint8 ~/ 4, rnd).forEach((length) {
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
    getRandomDoubles(smallRepetition, 360.0, rnd).forEach((degree) {
      final coordinate = degree - 180.0;
      final coordinateInt = (coordinate * degToFitGps).round();
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
    1.to(smallRepetition).forEach((index) {
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
    1.to(smallRepetition).forEach((index) {
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
