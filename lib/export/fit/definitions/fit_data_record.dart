import '../../../persistence/preferences.dart';
import '../../export_record.dart';
import '../fit_base_type.dart';
import '../fit_data.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';
import '../fit_serializable.dart';

class FitDataRecord extends FitDefinitionMessage {
  final String heartRateGapWorkaround;
  final int heartRateUpperLimit;
  final String heartRateLimitingMethod;

  FitDataRecord(
    localMessageType,
    this.heartRateGapWorkaround,
    this.heartRateUpperLimit,
    this.heartRateLimitingMethod,
  ) : super(localMessageType, FitMessage.Record) {
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

  @override
  List<int> serializeData(dynamic parameter) {
    ExportRecord model = parameter;

    var data = FitData();
    data.output = [localMessageType];
    final dateTime = model.record.timeStamp != null
        ? DateTime.fromMillisecondsSinceEpoch(model.record.timeStamp!)
        : DateTime.now();
    data.addLong(FitSerializable.fitDateTime(dateTime));
    data.addGpsCoordinate(model.latitude);
    data.addGpsCoordinate(model.longitude);

    if (model.record.heartRate != null) {
      if (model.record.heartRate == 0 &&
          (heartRateGapWorkaround == DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS ||
              heartRateLimitingMethod == HEART_RATE_LIMITING_WRITE_NOTHING)) {
        // #93 #113 #114
        model.record.heartRate = FitBaseTypes.uint8Type.invalidValue;
      }
    } else {
      model.record.heartRate = FitBaseTypes.uint8Type.invalidValue;
    }

    data.addByte(model.record.heartRate ?? FitBaseTypes.uint8Type.invalidValue);
    data.addByte(model.record.cadence ?? FitBaseTypes.uint8Type.invalidValue);
    data.addLong(((model.record.distance ?? 0.0) * 100).round());
    data.addShort(((model.record.speed ?? 0.0) * 1000).round());
    data.addShort(model.record.power?.round() ?? FitBaseTypes.uint16Type.invalidValue);

    return data.output;
  }
}
