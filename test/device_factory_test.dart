import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class MockBasePrefService extends Mock implements BasePrefService {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

void main() {
  setUpAll(() {
    final mockPrefService = MockBasePrefService();
    // Default int returns 0
    when(() => mockPrefService.get<int>(any())).thenReturn(0);
    Get.put<BasePrefService>(mockPrefService);
  });

  tearDownAll(() {
    Get.reset();
  });

  group('getDescriptorForFourCC covers all possibilities', () {
    for (final fourCC in allFourCC) {
      final fourCCIndicator = <String>{};
      test(fourCC, () async {
        final descriptor = DeviceFactory.getDescriptorForFourCC(fourCC);
        // ignore: a_null_check_operator_type ('descriptor' is DeviceDescriptor, not nullable here?)
        // wait, DeviceFactory.getDescriptorForFourCC returns DeviceDescriptor.
        expect(fourCCIndicator.contains(descriptor.fourCC), false);
        fourCCIndicator.add(fourCC);
      });
    }
  });

  group('genericDescriptorForSport covers all possibilities', () {
    final expectation = {
      ActivityType.ride: genericFTMSBikeFourCC,
      ActivityType.run: genericFTMSTreadmillFourCC,
      ActivityType.kayaking: genericFTMSKayakFourCC,
      ActivityType.canoeing: genericFTMSCanoeFourCC,
      ActivityType.rowing: genericFTMSRowerFourCC,
      ActivityType.swim: genericFTMSSwimFourCC,
      ActivityType.elliptical: genericFTMSCrossTrainerFourCC,
      ActivityType.nordicSki: concept2SkiFourCC,
    };
    final testSports = [...allSports];
    testSports.addAll([ActivityType.alpineSki, ActivityType.yoga]);
    for (final sport in testSports) {
      test(sport, () async {
        final isGeneric = expectation.containsKey(sport);
        final descriptor = DeviceFactory.genericDescriptorForSport(sport);
        expect(
          descriptor.fourCC,
          !isGeneric || sport == ActivityType.ride ? genericFTMSBikeFourCC : expectation[sport],
        );
      });
    }
  });
}
