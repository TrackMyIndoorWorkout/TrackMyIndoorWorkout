import '../../export_model.dart';
import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_header.dart';
import '../fit_message.dart';
import '../fit_serializable.dart';

class FitActivity extends FitDefinitionMessage {
  FitActivity({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.Activity,
        ) {
    fields = [
      FitField(253, FitBaseTypes.uint32Type), // Timestamp
      FitField(1, FitBaseTypes.uint16Type), // NumSessions: 1
      FitField(2, FitBaseTypes.enumType), // Timestamp or Activity?: 0
      FitField(3, FitBaseTypes.enumType), // Event: 1A
      FitField(4, FitBaseTypes.enumType), // EventType: 1
    ];
  }

  List<int> serializeData(dynamic parameter) {
    ExportModel model = parameter;

    var dummy = FitHeader();
    dummy.output = [localMessageType];
    dummy.addLong(FitSerializable.fitDateTime(model.dateActivity));
    dummy.output.addAll([1, 0, 0x1A, 1]);

    return dummy.output;
  }
}
