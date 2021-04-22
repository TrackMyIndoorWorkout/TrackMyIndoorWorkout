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
      FitField(2, FitBaseTypes.uint32Type), // MessageIndex
      FitField(3, FitBaseTypes.sint32Type), // StartPositionLat
      FitField(4, FitBaseTypes.sint32Type), // StartPositionLong
      FitField(5, FitBaseTypes.sint32Type), // EndPositionLat
      FitField(6, FitBaseTypes.sint32Type), // EndPositionLong

      FitField(4, FitBaseTypes.uint8Type), // Cadence
      FitField(5, FitBaseTypes.uint32Type), // Distance
      FitField(6, FitBaseTypes.uint16Type), // Speed
      FitField(7, FitBaseTypes.uint16Type), // Power
    ];
  }
}
