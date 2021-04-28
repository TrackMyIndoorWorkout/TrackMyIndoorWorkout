import '../../export_model.dart';
import '../enums/fit_file_type.dart';
import '../fit_base_type.dart';
import '../fit_data.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';

class FitFileId extends FitDefinitionMessage {
  FitFileId({localMessageType, textLength})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.FileId,
        ) {
    fields = [
      FitField(0, FitBaseTypes.enumType, null), // type (Activity)
      FitField(1, FitBaseTypes.uint16Type, null), // manufacturer
      // FitField(2, FitBaseTypes.uint16Type, null), // product
      FitField(4, FitBaseTypes.uint32Type, null), // time created
      FitField(8, FitBaseTypes.stringType, textLength), // product name
    ];
  }

  List<int> serializeData(dynamic parameter) {
    ExportModel model = parameter;

    var data = FitData();
    data.output = [localMessageType, 0];
    data.addByte(FitFileType.Activity);
    data.addShort(model.descriptor.manufacturerFitId);
    // data.addShort(1);
    data.setDateTime(DateTime.now());
    setStringFieldSize(8, model.descriptor.fullName.length + 1);
    data.addString(model.descriptor.fullName);
    return data.output;
  }
}
