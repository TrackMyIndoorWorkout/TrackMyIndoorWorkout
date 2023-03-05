import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/export_record.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_lap.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';
import 'package:track_my_indoor_exercise/persistence/isar/record.dart';
import 'utils.dart';

void main() {
  group('FitLap has the expected global message number', () {
    for (var withGps in [true, false]) {
      test('With GPS $withGps', () async {
        final lap = FitLap(0, withGps);

        expect(lap.globalMessageNumber, FitMessage.lap);
      });
    }
  });

  group('FitLap data has the expected length', () {
    for (var withGps in [true, false]) {
      test('FitLap data has the expected length', () async {
        final rng = Random();
        final lap = FitLap(0, withGps);
        final exportRecord = ExportRecord(
          latitude: rng.nextDouble(),
          longitude: rng.nextDouble(),
          record: Record(
            timeStamp: DateTime.now(),
          ),
        );

        final exportModel = ExportModelForTests(records: [exportRecord])
          ..averageSpeed = 0.0
          ..maximumSpeed = 0.0
          ..averageHeartRate = 0
          ..maximumHeartRate = 0
          ..averageCadence = 0
          ..maximumCadence = 0
          ..averagePower = 0.0
          ..maximumPower = 0;

        final output = lap.serializeData(exportModel);
        final expected = lap.fields.fold<int>(0, (accu, field) => accu + field.size);

        expect(output.length, expected + 1);
      });
    }
  });
}
