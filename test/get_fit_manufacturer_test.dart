import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_manufacturer.dart';

class TestData {
  final String text;
  final int id;

  TestData({this.text, this.id});
}

void main() {
  group('getFitManufacturer test', () {
    deviceMap.forEach((fourCC, deviceDescriptor) {
      test("$fourCC (${deviceDescriptor.manufacturer}) -> ${deviceDescriptor.manufacturerFitId}",
          () async {
        expect(
            getFitManufacturer(deviceDescriptor.manufacturer), deviceDescriptor.manufacturerFitId);
      });
    });
  });
}
