import '../../../utils/constants.dart';
import '../../export_record.dart';
import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_header.dart';
import '../fit_message.dart';
import '../fit_serializable.dart';

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
      FitField(5, FitBaseTypes.uint32Type), // Distance (1/100 m)
      FitField(6, FitBaseTypes.uint16Type), // Speed (1/1000 m/s)
      FitField(7, FitBaseTypes.uint16Type), // Power (Watts)
    ];
  }

  List<int> serializeData(dynamic parameter) {
    ExportRecord model = parameter;

    var dummy = FitHeader();
    dummy.output = [localMessageType];
    dummy.addLong(FitSerializable.fitDateTime(model.date));
    dummy.addLong((model.latitude * DEG_TO_FIT_GPS).round());
    dummy.addLong((model.longitude * DEG_TO_FIT_GPS).round());
    // TODO
    dummy.addByte(model.heartRate);
    // TODO
    dummy.addByte(model.cadence);
    dummy.addLong((model.distance * 100).round());
    dummy.addShort((model.speed * 1000).round());
    dummy.addShort(model.power.round());

    dummy.output.addAll([1, 0, 0x1A, 1]);

    return dummy.output;
  }
}
