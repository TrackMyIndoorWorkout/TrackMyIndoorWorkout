// import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'package:track_my_indoor_exercise/utils/power_speed_mixin.dart';

class TestData {
  final double speed;
  final double watts;

  TestData({required this.speed, required this.watts});
}

void main() {
  group("powerForVelocity calculates expected values:", () {
    for (final testData in [
      TestData(speed: 15.0, watts: 32.751977306547616),
      TestData(speed: 20.0, watts: 57.96038139329806),
      TestData(speed: 25.0, watts: 95.41828118110672),
      TestData(speed: 30.0, watts: 148.18805059523814),
      TestData(speed: 35.0, watts: 219.3320635609568),
      TestData(speed: 40.0, watts: 311.91269400352735),
      TestData(speed: 45.0, watts: 428.9923158482143),
    ]) {
      test("for ${testData.speed} -> ${testData.watts}", () async {
        await initPrefServiceForTest();
        final speed2Power = PowerSpeedMixin();
        await speed2Power.initPower2SpeedConstants();

        final power = speed2Power.powerForVelocity(testData.speed * DeviceDescriptor.kmh2ms);
        expect(power, closeTo(testData.watts, testData.watts * workaroundEpsRatio));
        // debugPrint("${testData.speed} -> $power");
      });
    }
  });
}
