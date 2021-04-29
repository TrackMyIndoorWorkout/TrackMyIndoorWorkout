import 'dart:convert';

import '../../utils/constants.dart';
import 'fit_base_type.dart';
import 'fit_crc.dart';

abstract class FitSerializable {
  static final fitEpoch = DateTime.utc(1989, 12, 31, 0, 0, 0).millisecondsSinceEpoch;
  List<int> output;

  FitSerializable() {
    output = [];
  }

  void addNonFloatingNumber(int number, int length, {bool signed = false}) {
    if (number == null) {
      if (length == 1) {
        number = signed ? FitBaseTypes.sint8Type.invalidValue : FitBaseTypes.uint8Type.invalidValue;
      } else if (length == 2) {
        number =
            signed ? FitBaseTypes.sint16Type.invalidValue : FitBaseTypes.uint16Type.invalidValue;
      } else if (length == 4) {
        number =
            signed ? FitBaseTypes.sint32Type.invalidValue : FitBaseTypes.uint32Type.invalidValue;
      }
    }

    if (number < 0) {
      // Two compliments flipping
      int threshold = MAX_UINT8;
      if (length == 2) {
        threshold = MAX_UINT16;
      } else if (length == 3) {
        threshold = MAX_UINT24;
      } else if (length == 4) {
        threshold = MAX_UINT32;
      }

      number += threshold;
    }

    for (int i = 0; i < length; i++) {
      output.add(number % MAX_UINT8);
      number ~/= MAX_UINT8;
    }
    assert(number == 0);
  }

  void addByte(int byte, {bool signed = false}) {
    addNonFloatingNumber(byte, 1, signed: signed);
  }

  void addShort(int integer, {bool signed = false}) {
    addNonFloatingNumber(integer, 2, signed: signed);
  }

  void addLong(int long, {bool signed = false}) {
    addNonFloatingNumber(long, 4, signed: signed);
  }

  void addString(String text) {
    output.addAll(utf8.encode(text));
    output.add(0);
  }

  void addGpsCoordinate(double coordinate) {
    addLong((coordinate * DEG_TO_FIT_GPS).round(), signed: true);
  }

  List<int> binarySerialize() {
    addShort(crcData(output));
    return output;
  }

  static int fitTimeStamp(int unixMilliseconds) {
    return (unixMilliseconds - fitEpoch) ~/ 1000;
  }

  static int fitDateTime(DateTime dateTime) {
    return fitTimeStamp(dateTime.millisecondsSinceEpoch);
  }
}
