import '../fit_base_type.dart';
import '../fit_definition_message.dart';
import '../fit_field.dart';
import '../fit_message.dart';

class FitActivity extends FitDefinitionMessage {
  FitActivity({localMessageType})
      : super(
          localMessageType: localMessageType,
          globalMessageNumber: FitMessage.Activity,
        ) {
    fields = [
      FitField(0, FitBaseTypes.enumType), // Sport
      FitField(1, FitBaseTypes.enumType), // Sub-Sport
    ];
  }
}
