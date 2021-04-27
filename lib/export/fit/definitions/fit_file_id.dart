import '../../export_model.dart';
import '../enums/fit_file_type.dart';
import '../fit_base_type.dart';
import '../fit_data.dart';
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
      FitField(0, FitBaseTypes.enumType), // type (Activity)
      FitField(1, FitBaseTypes.uint16Type), // manufacturer
      // FitField(2, FitBaseTypes.uint16Type), // product
      FitField(4, FitBaseTypes.uint32Type), // time created
      FitField(8, FitBaseTypes.stringType), // product name
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
    data.addString(model.descriptor.fullName);
    return data.output;
  }
}
