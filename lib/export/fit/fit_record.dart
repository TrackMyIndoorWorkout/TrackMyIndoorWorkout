import 'fit_serializable.dart';

abstract class FitRecord extends FitSerializable {
  static const int LITTLE_ENDIAN = 0;
  static const int BIG_ENDIAN = 1;

  int header;
  final int reserved = 0;
  final int architecture = LITTLE_ENDIAN;
  int localMessageType = 0; // 3 bits
  final int globalMessageNumber; // 2 bytes

  FitRecord({this.localMessageType, this.globalMessageNumber}) : super() {
    header = localMessageType;
  }

  List<int> binarySerialize() {
    addByte(header);
    return output;
  }
}
