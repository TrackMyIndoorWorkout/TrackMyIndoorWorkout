import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
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
          "$fourCC (${deviceDescriptor.manufacturerNamePart}) -> ${deviceDescriptor.manufacturerFitId}",
          () async {
        expect(getFitManufacturer(deviceDescriptor.manufacturerNamePart),
            deviceDescriptor.manufacturerFitId);
      });
    });
  });
}
