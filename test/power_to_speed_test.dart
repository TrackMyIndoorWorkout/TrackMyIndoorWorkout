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
  group("velocityForPowerCardano calculates expected values:", () {
    for (final testData in [
      TestData(speed: 18.63647574301608, watts: 50),
      TestData(speed: 25.50479935480119, watts: 100),
      TestData(speed: 30.146795804886246, watts: 150),
      TestData(speed: 33.77259130327632, watts: 200),
      TestData(speed: 36.798226444608154, watts: 250),
      TestData(speed: 39.42120009211477, watts: 300),
      TestData(speed: 41.7523412704549, watts: 350),
      TestData(speed: 43.860690218087, watts: 400),
      TestData(speed: 45.79246250691772, watts: 450),
      TestData(speed: 47.580269673405844, watts: 500),
      TestData(speed: 49.24807175618899, watts: 550),
      TestData(speed: 50.81404373764031, watts: 600),
      TestData(speed: 52.29233422221367, watts: 650),
      TestData(speed: 53.69419624220849, watts: 700),
    ]) {
      test("for ${testData.watts} -> ${testData.speed}", () async {
        await initPrefServiceForTest();
        final speed2Power = PowerSpeedMixin();
        await speed2Power.initPower2SpeedConstants();

        final velocity =
            speed2Power.velocityForPowerCardano(testData.watts.toInt()) * DeviceDescriptor.ms2kmh;
        expect(velocity, closeTo(testData.speed, testData.speed * workaroundEpsRatio));
        // debugPrint("${testData.watts} -> $velocity");
      });
    }
  });
}
