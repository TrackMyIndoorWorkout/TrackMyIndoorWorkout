import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
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
      FitField(2, FitBaseTypes.uint16Type), // Timestamp
      FitField(3, FitBaseTypes.uint32zType), // SerialNumber
      FitField(4, FitBaseTypes.uint16Type), // Product
      FitField(5, FitBaseTypes.uint16Type), // SoftwareRevision
      FitField(6, FitBaseTypes.uint8Type), // HardwareRevision
      FitField(27, FitBaseTypes.stringType), // ProductName
    ];
  }

  List<int> serializeData(dynamic parameter) {
    // TODO
    return null;
  }
}
