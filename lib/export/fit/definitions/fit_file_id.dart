import '../../export_model.dart';
import '../enums/fit_file_type.dart';
import '../fit_base_type.dart';
import '../fit_data.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';
import '../fit_serializable.dart';
import '../fit_string_field.dart';

class FitFileId extends FitDefinitionMessage {
  final int productTextLength;

  FitFileId(localMessageType, this.productTextLength) : super(localMessageType, FitMessage.fileId) {
    fields = [
      FitField(0, FitBaseTypes.enumType), // type (Activity)
      FitField(1, FitBaseTypes.uint16Type), // manufacturer
      // FitField(2, FitBaseTypes.uint16Type), // product
      FitField(4, FitBaseTypes.uint32Type), // time created
      FitStringField(8, productTextLength), // product name
    ];
  }

  @override
  List<int> serializeData(dynamic parameter) {
    ExportModel model = parameter;

    var data = FitData();
    data.output = [localMessageType];
    data.addByte(FitFileType.activity);
    data.addShort(model.descriptor.manufacturerFitId);
    // data.addShort(1);
    data.addLong(FitSerializable.fitDateTime(DateTime.now()));
    assert(productTextLength == model.descriptor.fullName.length);
    data.addString(model.descriptor.fullName);
    return data.output;
  }
}
