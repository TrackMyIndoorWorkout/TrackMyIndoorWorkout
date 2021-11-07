import '../../export_model.dart';
import '../enums/fit_device_type.dart';
import '../enums/fit_source_type.dart';
import '../fit_base_type.dart';
import '../fit_data.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';
import '../fit_serializable.dart';
import '../fit_string_field.dart';

class FitDeviceInfo extends FitDefinitionMessage {
  final int productTextLength;

  FitDeviceInfo(localMessageType, this.productTextLength)
      : super(localMessageType, FitMessage.DeviceInfo) {
    fields = [
      FitField(253, FitBaseTypes.uint32Type), // Timestamp
      FitField(1, FitBaseTypes.uint8Type), // DeviceType
      FitField(2, FitBaseTypes.uint16Type), // manufacturer
      FitField(25, FitBaseTypes.enumType), // source_type
      FitStringField(27, productTextLength), // ProductName
    ];
  }

  @override
  List<int> serializeData(dynamic parameter) {
    ExportModel model = parameter;

    var data = FitData();
    data.output = [localMessageType];
    data.addLong(FitSerializable.fitDateTime(DateTime.now()));
    data.addByte(FitDeviceType.FitnessEquipment);
    data.addShort(model.descriptor.manufacturerFitId);
    data.addByte(
        model.descriptor.antPlus ? FitSourceType.Antplus : FitSourceType.BluetoothLowEnergy);
    assert(productTextLength == model.descriptor.fullName.length);
    data.addString(model.descriptor.fullName);

    return data.output;
  }
}
