import 'fit_base_type.dart';
import 'fit_field.dart';
import 'fit_record.dart';

abstract class FitDefinitionMessage extends FitRecord {
  static const int FORTY_RECORD = 0x40;

  List<FitField> fields;

  FitDefinitionMessage({localMessageType, globalMessageNumber})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: globalMessageNumber,
        ) {
    header += FORTY_RECORD;
    fields = [];
  }

  List<int> binarySerialize() {
    super.binarySerialize();
    addByte(reserved);
    addByte(architecture);
    addShort(globalMessageNumber);
    addByte(fields.length);
    fields.forEach((field) {
      output.addAll(field.binarySerialize());
    });

    return output;
  }

  setStringFieldSize(int definitionNumber, int size) {
    int i = 0;
    int index = 0;
    fields.forEach((field) {
      if (field.definitionNumber == definitionNumber) {
        assert(field.baseType == FitBaseTypes.stringType.id);
        index = i;
      }

      i++;
    });

    fields[index].size = size;
  }

  List<int> serializeData(dynamic parameter);
}
