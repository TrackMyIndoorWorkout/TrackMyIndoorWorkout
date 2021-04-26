import '../../export_model.dart';
import '../enums/fit_file_type.dart';
import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_header.dart';
import '../fit_manufacturer.dart';
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
      FitField(2, FitBaseTypes.uint16Type), // product
      FitField(3, FitBaseTypes.uint32zType), // serial number
      FitField(4, FitBaseTypes.uint32Type), // time created
      FitField(8, FitBaseTypes.stringType), // product name
    ];
  }

  List<int> serializeData(dynamic parameter) {
    ExportModel model = parameter;

    var dummy = FitHeader();
    dummy.output = [localMessageType, 0];
    dummy.addByte(FitFileType.Activity);
    dummy.addByte(getFitManufacturer(model.deviceName));
    // TODO: product
    dummy.addLong(1);
    dummy.setDateTime(DateTime.now());
    dummy.addString(model.deviceName);
    return dummy.output;
  }
}
