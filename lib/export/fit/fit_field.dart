import 'fit_serializable.dart';

class FitField extends FitSerializable {
  int definitionNumber;
  int size;
  int baseType;

  List<int> binarySerialize() {
    return [definitionNumber, size, baseType];
  }
}
