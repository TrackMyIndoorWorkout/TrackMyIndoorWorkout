import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';

class FitFileCreator extends FitDefinitionMessage {
  FitFileCreator({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.FileCreator,
        ) {
    fields = [
      FitField(1, FitBaseTypes.uint16Type), // SoftwareRevision
    ];
  }

  List<int> serializeData(dynamic parameter) {
    return [localMessageType, 33];
  }
}
