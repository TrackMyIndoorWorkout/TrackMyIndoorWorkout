import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/export/export_model.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_device_info.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'fit_device_info_test.mocks.dart';

@GenerateMocks([ExportModel])
void main() {
  test('FitDeviceInfo has the expected global message number', () async {
    final deviceInfo = FitDeviceInfo(0, 0);

    expect(deviceInfo.globalMessageNumber, FitMessage.DeviceInfo);
  });

  group('FitDeviceInfo data has the expected length', () {
    final rnd = Random();
    deviceMap.forEach((fourCC, deviceDescriptor) {
      final globalMessageNumber = rnd.nextInt(MAX_UINT16);
      final text = deviceDescriptor.fullName;
      final deviceInfo = FitDeviceInfo(globalMessageNumber, text.length);
      final exportModel = MockExportModel()
        ..dateActivity = DateTime.now()
        ..descriptor = deviceDescriptor;
      final expected = deviceInfo.fields.fold<int>(0, (accu, field) => accu + field.size);

      test('$text(${text.length}) -> $expected', () async {
        final output = deviceInfo.serializeData(exportModel);

        expect(output.length, expected + 1);
      });
    });
  });
}
