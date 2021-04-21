import 'binary_serializable.dart';

class FitField extends BinarySerializable {
  int definitionNumber;
  int size;
  int baseType;

  List<int> binarySerialize() {
    return [definitionNumber, size, baseType];
  }
}
