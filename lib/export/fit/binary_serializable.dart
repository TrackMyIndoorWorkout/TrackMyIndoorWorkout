import 'fit_crc.dart';

abstract class BinarySerializable {
  static final fitEpoch = DateTime.utc(1989, 12, 31, 0, 0, 0).millisecondsSinceEpoch;

  int timeStamp; // seconds since FIT epoch (1989/12/31 UTC)
  List<int> output;

  BinarySerializable() {
    output = [];
  }

  void addNonFloatingNumber(int number, int length) {
    for (int i = 0; i < length; i++) {
      output.add(number % 256);
      number ~/= 256;
    }
    assert(number == 0);
  }

  void addByte(int byte) {
    addNonFloatingNumber(byte, 1);
  }

  void addInteger(int integer) {
    addNonFloatingNumber(integer, 2);
  }

  void addLong(int long) {
    addNonFloatingNumber(long, 4);
  }

  List<int> binarySerialize() {
    addInteger(crcData(output));
    return output;
  }

  int setTimeStamp(int unixMilliseconds) {
    timeStamp = unixMilliseconds ~/ 1000 - fitEpoch;
    return timeStamp;
  }

  int setDateTime(DateTime dateTime) {
    return setTimeStamp(dateTime.millisecondsSinceEpoch);
  }
}
