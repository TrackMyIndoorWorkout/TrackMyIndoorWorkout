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
    addInteger(globalMessageNumber);
    addByte(fields.length);
    fields.forEach((field) {
      output.addAll(field.binarySerialize());
    });

    return output;
  }

  // List<int> serializeData(dynamic parameter);
}
