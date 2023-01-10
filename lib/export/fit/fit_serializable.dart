import 'dart:convert';
import 'dart:math';

import '../../utils/constants.dart';
import 'fit_base_type.dart';
import 'fit_crc.dart';

abstract class FitSerializable {
  static final fitEpoch = DateTime.utc(1989, 12, 31, 0, 0, 0).millisecondsSinceEpoch;
  late List<int> output = [];

  void addNonFloatingNumber(int? number, int length, {bool signed = false}) {
    bool wasNull = number == null;
    if (number == null) {
      if (length == 1) {
        number = signed ? FitBaseTypes.sint8Type.invalidValue : FitBaseTypes.uint8Type.invalidValue;
      } else if (length == 2) {
        number =
            signed ? FitBaseTypes.sint16Type.invalidValue : FitBaseTypes.uint16Type.invalidValue;
      } else if (length == 4) {
        number =
            signed ? FitBaseTypes.sint32Type.invalidValue : FitBaseTypes.uint32Type.invalidValue;
      } else {
        number = 0;
      }
    }

    int threshold = maxUint8;
    if (length == 2) {
      threshold = maxUint16;
    } else if (length == 3) {
      threshold = maxUint24;
    } else if (length == 4) {
      threshold = maxUint32;
    }

    // Two compliments flipping
    if (number < 0) {
      number += threshold;
    }

    if (!wasNull) {
      // Limiting to maximum
      // -2 because
      // 1. -1 would result in 0 by the later modulo operator
      // 2. -1 would match the invalid value constant in many cases
      // And we shouldn't limit when the number was null (it is now invalid value)
      number = min(number, threshold - 2);
    }

    for (int i = 0; i < length; i++) {
      output.add(number! % maxUint8);
      number ~/= maxUint8;
    }
  }

  void addByte(int? byte, {bool signed = false}) {
    addNonFloatingNumber(byte, 1, signed: signed);
  }

  void addShort(int? integer, {bool signed = false}) {
    addNonFloatingNumber(integer, 2, signed: signed);
  }

  void addLong(int? long, {bool signed = false}) {
    addNonFloatingNumber(long, 4, signed: signed);
  }

  void addString(String text) {
    output.addAll(utf8.encode(text));
    output.add(0);
  }

  void addGpsCoordinate(double coordinate) {
    addLong((coordinate * degToFitGps).round(), signed: true);
  }

  List<int> binarySerialize() {
    addShort(crcData(output));
    return output;
  }

  static int fitTimeStamp(int? unixMilliseconds) {
    if (unixMilliseconds == null) {
      return 0;
    }

    return (unixMilliseconds - fitEpoch) ~/ 1000;
  }

  static int fitDateTime(DateTime dateTime) {
    return fitTimeStamp(dateTime.millisecondsSinceEpoch);
  }
}
