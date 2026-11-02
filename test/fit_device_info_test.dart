import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/export/fit/definitions/fit_device_info.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_message.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

import 'utils.dart';

class MockBasePrefService extends Mock implements BasePrefService {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

void main() {
  final mockPrefService = MockBasePrefService();
  when(() => mockPrefService.get<int>(any())).thenReturn(0);
  Get.put<BasePrefService>(mockPrefService);

  tearDownAll(() {
    Get.reset();
  });
  test('FitDeviceInfo has the expected global message number', () async {
    final deviceInfo = FitDeviceInfo(0, 0);

    expect(deviceInfo.globalMessageNumber, FitMessage.deviceInfo);
  });

  group('FitDeviceInfo data has the expected length', () {
    final rnd = Random();
    DeviceFactory.allDescriptors().forEach((deviceDescriptor) {
      final globalMessageNumber = rnd.nextInt(maxUint16);
      final text = deviceDescriptor.fullName;
      final deviceInfo = FitDeviceInfo(globalMessageNumber, text.length);
      final exportModel = ExportModelForTests(descriptor: deviceDescriptor);
      final expected = deviceInfo.fields.fold<int>(0, (accu, field) => accu + field.size);

      test('$text(${text.length}) -> $expected', () async {
        final output = deviceInfo.serializeData(exportModel);

        expect(output.length, expected + 1);
      });
    });
  });
}
