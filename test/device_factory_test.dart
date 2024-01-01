import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

void main() {
  group('getDescriptorForFourCC covers all possibilities', () {
    for (final fourCC in allFourCC) {
      final fourCCIndicator = <String>{};
      test(fourCC, () async {
        final descriptor = DeviceFactory.getDescriptorForFourCC(fourCC);
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
        expect(descriptor.fourCC,
            !isGeneric || sport == ActivityType.ride ? genericFTMSBikeFourCC : expectation[sport]);
      });
    }
  });
}
