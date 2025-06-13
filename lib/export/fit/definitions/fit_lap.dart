import 'dart:math';

import '../../../utils/constants.dart';
import '../../export_model.dart';
import '../../export_target.dart';
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
import '../fit_utils.dart';

class FitLap extends FitDefinitionMessage {
  final double altitude;
  final int exportTarget;

  FitLap(int localMessageType, this.altitude, this.exportTarget)
    : super(localMessageType, FitMessage.lap) {
    fields = [
      FitField(253, FitBaseTypes.uint32Type), // Timestamp (Lap end time)
      FitField(0, FitBaseTypes.enumType), // Event
      FitField(1, FitBaseTypes.enumType), // EventType
      FitField(2, FitBaseTypes.uint32Type), // StartTime
      FitField(7, FitBaseTypes.uint32Type), // TotalElapsedTime (1/1000s)
      FitField(8, FitBaseTypes.uint32Type), // TotalTimerTime (1/1000s)
      FitField(9, FitBaseTypes.uint32Type), // TotalDistance (1/100 m)
    ];

    if (exportTarget == ExportTarget.regular) {
      fields.add(
        FitField(10, FitBaseTypes.uint32Type), // Total Cycles / Total Strides (run / walk)
      );
    }

    fields.addAll([
      FitField(11, FitBaseTypes.uint16Type), // TotalCalories (kcal)
      FitField(13, FitBaseTypes.uint16Type), // AvgSpeed (1/1000 m/s)
      FitField(14, FitBaseTypes.uint16Type), // MaxSpeed (1/1000 m/s)
      FitField(15, FitBaseTypes.uint8Type), // AvgHeartRate (bpm)
      FitField(16, FitBaseTypes.uint8Type), // MaxHeartRate (bpm)
      FitField(17, FitBaseTypes.uint8Type), // AvgCadence (rpm or spm)
      FitField(18, FitBaseTypes.uint8Type), // MaxCadence (rpm or spm)
      FitField(19, FitBaseTypes.uint16Type), // AvgPower (Watts)
      FitField(20, FitBaseTypes.uint16Type), // MaxPower (Watts)
      FitField(24, FitBaseTypes.enumType), // LapTrigger
      FitField(25, FitBaseTypes.enumType), // Sport
    ]);

    if (exportTarget == ExportTarget.regular) {
      fields.add(
        FitField(39, FitBaseTypes.enumType), // Sub-Sport
      );
    }

    fields.addAll([
      FitField(42, FitBaseTypes.uint16Type), // Avg Altitude (1/5 m with 500 offset)
      FitField(43, FitBaseTypes.uint16Type), // Max Altitude (1/5 m with 500 offset)
      FitField(62, FitBaseTypes.uint16Type), // Min Altitude (1/5 m with 500 offset)
    ]);
  }

  @override
  List<int> serializeData(dynamic parameter) {
    ExportModel model = parameter;

    final first = model.records.first;
    final last = model.records.last;
    var data = FitData();
    data.output = [localMessageType];
    data.addLong(FitSerializable.fitTimeStamp(last.record.timeStamp));
    data.addByte(FitEventEnum.lap);
    data.addByte(FitEventType.stop);
    data.addLong(FitSerializable.fitTimeStamp(first.record.timeStamp));
    data.addLong(model.activity.elapsed * 1000);
    data.addLong(model.activity.movingTime);
    data.addLong((model.activity.distance * 100).ceil());

    if (exportTarget == ExportTarget.regular) {
      data.addLong(model.activity.strides);
    }

    data.addShort(max(model.activity.calories, 0));
    data.addShort(model.averageSpeed > eps ? (model.averageSpeed * 1000).round() : 0);
    data.addShort(model.maximumSpeed > eps ? (model.maximumSpeed * 1000).round() : 0);
    data.addByte(max(model.averageHeartRate, 0));
    data.addByte(max(model.maximumHeartRate, 0));
    data.addByte(max(model.averageCadence, 0));
    data.addByte(max(model.maximumCadence, 0));
    data.addShort(model.averagePower > eps ? model.averagePower.round() : 0);
    data.addShort(model.maximumPower > eps ? model.maximumPower.round() : 0);
    data.addByte(FitLapTrigger.sessionEnd);
    final fitSport = toFitSport(model.activity.sport);
    data.addByte(fitSport.item1);

    if (exportTarget == ExportTarget.regular) {
      data.addByte(fitSport.item2);
    }

    data.addShort(convertAltitudeForFit(altitude));
    data.addShort(convertAltitudeForFit(altitude));
    data.addShort(convertAltitudeForFit(altitude));

    return data.output;
  }
}
