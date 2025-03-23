import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_base_type.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_data.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_definition_message.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_field.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_string_field.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

class FitDefinitionMessageTest extends FitDefinitionMessage {
  FitDefinitionMessageTest({localMessageType, globalMessageNumber})
    : super(localMessageType, globalMessageNumber);

  @override
  List<int> serializeData(dynamic parameter) {
    return super.binarySerialize();
  }
}

class FitStringFieldTest extends FitDefinitionMessage {
  final int definitionNumber;
  final int byte1;
  final String text;
  final int byte2;

  FitStringFieldTest({
    localMessageType,
    globalMessageNumber,
    required this.definitionNumber,
    required this.byte1,
    required this.text,
    required this.byte2,
  }) : super(localMessageType, globalMessageNumber) {
    fields = [
      FitField(definitionNumber, FitBaseTypes.uint8Type),
      FitStringField(definitionNumber + 1, text.length),
      FitField(definitionNumber + 2, FitBaseTypes.uint8Type),
    ];
  }

  @override
  List<int> serializeData(dynamic parameter) {
    var data = FitData();
    data.output = [localMessageType, 0];
    data.addByte(byte1);
    data.addString(text);
    data.addByte(byte2);
    return data.output;
  }
}

void main() {
  group('FitDefinition without fields handle globalMessageNumber well', () {
    final rnd = Random();
    getRandomInts(smallRepetition, maxUint16, rnd).forEach((short) {
      final bigEndian = rnd.nextBool(); // Big Endian?
      final shortLsb = short % maxUint8;
      final shortMsb = short ~/ maxUint8;
      final localMessageType = rnd.nextInt(8);
      final expected = [
        FitDefinitionMessage.fourtyRecord + localMessageType,
        0,
        bigEndian ? 1 : 0,
        shortLsb,
        shortMsb,
        0,
      ];
      test('$short -> $expected', () async {
        final subject = FitDefinitionMessageTest(
          localMessageType: localMessageType,
          globalMessageNumber: short,
        )..architecture = bigEndian ? 1 : 0;

        final output = subject.serializeData(null);

        expect(listEquals(output, expected), true);
      });
    });
  });

  group('FitDefinition strings serialize properly', () {
    final rnd = Random();
    getRandomInts(smallRepetition, maxUint8 ~/ 8, rnd).forEach((length) {
      final byte1 = rnd.nextInt(maxByte);
      final text = mockString(length + 1);
      final byte2 = rnd.nextInt(maxByte);
      final localMessageType = rnd.nextInt(6);
      final globalMessageNumber = rnd.nextInt(maxUint16);
      final definitionNumber = rnd.nextInt(6);
      final expected = [localMessageType, 0, byte1] + utf8.encode(text) + [0, byte2];
      test('$text($length) -> $expected', () async {
        final subject = FitStringFieldTest(
          localMessageType: localMessageType,
          globalMessageNumber: globalMessageNumber,
          definitionNumber: definitionNumber,
          byte1: byte1,
          text: text,
          byte2: byte2,
        );

        final output = subject.serializeData(null);

        expect(listEquals(output, expected), true);
      });
    });

    group('FitDefinition strings with headers serialize properly', () {
      final rnd = Random();
      getRandomInts(smallRepetition, maxUint8 ~/ 8, rnd).forEach((length) {
        final byte1 = rnd.nextInt(maxByte);
        final text = mockString(length + 1);
        final byte2 = rnd.nextInt(maxByte);
        final localMessageType = rnd.nextInt(6);
        final globalMessageNumber = rnd.nextInt(maxUint16);
        final definitionNumber = rnd.nextInt(6);
        final shortLsb = globalMessageNumber % maxUint8;
        final shortMsb = globalMessageNumber ~/ maxUint8;
        final expected = [
          FitDefinitionMessage.fourtyRecord + localMessageType,
          0,
          0,
          shortLsb,
          shortMsb,
          3,
          definitionNumber,
          FitBaseTypes.uint8Type.size,
          FitBaseTypes.uint8Type.id,
          definitionNumber + 1,
          text.length + 1,
          FitBaseTypes.stringType.id,
          definitionNumber + 2,
          FitBaseTypes.uint8Type.size,
          FitBaseTypes.uint8Type.id,
        ];
        test('$text($length) -> $expected', () async {
          final subject = FitStringFieldTest(
            localMessageType: localMessageType,
            globalMessageNumber: globalMessageNumber,
            definitionNumber: definitionNumber,
            byte1: byte1,
            text: text,
            byte2: byte2,
          );

          final output = subject.binarySerialize();

          expect(listEquals(output, expected), true);
        });
      });
    });
  });
}
