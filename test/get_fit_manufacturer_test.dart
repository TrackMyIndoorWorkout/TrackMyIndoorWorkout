import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_manufacturer.dart';

class TestData {
  final String text;
  final int id;

  TestData({required this.text, required this.id});
}

void main() {
  group('getFitManufacturer test', () {
    DeviceFactory.allDescriptors().forEach((deviceDescriptor) {
      test(
        "${deviceDescriptor.fourCC} (${deviceDescriptor.manufacturerNamePart}) -> ${deviceDescriptor.manufacturerFitId}",
        () async {
          final manufacturerFitId =
              deviceDescriptor.fourCC != virtufitUltimatePro2FourCC
                  ? getFitManufacturer(deviceDescriptor.manufacturerNamePart)
                  : wahooFitnessFitId;
          expect(manufacturerFitId, deviceDescriptor.manufacturerFitId);
        },
      );
    });
  });
}
