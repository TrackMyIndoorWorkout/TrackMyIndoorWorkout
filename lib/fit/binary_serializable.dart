import 'fit_crc.dart';

abstract class BinarySerializable {
  List<int> output;

  BinarySerializable() {
    output = [];
  }

  void addNonFloatingNumber(int number, int length) {
    for (int i = 0; i < length; i++) {
      output.add(number % 256);
      number ~/= 256;
    }
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
}
