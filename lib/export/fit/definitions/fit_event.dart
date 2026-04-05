import 'package:tuple/tuple.dart';

import '../../export_record.dart';
import '../enums/fit_activity.dart';
import '../enums/fit_event.dart';
import '../enums/fit_event_type.dart';
import '../fit_base_type.dart';
import '../fit_data.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';
import '../fit_serializable.dart';

class FitEvent extends FitDefinitionMessage {
  FitEvent(int localMessageType) : super(localMessageType, FitMessage.event) {
    fields = [
      FitField(253, FitBaseTypes.uint32Type), // Timestamp (Lap end time)
      FitField(0, FitBaseTypes.enumType), // Event
      FitField(1, FitBaseTypes.enumType), // EventType
      FitField(3, FitBaseTypes.uint32Type), // Data
    ];
  }

  @override
  List<int> serializeData(dynamic parameter) {
    Tuple2<bool, ExportRecord> tuple = parameter;

    var data = FitData();
    data.output = [localMessageType];
    data.addLong(FitSerializable.fitTimeStamp(tuple.item2.record.timeStamp));
    data.addByte(FitEventEnum.timer);
    data.addByte(tuple.item1 ? FitEventType.start : FitEventType.stop);
    data.addLong(FitActivityEnum.manual);

    return data.output;
  }
}
