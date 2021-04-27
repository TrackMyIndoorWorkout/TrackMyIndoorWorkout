import '../../export_model.dart';
import '../enums/fit_device_type.dart';
import '../enums/fir_source_type.dart';
import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_header.dart';
import '../fit_manufacturer.dart';
import '../fit_message.dart';

class FitDeviceInfo extends FitDefinitionMessage {
  FitDeviceInfo({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.DeviceInfo,
        ) {
    fields = [
      FitField(253, FitBaseTypes.uint32Type), // Timestamp
      FitField(1, FitBaseTypes.uint8Type), // DeviceType
      FitField(2, FitBaseTypes.uint16Type), // manufacturer
      // FitField(4, FitBaseTypes.uint16Type), // Product
      FitField(25, FitBaseTypes.enumType), // source_type
      FitField(27, FitBaseTypes.stringType), // ProductName
    ];
  }

  List<int> serializeData(dynamic parameter) {
    ExportModel model = parameter;

    var dummy = FitHeader();
    dummy.output = [localMessageType, 0];
    dummy.setDateTime(DateTime.now());
    dummy.addByte(FitDeviceType.FitnessEquipment);
    dummy.addShort(getFitManufacturer(model.deviceName));
    // dummy.addShort(1);
    dummy.addByte(FitSourceType.BluetoothLowEnergy);
    dummy.addString(model.deviceName);

    return dummy.output;
  }
}
