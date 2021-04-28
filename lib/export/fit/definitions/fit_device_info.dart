import '../../export_model.dart';
import '../enums/fit_device_type.dart';
import '../enums/fir_source_type.dart';
import '../fit_base_type.dart';
import '../fit_data.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';
import '../fit_string_field.dart';

class FitDeviceInfo extends FitDefinitionMessage {
  final int productTextLength;

  FitDeviceInfo(localMessageType, this.productTextLength)
      : super(localMessageType, FitMessage.DeviceInfo) {
    fields = [
      FitField(253, FitBaseTypes.uint32Type), // Timestamp
      FitField(1, FitBaseTypes.uint8Type), // DeviceType
      FitField(2, FitBaseTypes.uint16Type), // manufacturer
      // FitField(4, FitBaseTypes.uint16Type), // Product
      FitField(25, FitBaseTypes.enumType), // source_type
      FitStringField(27, productTextLength), // ProductName
    ];
  }

  List<int> serializeData(dynamic parameter) {
    ExportModel model = parameter;

    var data = FitData();
    data.output = [localMessageType, 0];
    data.setDateTime(DateTime.now());
    data.addByte(FitDeviceType.FitnessEquipment);
    data.addShort(model.descriptor.manufacturerFitId);
    // data.addShort(1);
    data.addByte(
        model.descriptor.antPlus ? FitSourceType.Antplus : FitSourceType.BluetoothLowEnergy);
    assert(productTextLength == model.descriptor.fullName.length);
    data.addString(model.descriptor.fullName);

    return data.output;
  }
}
