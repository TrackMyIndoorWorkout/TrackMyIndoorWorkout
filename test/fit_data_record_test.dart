import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/export_record.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_data_record.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';
import 'package:track_my_indoor_exercise/persistence/models/record.dart';
import 'package:track_my_indoor_exercise/preferences/heart_rate_gap_workaround.dart';
import 'package:track_my_indoor_exercise/preferences/heart_rate_limiting.dart';

void main() {
  test('FitDataRecord has the expected global message number', () async {
    final dataRecord = FitDataRecord(
      0,
      0,
      heartRateGapWorkaroundDefault,
      heartRateUpperLimitDefault,
      heartRateLimitingMethodDefault,
    );

    expect(dataRecord.globalMessageNumber, FitMessage.record);
  });

  test('FitDataRecord data has the expected length', () async {
    final rng = Random();
    final dataRecord = FitDataRecord(
      0,
      0,
      heartRateGapWorkaroundDefault,
      heartRateUpperLimitDefault,
      heartRateLimitingMethodDefault,
    );
    final now = DateTime.now();
    final exportRecord = ExportRecord(
      latitude: rng.nextDouble(),
      longitude: rng.nextDouble(),
      record: Record(
        timeStamp: now.millisecondsSinceEpoch,
        power: 0,
        speed: 0.0,
        cadence: 0,
        heartRate: 0,
      ),
    );

    final output = dataRecord.serializeData(exportRecord);
    final expected = dataRecord.fields.fold<int>(0, (accu, field) => accu + field.size);

    expect(output.length, expected + 1);
  });
}
