import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_manufacturer.dart';

class MockBasePrefService extends Mock implements BasePrefService {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

void main() {
  final mockPrefService = MockBasePrefService();
  // Default int returns 0
  when(() => mockPrefService.get<int>(any())).thenReturn(0);
  Get.put<BasePrefService>(mockPrefService);

  tearDownAll(() {
    Get.reset();
  });

  group('getFitManufacturer test', () {
    DeviceFactory.allDescriptors().forEach((deviceDescriptor) {
      test(
        "${deviceDescriptor.fourCC} (${deviceDescriptor.manufacturerNamePart}) -> ${deviceDescriptor.manufacturerFitId}",
        () async {
          final manufacturerFitId = deviceDescriptor.fourCC != virtufitUltimatePro2FourCC
              ? getFitManufacturer(deviceDescriptor.manufacturerNamePart)
              : wahooFitnessFitId;
          expect(manufacturerFitId, deviceDescriptor.manufacturerFitId);
        },
      );
    });
  });
}
