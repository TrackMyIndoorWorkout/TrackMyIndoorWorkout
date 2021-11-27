import '../fit_base_type.dart';
import '../fit_data.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';

class FitFileCreator extends FitDefinitionMessage {
  FitFileCreator(localMessageType) : super(localMessageType, FitMessage.FileCreator) {
    fields = [
      FitField(0, FitBaseTypes.uint16Type), // SoftwareRevision
    ];
  }

  @override
  List<int> serializeData(dynamic parameter) {
    var data = FitData();
    data.output = [localMessageType];
    data.addShort(85);
    return data.output;
  }
}
