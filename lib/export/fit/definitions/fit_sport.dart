import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';
import '../fit_sport.dart';

class FitSport extends FitDefinitionMessage {
  FitSport({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.Sport,
        ) {
    fields = [
      FitField(0, FitBaseTypes.enumType), // Sport
      FitField(1, FitBaseTypes.enumType), // Sub-Sport
    ];
  }

  List<int> serializeData(dynamic parameter) {
    final fitSport = activityType2FitSport(parameter);
    return [localMessageType, fitSport.item1, fitSport.item2];
  }
}
