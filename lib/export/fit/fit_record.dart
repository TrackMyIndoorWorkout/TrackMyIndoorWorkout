import 'fit_serializable.dart';

abstract class FitRecord extends FitSerializable {
  static const int littleEndian = 0;
  static const int bigEndian = 1;

  late int header;
  final int reserved = 0;
  int architecture = littleEndian;
  int localMessageType = 0; // 3 bits
  final int globalMessageNumber; // 2 bytes

  FitRecord({required this.localMessageType, required this.globalMessageNumber}) {
    header = localMessageType;
  }

  @override
  List<int> binarySerialize() {
    addByte(header);
    return output;
  }
}
