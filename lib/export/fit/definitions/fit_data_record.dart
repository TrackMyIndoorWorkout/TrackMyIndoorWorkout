import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';

class FitDataRecord extends FitDefinitionMessage {
  FitDataRecord({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.Record,
        ) {
    fields = [
      FitField(253, FitBaseTypes.uint32Type), // Timestamp
      FitField(0, FitBaseTypes.sint32Type), // PositionLat
      FitField(1, FitBaseTypes.sint32Type), // PositionLong
      FitField(3, FitBaseTypes.uint8Type), // HeartRate (bpm)
      FitField(4, FitBaseTypes.uint8Type), // Cadence (rpm or spm?)
      FitField(5, FitBaseTypes.uint32Type), // Distance (1/00 m)
      FitField(6, FitBaseTypes.uint16Type), // Speed (1/1000 m/s)
      FitField(7, FitBaseTypes.uint16Type), // Power (Watts)
      FitField(33, FitBaseTypes.uint16Type), // Calories
    ];
  }
}
