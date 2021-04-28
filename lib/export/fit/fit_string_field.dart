import 'fit_base_type.dart';
import 'fit_field.dart';

class FitStringField extends FitField {
  FitStringField(definitionNumber, int length) : super(definitionNumber, FitBaseTypes.stringType) {
    size = length + 1;
  }

  List<int> binarySerialize() {
    return [definitionNumber, size, baseType];
  }
}
