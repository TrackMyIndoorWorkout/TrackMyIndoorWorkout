import '../../../utils/constants.dart';
import '../../export_model.dart';
import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_header.dart';
import '../fit_message.dart';
import '../fit_serializable.dart';
import '../fit_sport.dart';

class FitSession extends FitDefinitionMessage {
  FitSession({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.Session,
        ) {
    fields = [
      FitField(254, FitBaseTypes.uint32Type), // MessageIndex: 0
      FitField(253, FitBaseTypes.uint32Type), // Timestamp (Session end time)
      FitField(0, FitBaseTypes.enumType), // Event: 9
      FitField(1, FitBaseTypes.enumType), // EventType: 1
      FitField(2, FitBaseTypes.uint32Type), // StartTime
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

  List<int> serializeData(dynamic parameter) {
    ExportModel model = parameter;
    final first = model.points.first;
    final last = model.points.last;
    var dummy = FitHeader();
    dummy.output = [localMessageType, 0];
    dummy.addLong(FitSerializable.fitTimeStamp(last.timeStampInteger));
    dummy.addByte(9);
    dummy.addByte(1);
    dummy.addLong(FitSerializable.fitTimeStamp(first.timeStampInteger));
    dummy.addLong((first.latitude * DEG_TO_FIT_GPS).round());
    dummy.addLong((first.longitude * DEG_TO_FIT_GPS).round());
    dummy.addLong((last.latitude * DEG_TO_FIT_GPS).round());
    dummy.addLong((last.longitude * DEG_TO_FIT_GPS).round());
    dummy.addLong((model.totalTime * 1000).ceil());
    dummy.addLong((model.totalDistance * 100).ceil());
    dummy.addShort((model.calories * 100).ceil());
    dummy.addShort((model.averageSpeed * 1000).round());
    dummy.addShort((model.maximumSpeed * 1000).round());
    dummy.addByte(model.averageHeartRate);
    dummy.addByte(model.maximumHeartRate);
    dummy.addByte(model.averageCadence);
    dummy.addByte(model.maximumCadence);
    dummy.addShort(model.averagePower.round());
    dummy.addShort(model.maximumPower.round());
    final fitSport = activityType2FitSport(model.activityType);
    dummy.addByte(fitSport.item1);
    dummy.addByte(fitSport.item2);

    return dummy.output;
  }
}
