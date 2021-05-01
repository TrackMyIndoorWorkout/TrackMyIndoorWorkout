import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/export/export_model.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_file_id.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

void main() {
  test('FitFileId has the expected global message number', () async {
    final fileId = FitFileId(0, 0);

    expect(fileId.globalMessageNumber, FitMessage.FileId);
  });

  group('FitFileId data has the expected length', () {
    final rnd = Random();
    deviceMap.forEach((fourCC, deviceDescriptor) {
      final globalMessageNumber = rnd.nextInt(MAX_UINT16);
      final text = deviceDescriptor.fullName;
      final fileId = FitFileId(globalMessageNumber, text.length);
      final exportModel = ExportModel()
        ..dateActivity = DateTime.now()
        ..descriptor = deviceDescriptor;
      final expected = fileId.fields.fold(0, (accu, field) => accu + field.size);

      test('$text(${text.length}) -> $expected', () async {
        final output = fileId.serializeData(exportModel);

        expect(output.length, expected + 1);
      });
    });
  });
}