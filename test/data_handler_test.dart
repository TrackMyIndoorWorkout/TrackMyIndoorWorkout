import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

import 'utils.dart';

main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  group('preProcessFlag handles 1 byte flags as expected', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 255, rnd).forEach((flag) {
      test('$flag', () async {
        final descriptor = DeviceFactory.getCSCBasedBike();
        final data = [flag, rnd.nextInt(255)];

        descriptor.preProcessFlag(data);

        expect(descriptor.featuresFlag, flag);
      });
    });
  });

  group('preProcessFlag handles 2 byte flags as expected', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 255, rnd).forEach((flagLsb) {
      final flagMsb = rnd.nextInt(255);
      test('[$flagLsb, $flagMsb]', () async {
        final descriptor = DeviceFactory.getPowerMeterBasedBike();
        final data = [flagLsb, flagMsb, rnd.nextInt(255)];

        descriptor.preProcessFlag(data);

        expect(descriptor.featuresFlag, flagLsb + 256 * flagMsb);
      });
    });
  });

  group('keySelector handles 3 byte flags as expected', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 255, rnd).forEach((flagLsb) {
      final flagMid = rnd.nextInt(255);
      final flagMsb = rnd.nextInt(255);
      test('[$flagLsb, $flagMid, $flagMsb]', () async {
        final descriptor = DeviceFactory.getGenericFTMSCrossTrainer();
        final data = [flagLsb, flagMid, flagMsb, rnd.nextInt(255)];

        descriptor.preProcessFlag(data);

        expect(descriptor.featuresFlag, flagLsb + 256 * flagMid + 65536 * flagMsb);
      });
    });
  });
}
