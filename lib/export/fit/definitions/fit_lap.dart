import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';

class FitLap extends FitDefinitionMessage {
  FitLap({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.Lap,
        ) {
    fields = [
      FitField(253, FitBaseTypes.uint32Type), // Timestamp
      FitField(0, FitBaseTypes.enumType), // Event
      FitField(1, FitBaseTypes.enumType), // EventType

      FitField(0, FitBaseTypes.sint32Type), // PositionLat
      FitField(1, FitBaseTypes.sint32Type), // PositionLong
      FitField(4, FitBaseTypes.uint8Type), // Cadence
      FitField(5, FitBaseTypes.uint32Type), // Distance
      FitField(6, FitBaseTypes.uint16Type), // Speed
      FitField(7, FitBaseTypes.uint16Type), // Power
    ];
  }
}
