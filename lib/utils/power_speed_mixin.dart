import 'dart:math';

import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../preferences/air_temperature.dart';
import '../preferences/athlete_body_weight.dart';
import '../preferences/bike_weight.dart';
import '../preferences/drive_train_loss.dart';
import 'constants.dart';
import 'init_preferences.dart';

class PowerSpeedMixin {
  // https://www.gribble.org/cycling/power_v_speed.html
  static const epsilon = 0.001;
  static const maxIterations = 100;
  static int driveTrainLoss = driveTrainLossDefault; // 2 %
  static const gConst = 9.8067;
  static int athleteWeight = athleteBodyWeightDefault; // 80 kg
  static int bikeWeight = bikeWeightDefault; // 9 kg
  static const rollingResistanceCoefficient = 0.005;
  static const dragCoefficient = 0.63;
  static double frontalArea = 0.509; // m^2
  // https://www.gribble.org/cycling/air_density.html
  static int airTemperature = airTemperatureDefault; // 15 C
  static double airDensity = airDensityDefault; // default for 15 Celsius
  static double fRolling = 0.0;

  // https://en.wikipedia.org/wiki/Density_of_air
  static final Map<int, double> _airTemperatureToDensity = {
    35: 1.1455,
    30: 1.1644,
    25: 1.1839,
    20: 1.2041,
    airTemperatureDefault: airDensityDefault,
    10: 1.2466,
    5: 1.2690,
    0: 1.2922,
    -5: 1.3163,
    -10: 1.3413,
    -15: 1.3673,
    -20: 1.3943,
    -25: 1.4224,
  };

  Future<void> initPower2SpeedConstants() async {
    if (testing) {
      if (!Get.isRegistered<BasePrefService>()) {
        await initPrefServiceForTest();
      }
    }

    final prefService = Get.find<BasePrefService>();
    final athleteWeightNew =
        prefService.get<int>(athleteBodyWeightIntTag) ?? athleteBodyWeightDefault;
    if (athleteWeightNew != athleteWeight) {
      athleteWeight = athleteWeightNew;
    }

    final bikeWeightNewest = prefService.get<int>(bikeWeightTag) ?? bikeWeightDefault;
    if (bikeWeightNewest != bikeWeight) {
      bikeWeight = bikeWeightNewest;
    }

    final driveTrainLossNewest = prefService.get<int>(driveTrainLossTag) ?? driveTrainLossDefault;
    if (driveTrainLossNewest != driveTrainLoss) {
      driveTrainLoss = driveTrainLossNewest;
    }

    final airTemperatureNewest = prefService.get<int>(airTemperatureTag) ?? airTemperatureDefault;
    if (airTemperatureNewest != airTemperature) {
      airTemperature = airTemperatureNewest;
      airDensity = _airTemperatureToDensity[airTemperature] ?? airDensityDefault;
    }

    fRolling = gConst * (athleteWeight + bikeWeight) * rollingResistanceCoefficient;
  }

  double powerForVelocity(velocity) {
    final fDrag = 0.5 * frontalArea * dragCoefficient * airDensity * velocity * velocity;
    final totalForce = fRolling + fDrag;
    final wheelPower = totalForce * velocity;
    final driveTrainFraction = 1.0 - (driveTrainLoss / 100.0);
    final legPower = wheelPower / driveTrainFraction;
    return legPower;
  }

  double velocityForPowerCardano(int power) {
    // Looking at https://proofwiki.org/wiki/Cardano%27s_Formula
    // https://brilliant.org/wiki/cardano-method/
    // It returns m/s
    final driveTrainFraction = 1.0 - (driveTrainLoss / 100.0);
    final a = 0.5 * dragCoefficient * frontalArea * airDensity;
    final c = gConst * (athleteWeight + bikeWeight) * rollingResistanceCoefficient;
    final dNeg = driveTrainFraction * power;
    final q = c / (3 * a);
    final r = dNeg / (2 * a);
    final e = sqrt(q * q * q + r * r);
    const third = 1 / 3;
    final rAddE = r + e;
    // Dart pow doesn't like negative bases
    final negateS = rAddE < 0;
    final s = pow(rAddE.abs(), third) * (negateS ? -1 : 1);
    final rSubE = r - e;
    final negateT = rSubE < 0;
    final t = pow(rSubE.abs(), third) * (negateT ? -1 : 1);
    return (s + t).toDouble();
  }
}
