import 'binary_serializable.dart';

class FitRecord extends BinarySerializable {
  static const int LITTLE_ENDIAN = 0;
  static const int BIG_ENDIAN = 1;

  static const int MESSAGE_TYPE_DATA = 0;
  static const int MESSAGE_TYPE_DEFINITION = 1;

  int header;
  final int reserved = 0;
  final int architecture = LITTLE_ENDIAN;
  int localMessageType = 0; // 3 bits
  int globalMessageNumber; // 2 bytes

  FitRecord({this.localMessageType, this.globalMessageNumber}) : super() {
    header = localMessageType;
  }

  List<int> binarySerialize() {
    addByte(header);
    return output;
  }
}
