import '../../../utils/constants.dart';
import '../../export_model.dart';
import '../enums/fit_event.dart';
import '../enums/fit_event_type.dart';
import '../enums/fit_lap_trigger.dart';
import '../fit_base_type.dart';
import '../fit_data.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';
import '../fit_serializable.dart';
import '../fit_sport.dart';

class FitLap extends FitDefinitionMessage {
  FitLap({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.Lap,
        ) {
    fields = [
      FitField(254, FitBaseTypes.uint32Type, null), // MessageIndex
      FitField(253, FitBaseTypes.uint32Type, null), // Timestamp (Lap end time)
      FitField(0, FitBaseTypes.enumType, null), // Event
      FitField(1, FitBaseTypes.enumType, null), // EventType
      FitField(2, FitBaseTypes.uint32Type, null), // StartTime
      FitField(3, FitBaseTypes.sint32Type, null), // StartPositionLat
      FitField(4, FitBaseTypes.sint32Type, null), // StartPositionLong
      FitField(5, FitBaseTypes.sint32Type, null), // EndPositionLat
      FitField(6, FitBaseTypes.sint32Type, null), // EndPositionLong
      FitField(7, FitBaseTypes.uint32Type, null), // TotalElapsedTime (1/1000s)
      FitField(9, FitBaseTypes.uint32Type, null), // TotalDistance (1/100 m)
      FitField(11, FitBaseTypes.uint16Type, null), // TotalCalories (kcal)
      FitField(13, FitBaseTypes.uint16Type, null), // AvgSpeed (1/1000 m/s)
      FitField(14, FitBaseTypes.uint16Type, null), // MaxSpeed (1/1000 m/s)
      FitField(15, FitBaseTypes.uint8Type, null), // AvgHeartRate (bpm)
      FitField(16, FitBaseTypes.uint8Type, null), // MaxHeartRate (bpm)
      FitField(17, FitBaseTypes.uint8Type, null), // AvgCadence (rpm or spm)
      FitField(18, FitBaseTypes.uint8Type, null), // MaxCadence (rpm or spm)
      FitField(19, FitBaseTypes.uint16Type, null), // AvgPower (Watts)
      FitField(20, FitBaseTypes.uint16Type, null), // MaxPower (Watts)
      FitField(24, FitBaseTypes.enumType, null), // LapTrigger
      FitField(25, FitBaseTypes.enumType, null), // Sport
      FitField(39, FitBaseTypes.enumType, null), // Sub-Sport
    ];
  }

  List<int> serializeData(dynamic parameter) {
    ExportModel model = parameter;

    final first = model.records.first;
    final last = model.records.last;
    var data = FitData();
    data.output = [localMessageType, 0];
    data.addLong(FitSerializable.fitTimeStamp(last.timeStampInteger));
    data.addByte(FitEvent.Lap);
    data.addByte(FitEventType.Stop);
    data.addLong(FitSerializable.fitTimeStamp(first.timeStampInteger));
    data.addLong((first.latitude * DEG_TO_FIT_GPS).round());
    data.addLong((first.longitude * DEG_TO_FIT_GPS).round());
    data.addLong((last.latitude * DEG_TO_FIT_GPS).round());
    data.addLong((last.longitude * DEG_TO_FIT_GPS).round());
    data.addLong((model.totalTime * 1000).ceil());
    data.addLong((model.totalDistance * 100).ceil());
    data.addShort((model.calories * 100).ceil());
    data.addShort((model.averageSpeed * 1000).round());
    data.addShort((model.maximumSpeed * 1000).round());
    data.addByte(model.averageHeartRate);
    data.addByte(model.maximumHeartRate);
    data.addByte(model.averageCadence);
    data.addByte(model.maximumCadence);
    data.addShort(model.averagePower.round());
    data.addShort(model.maximumPower.round());
    data.addByte(FitLapTrigger.SessionEnd);
    final fitSport = activityType2FitSport(model.activityType);
    data.addByte(fitSport.item1);
    data.addByte(fitSport.item2);

    return data.output;
  }
}
