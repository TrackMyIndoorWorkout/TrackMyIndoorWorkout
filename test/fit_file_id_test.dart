import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_file_id.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'utils.dart';

void main() {
  test('FitFileId has the expected global message number', () async {
    final fileId = FitFileId(0, 0);

    expect(fileId.globalMessageNumber, FitMessage.fileId);
  });

  group('FitFileId data has the expected length', () {
    final rnd = Random();
    DeviceFactory.allDescriptors().forEach((deviceDescriptor) {
      final globalMessageNumber = rnd.nextInt(maxUint16);
      final text = deviceDescriptor.fullName;
      final fileId = FitFileId(globalMessageNumber, text.length);
      final exportModel = ExportModelForTests(descriptor: deviceDescriptor);
      final expected = fileId.fields.fold<int>(0, (accu, field) => accu + field.size);

      test('$text(${text.length}) -> $expected', () async {
        final output = fileId.serializeData(exportModel);

        expect(output.length, expected + 1);
      });
    });
  });
}
