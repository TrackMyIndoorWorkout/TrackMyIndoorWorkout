import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';

class FitActivity extends FitDefinitionMessage {
  FitActivity({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.Activity,
        ) {
    fields = [
      FitField(253, FitBaseTypes.uint32Type), // Timestamp
      // FitField(0, FitBaseTypes.uint32Type), // TotalTimerTime (exclude pauses) 1/1000 s
      FitField(1, FitBaseTypes.uint16Type), // NumSessions: 1
      FitField(2, FitBaseTypes.enumType), // Timestamp or Activity?: 0
      FitField(3, FitBaseTypes.enumType), // Event: 1A
      FitField(4, FitBaseTypes.enumType), // EventType: 1
      // FitField(5, FitBaseTypes.uint32Type), // LocalTimestamp
    ];
  }
}
