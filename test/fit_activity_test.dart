import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/export_target.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_activity.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';
import 'package:tuple/tuple.dart';
import 'utils.dart';

void main() {
  group('FitActivity has the expected global message number', () {
    for (var exportTarget in [
      const Tuple2<int, String>(ExportTarget.regular, "regular"),
      const Tuple2<int, String>(ExportTarget.suunto, "SUUNTO"),
    ]) {
      test('for ${exportTarget.item2}', () async {
        final activity = FitActivity(0, exportTarget.item1);

        expect(activity.globalMessageNumber, FitMessage.Activity);
      });
    }
  });

  group('FitActivity data has the expected length', () {
    for (var exportTarget in [
      const Tuple2<int, String>(ExportTarget.regular, "regular"),
      const Tuple2<int, String>(ExportTarget.suunto, "SUUNTO"),
    ]) {
      test('for ${exportTarget.item2}', () async {
        final activity = FitActivity(0, exportTarget.item1);
        final exportModel = ExportModelForTests();
        exportModel.activity.hydrate();
        final output = activity.serializeData(exportModel);
        final expected = activity.fields.fold<int>(0, (accu, field) => accu + field.size);

        expect(output.length, expected + 1);
      });
    }
  });
}
