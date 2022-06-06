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
  group("velocityForPowerCardano calculates expected values:", () {
    for (final testData in [
      TestData(aWeight: 60, bWeight: 9, temp: 0, speed: 16.021582540896325, watts: 34),
      TestData(aWeight: 60, bWeight: 9, temp: 15, speed: 20.230959259024676, watts: 55),
      TestData(aWeight: 60, bWeight: 9, temp: 30, speed: 20.195520288217864, watts: 53),
      TestData(aWeight: 60, bWeight: 10, temp: 0, speed: 19.241436897812292, watts: 51),
      TestData(aWeight: 60, bWeight: 10, temp: 15, speed: 20.1858986617957, watts: 55),
      TestData(aWeight: 60, bWeight: 10, temp: 30, speed: 20.148404188649423, watts: 53),
      TestData(aWeight: 60, bWeight: 11, temp: 0, speed: 19.362494782652497, watts: 52),
      TestData(aWeight: 60, bWeight: 11, temp: 15, speed: 20.140869467681505, watts: 55),
      TestData(aWeight: 60, bWeight: 11, temp: 30, speed: 20.26861359737099, watts: 54),
      TestData(aWeight: 70, bWeight: 9, temp: 0, speed: 19.009690294311667, watts: 52),
      TestData(aWeight: 70, bWeight: 9, temp: 15, speed: 19.781829547754864, watts: 55),
      TestData(aWeight: 70, bWeight: 9, temp: 30, speed: 19.726053055191482, watts: 53),
      TestData(aWeight: 70, bWeight: 10, temp: 0, speed: 18.797922800205523, watts: 51),
      TestData(aWeight: 70, bWeight: 10, temp: 15, speed: 19.737106701704295, watts: 55),
      TestData(aWeight: 70, bWeight: 10, temp: 30, speed: 19.67932446403251, watts: 53),
      TestData(aWeight: 70, bWeight: 11, temp: 0, speed: 18.92184963854608, watts: 52),
      TestData(aWeight: 70, bWeight: 11, temp: 15, speed: 19.692420550930805, watts: 55),
      TestData(aWeight: 70, bWeight: 11, temp: 30, speed: 19.8024697027162, watts: 54),
      TestData(aWeight: 80, bWeight: 9, temp: 0, speed: 18.572060492662388, watts: 52),
      TestData(aWeight: 80, bWeight: 9, temp: 15, speed: 19.336316739918438, watts: 55),
      TestData(aWeight: 80, bWeight: 9, temp: 30, speed: 19.26073523339485, watts: 53),
      TestData(aWeight: 80, bWeight: 10, temp: 0, speed: 18.358310237795166, watts: 51),
      TestData(aWeight: 80, bWeight: 10, temp: 15, speed: 19.291985012643217, watts: 55),
      TestData(aWeight: 80, bWeight: 10, temp: 30, speed: 19.214455275316833, watts: 53),
      TestData(aWeight: 80, bWeight: 11, temp: 0, speed: 18.48502865702516, watts: 52),
      TestData(aWeight: 80, bWeight: 11, temp: 15, speed: 19.247695362597582, watts: 55),
      TestData(aWeight: 80, bWeight: 11, temp: 30, speed: 19.34045816698098, watts: 54),
      TestData(aWeight: 60, bWeight: 9, temp: 0, speed: 28.97375286192987, watts: 138),
      TestData(aWeight: 60, bWeight: 9, temp: 15, speed: 30.404945736187322, watts: 150),
      TestData(aWeight: 60, bWeight: 9, temp: 30, speed: 30.329194478793934, watts: 143),
      TestData(aWeight: 60, bWeight: 10, temp: 0, speed: 28.941204237353674, watts: 138),
      TestData(aWeight: 60, bWeight: 10, temp: 15, speed: 30.372145130106798, watts: 150),
      TestData(aWeight: 60, bWeight: 10, temp: 30, speed: 30.3763850005608, watts: 144),
      TestData(aWeight: 60, bWeight: 11, temp: 0, speed: 28.908661374863023, watts: 138),
      TestData(aWeight: 60, bWeight: 11, temp: 15, speed: 30.339349878521652, watts: 150),
      TestData(aWeight: 60, bWeight: 11, temp: 30, speed: 30.341996643656067, watts: 144),
      TestData(aWeight: 70, bWeight: 9, temp: 0, speed: 28.648537046008727, watts: 138),
      TestData(aWeight: 70, bWeight: 9, temp: 15, speed: 30.077190943744284, watts: 150),
      TestData(aWeight: 70, bWeight: 9, temp: 30, speed: 29.984762445420156, watts: 143),
      TestData(aWeight: 70, bWeight: 10, temp: 0, speed: 28.61605022892004, watts: 138),
      TestData(aWeight: 70, bWeight: 10, temp: 15, speed: 30.04444776082964, watts: 150),
      TestData(aWeight: 70, bWeight: 10, temp: 30, speed: 30.032795581514268, watts: 144),
      TestData(aWeight: 70, bWeight: 11, temp: 0, speed: 28.58357010897744, watts: 138),
      TestData(aWeight: 70, bWeight: 11, temp: 15, speed: 30.011710798516084, watts: 150),
      TestData(aWeight: 70, bWeight: 11, temp: 30, speed: 29.998474430994563, watts: 144),
      TestData(aWeight: 80, bWeight: 9, temp: 0, speed: 28.32398168649895, watts: 138),
      TestData(aWeight: 80, bWeight: 9, temp: 15, speed: 29.750049634869246, watts: 150),
      TestData(aWeight: 80, bWeight: 9, temp: 30, speed: 29.64104657867244, watts: 143),
      TestData(aWeight: 80, bWeight: 10, temp: 0, speed: 28.291566140858112, watts: 138),
      TestData(aWeight: 80, bWeight: 10, temp: 15, speed: 29.717372639634426, watts: 150),
      TestData(aWeight: 80, bWeight: 10, temp: 30, speed: 29.689923768177117, watts: 144),
      TestData(aWeight: 80, bWeight: 11, temp: 0, speed: 28.25915825235402, watts: 138),
      TestData(aWeight: 80, bWeight: 11, temp: 15, speed: 29.684702753882068, watts: 150),
      TestData(aWeight: 80, bWeight: 11, temp: 30, speed: 29.655679993405343, watts: 144),
    ]) {
      test(
          "for ${testData.aWeight} ${testData.bWeight} ${testData.temp} ${testData.watts} -> ${testData.speed}",
          () async {
        final prefService = await initPrefServiceForTest();
        await prefService.set<int>(athleteBodyWeightIntTag, testData.aWeight);
        await prefService.set<int>(bikeWeightTag, testData.bWeight);
        await prefService.set<int>(airTemperatureTag, testData.temp);
        final speed2Power = PowerSpeedMixin();
        await speed2Power.initPower2SpeedConstants();

        final velocity =
            speed2Power.velocityForPowerCardano(testData.watts.toInt()) * DeviceDescriptor.ms2kmh;
        expect(velocity, closeTo(testData.speed, displayEps));
        // debugPrint(
        //     "${testData.aWeight} ${testData.bWeight} ${testData.temp} ${testData.watts} -> $velocity");
      });
    }
  });
}
