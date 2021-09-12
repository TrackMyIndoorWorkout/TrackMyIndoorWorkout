import 'fit_field.dart';
import 'fit_record.dart';

abstract class FitDefinitionMessage extends FitRecord {
  static const int fourtyRecord = 0x40;

  List<FitField> fields = [];

  FitDefinitionMessage(localMessageType, globalMessageNumber)
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: globalMessageNumber,
        ) {
    header += fourtyRecord;
  }

  @override
  List<int> binarySerialize() {
    super.binarySerialize();
    addByte(reserved);
    addByte(architecture);
    addShort(globalMessageNumber);
    addByte(fields.length);
    for (var field in fields) {
      output.addAll(field.binarySerialize());
    }

    return output;
  }

  List<int> serializeData(dynamic parameter);
}
