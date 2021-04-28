import 'dart:convert';

import '../../utils/constants.dart';
import 'fit_crc.dart';

abstract class FitSerializable {
  static final fitEpoch = DateTime.utc(1989, 12, 31, 0, 0, 0).millisecondsSinceEpoch;
  List<int> output;

  FitSerializable() {
    output = [];
  }

  void addNonFloatingNumber(int number, int length) {
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

  void addByte(int byte) {
    addNonFloatingNumber(byte, 1);
  }

  void addShort(int integer) {
    addNonFloatingNumber(integer, 2);
  }

  void addLong(int long) {
    addNonFloatingNumber(long, 4);
  }

  void addString(String text) {
    output.addAll(utf8.encode(text));
    output.add(0);
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
