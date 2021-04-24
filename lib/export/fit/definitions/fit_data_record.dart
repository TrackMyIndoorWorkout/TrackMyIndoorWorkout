import '../../../persistence/preferences.dart';
import '../../../utils/constants.dart';
import '../../export_record.dart';
import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_header.dart';
import '../fit_message.dart';
import '../fit_serializable.dart';

class FitDataRecord extends FitDefinitionMessage {
  final String heartRateGapWorkaround;
  final int heartRateUpperLimit;
  final String heartRateLimitingMethod;

  FitDataRecord({
    localMessageType,
    this.heartRateGapWorkaround,
    this.heartRateUpperLimit,
    this.heartRateLimitingMethod,
  }) : super(
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
    if (model.heartRate != null) {
      if (heartRateUpperLimit > 0 &&
          model.heartRate > heartRateUpperLimit &&
          heartRateLimitingMethod != HEART_RATE_LIMITING_NO_LIMIT) {
        // #114
        if (heartRateLimitingMethod == HEART_RATE_LIMITING_CAP_AT_LIMIT) {
          model.heartRate = heartRateUpperLimit;
        } else {
          model.heartRate = heartRateLimitingMethod == HEART_RATE_LIMITING_WRITE_ZERO
              ? 0
              : FitBaseTypes.uint8Type.invalidValue;
        }
      } else if (model.heartRate == 0 &&
              heartRateGapWorkaround == DATA_GAP_WORKAROUND_DO_NOT_WRITE_ZEROS ||
          heartRateLimitingMethod == HEART_RATE_LIMITING_WRITE_NOTHING) {
        // #93 #113 #114
        model.heartRate = FitBaseTypes.uint8Type.invalidValue;
      }
    } else {
      model.heartRate = FitBaseTypes.uint8Type.invalidValue;
    }

    dummy.addByte(model.heartRate);
    dummy.addByte(model.cadence);
    dummy.addLong((model.distance * 100).round());
    dummy.addShort((model.speed * 1000).round());
    dummy.addShort(model.power.round());

    dummy.output.addAll([1, 0, 0x1A, 1]);

    return dummy.output;
  }
}
