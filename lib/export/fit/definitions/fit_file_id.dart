import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';

class FitFileId extends FitDefinitionMessage {
  FitFileId({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.FileId,
        ) {
    fields = [
      FitField(0, FitBaseTypes.enumType), // type
      FitField(1, FitBaseTypes.uint16Type), // manufacturer
      FitField(2, FitBaseTypes.uint16Type), // product
      FitField(3, FitBaseTypes.uint32zType), // serial number
      FitField(4, FitBaseTypes.uint32Type), // time created
      FitField(8, FitBaseTypes.stringType), // product name
    ];
  }

  List<int> serializeData(dynamic parameter) {
    // TODO
    return null;
  }
}
