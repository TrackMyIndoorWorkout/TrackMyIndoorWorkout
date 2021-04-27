import '../../export_model.dart';
import '../enums/fit_activity.dart';
import '../enums/fit_event.dart';
import '../enums/fit_event_type.dart';
import '../fit_base_type.dart';
import '../fit_data.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
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
      FitField(2, FitBaseTypes.enumType), // Activity (Manual)
      FitField(3, FitBaseTypes.enumType), // Event (Activity)
      FitField(4, FitBaseTypes.enumType), // EventType (Stop)
    ];
  }

  List<int> serializeData(dynamic parameter) {
    ExportModel model = parameter;

    var dummy = FitData();
    dummy.output = [localMessageType];
    dummy.addLong(FitSerializable.fitDateTime(model.dateActivity));
    dummy.addShort(1);
    dummy.addByte(FitActivityEnum.Manual);
    dummy.addByte(FitEvent.Activity);
    dummy.addByte(FitEventType.Stop);

    return dummy.output;
  }
}
