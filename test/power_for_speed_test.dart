// import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/preferences/air_temperature.dart';
import 'package:track_my_indoor_exercise/preferences/athlete_body_weight.dart';
import 'package:track_my_indoor_exercise/preferences/bike_weight.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'package:track_my_indoor_exercise/utils/power_speed_mixin.dart';

class TestData {
  final int aWeight;
  final int bWeight;
  final int temp;
  final double speed;
  final double watts;

  TestData({
    required this.aWeight,
    required this.bWeight,
    required this.temp,
    required this.speed,
    required this.watts,
  });
}

void main() {
  group("powerForVelocity calculates expected values:", () {
    for (final testData in [
      TestData(aWeight: 60, bWeight: 9, temp: 0, speed: 20.0, watts: 55.43031053162006),
      TestData(aWeight: 60, bWeight: 9, temp: 15, speed: 20.0, watts: 53.573178697404884),
      TestData(aWeight: 60, bWeight: 9, temp: 30, speed: 20.0, watts: 51.8450922776518),
      TestData(aWeight: 60, bWeight: 10, temp: 0, speed: 20.0, watts: 55.70827821869488),
      TestData(aWeight: 60, bWeight: 10, temp: 15, speed: 20.0, watts: 53.85114638447971),
      TestData(aWeight: 60, bWeight: 10, temp: 30, speed: 20.0, watts: 52.123059964726636),
      TestData(aWeight: 60, bWeight: 11, temp: 0, speed: 20.0, watts: 55.98624590576971),
      TestData(aWeight: 60, bWeight: 11, temp: 15, speed: 20.0, watts: 54.12911407155455),
      TestData(aWeight: 60, bWeight: 11, temp: 30, speed: 20.0, watts: 52.40102765180146),
      TestData(aWeight: 70, bWeight: 9, temp: 0, speed: 20.0, watts: 58.209987402368355),
      TestData(aWeight: 70, bWeight: 9, temp: 15, speed: 20.0, watts: 56.35285556815318),
      TestData(aWeight: 70, bWeight: 9, temp: 30, speed: 20.0, watts: 54.6247691484001),
      TestData(aWeight: 70, bWeight: 10, temp: 0, speed: 20.0, watts: 58.48795508944318),
      TestData(aWeight: 70, bWeight: 10, temp: 15, speed: 20.0, watts: 56.63082325522801),
      TestData(aWeight: 70, bWeight: 10, temp: 30, speed: 20.0, watts: 54.90273683547493),
      TestData(aWeight: 70, bWeight: 11, temp: 0, speed: 20.0, watts: 58.76592277651801),
      TestData(aWeight: 70, bWeight: 11, temp: 15, speed: 20.0, watts: 56.90879094230284),
      TestData(aWeight: 70, bWeight: 11, temp: 30, speed: 20.0, watts: 55.18070452254976),
      TestData(aWeight: 80, bWeight: 9, temp: 0, speed: 20.0, watts: 60.98966427311666),
      TestData(aWeight: 80, bWeight: 9, temp: 15, speed: 20.0, watts: 59.13253243890148),
      TestData(aWeight: 80, bWeight: 9, temp: 30, speed: 20.0, watts: 57.40444601914841),
      TestData(aWeight: 80, bWeight: 10, temp: 0, speed: 20.0, watts: 61.26763196019148),
      TestData(aWeight: 80, bWeight: 10, temp: 15, speed: 20.0, watts: 59.410500125976306),
      TestData(aWeight: 80, bWeight: 10, temp: 30, speed: 20.0, watts: 57.68241370622323),
      TestData(aWeight: 80, bWeight: 11, temp: 0, speed: 20.0, watts: 61.54559964726631),
      TestData(aWeight: 80, bWeight: 11, temp: 15, speed: 20.0, watts: 59.68846781305114),
      TestData(aWeight: 80, bWeight: 11, temp: 30, speed: 20.0, watts: 57.96038139329806),
      TestData(aWeight: 60, bWeight: 9, temp: 0, speed: 30.0, watts: 151.11522852891162),
      TestData(aWeight: 60, bWeight: 9, temp: 15, speed: 30.0, watts: 144.8474085884354),
      TestData(aWeight: 60, bWeight: 9, temp: 30, speed: 30.0, watts: 139.01511692176874),
      TestData(aWeight: 60, bWeight: 10, temp: 0, speed: 30.0, watts: 151.53218005952385),
      TestData(aWeight: 60, bWeight: 10, temp: 15, speed: 30.0, watts: 145.26436011904764),
      TestData(aWeight: 60, bWeight: 10, temp: 30, speed: 30.0, watts: 139.43206845238097),
      TestData(aWeight: 60, bWeight: 11, temp: 0, speed: 30.0, watts: 151.94913159013606),
      TestData(aWeight: 60, bWeight: 11, temp: 15, speed: 30.0, watts: 145.6813116496599),
      TestData(aWeight: 60, bWeight: 11, temp: 30, speed: 30.0, watts: 139.84901998299324),
      TestData(aWeight: 70, bWeight: 9, temp: 0, speed: 30.0, watts: 155.28474383503405),
      TestData(aWeight: 70, bWeight: 9, temp: 15, speed: 30.0, watts: 149.01692389455786),
      TestData(aWeight: 70, bWeight: 9, temp: 30, speed: 30.0, watts: 143.1846322278912),
      TestData(aWeight: 70, bWeight: 10, temp: 0, speed: 30.0, watts: 155.7016953656463),
      TestData(aWeight: 70, bWeight: 10, temp: 15, speed: 30.0, watts: 149.4338754251701),
      TestData(aWeight: 70, bWeight: 10, temp: 30, speed: 30.0, watts: 143.6015837585034),
      TestData(aWeight: 70, bWeight: 11, temp: 0, speed: 30.0, watts: 156.11864689625855),
      TestData(aWeight: 70, bWeight: 11, temp: 15, speed: 30.0, watts: 149.85082695578237),
      TestData(aWeight: 70, bWeight: 11, temp: 30, speed: 30.0, watts: 144.01853528911568),
      TestData(aWeight: 80, bWeight: 9, temp: 0, speed: 30.0, watts: 159.4542591411565),
      TestData(aWeight: 80, bWeight: 9, temp: 15, speed: 30.0, watts: 153.1864392006803),
      TestData(aWeight: 80, bWeight: 9, temp: 30, speed: 30.0, watts: 147.35414753401363),
      TestData(aWeight: 80, bWeight: 10, temp: 0, speed: 30.0, watts: 159.87121067176872),
      TestData(aWeight: 80, bWeight: 10, temp: 15, speed: 30.0, watts: 153.60339073129254),
      TestData(aWeight: 80, bWeight: 10, temp: 30, speed: 30.0, watts: 147.77109906462587),
      TestData(aWeight: 80, bWeight: 11, temp: 0, speed: 30.0, watts: 160.288162202381),
      TestData(aWeight: 80, bWeight: 11, temp: 15, speed: 30.0, watts: 154.02034226190477),
      TestData(aWeight: 80, bWeight: 11, temp: 30, speed: 30.0, watts: 148.18805059523814),
    ]) {
      test(
          "for ${testData.aWeight} ${testData.bWeight} ${testData.temp} ${testData.speed} -> ${testData.watts}",
          () async {
        final prefService = await initPrefServiceForTest();
        await prefService.set<int>(athleteBodyWeightIntTag, testData.aWeight);
        await prefService.set<int>(bikeWeightTag, testData.bWeight);
        await prefService.set<int>(airTemperatureTag, testData.temp);
        final speed2Power = PowerSpeedMixin();
        await speed2Power.initPower2SpeedConstants();

        final power = speed2Power.powerForVelocity(testData.speed * DeviceDescriptor.kmh2ms);
        expect(power, closeTo(testData.watts, eps));
        // debugPrint(
        //     "${testData.aWeight} ${testData.bWeight} ${testData.temp} ${testData.speed} -> $power");
      });
    }
  });
}
