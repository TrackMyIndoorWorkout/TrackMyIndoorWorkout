import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/export_record.dart';
import 'package:track_my_indoor_exercise/export/export_target.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_session.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'package:tuple/tuple.dart';
import 'utils.dart';

void main() {
  group('FitSession has the expected global message number', () {
    for (var withGps in [true, false]) {
      for (var exportTarget in [
        const Tuple2<int, String>(ExportTarget.regular, "regular"),
        const Tuple2<int, String>(ExportTarget.suunto, "SUUNTO"),
      ]) {
        test('for ${exportTarget.item2}', () async {
          final session = FitSession(0, exportTarget.item1, withGps);

          expect(session.globalMessageNumber, FitMessage.session);
        });
      }
    }
  });

  group('FitSession data has the expected length', () {
    for (var withGps in [true, false]) {
      for (var exportTarget in [
        const Tuple2<int, String>(ExportTarget.regular, "regular"),
        const Tuple2<int, String>(ExportTarget.suunto, "SUUNTO"),
      ]) {
        test('for ${exportTarget.item2}', () async {
          final rng = Random();
          final session = FitSession(0, exportTarget.item1, withGps);
          final now = DateTime.now();
          final exportRecord = withGps
              ? ExportRecord(
                  latitude: rng.nextDouble(),
                  longitude: rng.nextDouble(),
                  record: Record(
                    timeStamp: now.millisecondsSinceEpoch,
                  ),
                )
              : ExportRecord(record: Record(timeStamp: now.millisecondsSinceEpoch));

          final exportModel = ExportModelForTests(records: [exportRecord])
            ..averageSpeed = 0.0
            ..maximumSpeed = 0.0
            ..averageHeartRate = 0
            ..maximumHeartRate = 0
            ..averageCadence = 0
            ..maximumCadence = 0
            ..averagePower = 0.0
            ..maximumPower = 0;

          final output = session.serializeData(exportModel);
          final expected = session.fields.fold<int>(0, (accu, field) => accu + field.size);

          expect(output.length, expected + 1);
        });
      }
    }
  });
}
