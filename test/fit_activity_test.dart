import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:track_my_indoor_exercise/export/export_model.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_activity.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';
import 'fit_activity_test.mocks.dart';

@GenerateMocks([ExportModel])
void main() {
  test('FitActivity has the expected global message number', () async {
    final activity = FitActivity(0);

    expect(activity.globalMessageNumber, FitMessage.Activity);
  });

  test('FitActivity data has the expected length', () async {
    final activity = FitActivity(0);
    final exportModel = MockExportModel()..dateActivity = DateTime.now();
    final output = activity.serializeData(exportModel);
    final expected = activity.fields.fold<int>(0, (accu, field) => accu + field.size);

    expect(output.length, expected + 1);
  });
}
