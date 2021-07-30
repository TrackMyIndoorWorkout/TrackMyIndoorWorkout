import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_base_type.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_manufacturer.dart';

class TestData {
  final String text;
  final int id;

  TestData({required this.text, required this.id});
}

void main() {
  group('getFitManufacturer test', () {
    deviceMap.forEach((fourCC, deviceDescriptor) {
      test(
          "$fourCC (${deviceDescriptor.manufacturerPrefix}) -> ${deviceDescriptor.manufacturerFitId}",
          () async {
        final expected = deviceDescriptor.fourCC.startsWith("G")
            ? FitBaseTypes.uint16Type.invalidValue
            : deviceDescriptor.manufacturerFitId;
        expect(getFitManufacturer(deviceDescriptor.manufacturerPrefix), expected);
      });
    });
  });
}
