import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_data/mock_data.dart';
import 'package:track_my_indoor_exercise/utils/color_ex.dart';
import 'package:track_my_indoor_exercise/utils/string_ex.dart';
import 'package:tuple/tuple.dart';

import 'utils.dart';

void main() {
  group('String Ex uuidString test', () {
    for (final i in List<int>.generate(smallRepetition, (i) => i, growable: false)) {
      final uuidStr = mockUUID().toString();
      final btUuid = uuidStr.substring(4, 8).toLowerCase();
      test("$i. $uuidStr -> $btUuid", () async {
        expect(uuidStr.uuidString(), btUuid);
      });
    }
  });

  group('String Ex rgbString test', () {
    for (final testPair in [
      const Tuple2("0x01", "000001"),
      const Tuple2("0x0012", "000012"),
      const Tuple2("0x0123", "000123"),
      const Tuple2("0x01234", "001234"),
      const Tuple2("0x12345", "012345"),
      const Tuple2("0x0012345", "012345"),
      const Tuple2("0x000012345", "012345"),
      Tuple2(Colors.indigo.toInt32.toRadixString(16), "3F51B5"),
    ]) {
      final expected = testPair.item1.rgbString();
      test("${testPair.item1} -> $expected -> ${testPair.item2}", () async {
        expect(expected, testPair.item2);
      });
    }
  });

  group('String Ex shortAddressString test', () {
    for (final testPair in [
      const Tuple2("ED:7A:58:C4:CA:A0", "ED7A58C4CAA0"),
      const Tuple2("Hello, world! i am 'foo'", "Helloworldiamfoo"),
    ]) {
      final expected = testPair.item1.shortAddressString();
      test("${testPair.item1} -> $expected -> ${testPair.item2}", () async {
        expect(expected, testPair.item2);
      });
    }
  });
}
