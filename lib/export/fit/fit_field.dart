import 'fit_base_type.dart';
import 'fit_serializable.dart';

class FitField extends FitSerializable {
  final int definitionNumber;
  int size;
  int baseType;

  FitField(this.definitionNumber, FitBaseType fitBaseType, int textLength) {
    if (textLength == null) {
      size = fitBaseType.size;
    } else {
      assert(fitBaseType.id == FitBaseTypes.stringType.id);
      size = textLength + 1;
    }
    baseType = fitBaseType.id;
  }

  List<int> binarySerialize() {
    return [definitionNumber, size, baseType];
  }
}
