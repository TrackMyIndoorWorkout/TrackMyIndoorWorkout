import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/export_record.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_session.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_serializable.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'utils.dart';

void main() {
  test('FitSession has the expected global message number', () async {
    final session = FitSession(0);

    expect(session.globalMessageNumber, FitMessage.Session);
  });

  test('FitLap data has the expected length', () async {
    final rng = Random();
    final session = FitSession(0);
    final now = DateTime.now();
    final exportRecord = ExportRecord(
      timeStampInteger: FitSerializable.fitDateTime(now),
      latitude: rng.nextDouble(),
      longitude: rng.nextDouble(),
      record: Record(
        timeStamp: now.millisecondsSinceEpoch,
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

    final output = session.serializeData(exportModel);
    final expected = session.fields.fold<int>(0, (accu, field) => accu + field.size);

    expect(output.length, expected + 1);
  });
}
