import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';

class FitSession extends FitDefinitionMessage {
  FitSession({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.Session,
        ) {
    fields = [
      FitField(254, FitBaseTypes.uint32Type), // MessageIndex
      FitField(253, FitBaseTypes.uint32Type), // Timestamp
      FitField(0, FitBaseTypes.enumType), // Event: 9
      FitField(1, FitBaseTypes.enumType), // EventType: 1
      FitField(2, FitBaseTypes.uint32Type), // MessageIndex: ???
      FitField(3, FitBaseTypes.sint32Type), // StartPositionLat
      FitField(4, FitBaseTypes.sint32Type), // StartPositionLong
      FitField(5, FitBaseTypes.sint32Type), // EndPositionLat
      FitField(6, FitBaseTypes.sint32Type), // EndPositionLong
      FitField(7, FitBaseTypes.uint32Type), // TotalElapsedTime (1/1000 s)
      FitField(9, FitBaseTypes.uint32Type), // TotalDistance (1/100 m)
      FitField(11, FitBaseTypes.uint16Type), // TotalCalories (1/100 m)
      FitField(13, FitBaseTypes.uint16Type), // AvgSpeed (1/1000 m/s)
      FitField(14, FitBaseTypes.uint16Type), // MaxSpeed (1/1000 m/s)
      FitField(15, FitBaseTypes.uint8Type), // AvgHeartRate (bpm)
      FitField(16, FitBaseTypes.uint8Type), // MaxHeartRate (bpm)
      FitField(17, FitBaseTypes.uint8Type), // AvgCadence (rpm or spm)
      FitField(18, FitBaseTypes.uint8Type), // MaxCadence (rpm or spm)
      FitField(19, FitBaseTypes.uint16Type), // AvgPower (Watts)
      FitField(20, FitBaseTypes.uint16Type), // MaxPower (Watts)
      FitField(25, FitBaseTypes.enumType), // Sport
      FitField(39, FitBaseTypes.enumType), // Sub-Sport
    ];
  }
}
