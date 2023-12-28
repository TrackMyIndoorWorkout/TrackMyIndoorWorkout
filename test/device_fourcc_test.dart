import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';

void main() {
  test('deviceNamePrefixes covers all descriptors 1', () async {
    // MPowerImport doesn't have any prefix
    expect(allFourCC.length - 1, deviceNamePrefixes.length);
  });

  group('deviceNamePrefixes binds as expected', () {
    for (final fourCC in allFourCC) {
      test(fourCC, () async {
        final hasPrefixes = fourCC != kayakFirstFourCC;
        final hasPostfixes =
            [concept2RowerFourCC, concept2SkiFourCC, concept2BikeFourCC].contains(fourCC);
        final deviceIdentifierHelperEntry = deviceNamePrefixes[fourCC];
        if (fourCC != mPowerImportDeviceId) {
          expect(deviceIdentifierHelperEntry, isNotNull);
          expect(deviceIdentifierHelperEntry!.deviceNamePrefixes.length,
              deviceIdentifierHelperEntry.deviceNameLoweredPrefixes.length);
          expect(deviceIdentifierHelperEntry.deviceNamePostfix.length,
              deviceIdentifierHelperEntry.deviceNameLoweredPostfix.length);
          expect(deviceIdentifierHelperEntry.manufacturerNamePrefix.length,
              deviceIdentifierHelperEntry.manufacturerNameLoweredPrefix.length);
          expect(deviceIdentifierHelperEntry.deviceNamePrefixes.isNotEmpty, hasPrefixes);
          expect(deviceIdentifierHelperEntry.deviceNamePostfix.isNotEmpty, hasPostfixes);
        } else {
          expect(deviceIdentifierHelperEntry, isNull);
        }
      });
    }
  });

  test('deviceSportDescriptors covers all descriptors 1', () async {
    // MPowerImport doesn't have any prefix
    expect(allFourCC.length - 1, deviceSportDescriptors.length);
  });

  group('deviceSportDescriptors binds as expected', () {
    for (final fourCC in allFourCC) {
      test(fourCC, () async {
        final isMultiSport = multiSportFourCCs.contains(fourCC) && fourCC != genericFTMSRowerFourCC;
        final sportDescriptor = deviceSportDescriptors[fourCC];
        if (fourCC != mPowerImportDeviceId) {
          expect(sportDescriptor, isNotNull);
          expect(sportDescriptor!.isMultiSport, isMultiSport);
        } else {
          expect(sportDescriptor, isNull);
        }
      });
    }
  });
}
