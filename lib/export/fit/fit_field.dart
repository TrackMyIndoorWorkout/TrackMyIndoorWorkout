import 'fit_base_type.dart';
import 'fit_serializable.dart';

class FitField extends FitSerializable {
  final int definitionNumber;
  late int size;
  late int baseType;

  FitField(this.definitionNumber, FitBaseType fitBaseType) {
    size = fitBaseType.size;
    baseType = fitBaseType.id;
  }

  List<int> binarySerialize() {
    return [definitionNumber, size, baseType];
  }
}
