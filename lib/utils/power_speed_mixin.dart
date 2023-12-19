import 'dart:math';

import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../preferences/air_temperature.dart';
import '../preferences/athlete_body_weight.dart';
import '../preferences/bike_weight.dart';
import '../preferences/drag_force_tune.dart';
import '../preferences/drive_train_loss.dart';
import 'constants.dart';
import 'init_preferences.dart';

mixin PowerSpeedMixin {
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
  static double a = 0.0; // See Cardano's Formula
  static double c = 0.0; // fRolling, but also c in Cardano's Formula
  static double q = 0.0; // See Cardano's Formula
  static double driveTrainFraction = 0.0;
  static int dragForceTuneFactor = dragForceTuneDefault;
  static double dragForceTunePercent = dragForceTuneFactor / 100.0;

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
  final Map<int, double> velocityForPowerDict = <int, double>{};

  Future<void> initPower2SpeedConstants() async {
    if (testing) {
      velocityForPowerDict.clear();
      if (!Get.isRegistered<BasePrefService>()) {
        await initPrefServiceForTest();
      }
    }

    final prefService = Get.find<BasePrefService>();
    bool clearDictionary = false;
    final athleteWeightNew =
        prefService.get<int>(athleteBodyWeightIntTag) ?? athleteBodyWeightDefault;
    if (athleteWeightNew != athleteWeight) {
      athleteWeight = athleteWeightNew;
      clearDictionary = true;
    }

    final bikeWeightNewest = prefService.get<int>(bikeWeightTag) ?? bikeWeightDefault;
    if (bikeWeightNewest != bikeWeight) {
      bikeWeight = bikeWeightNewest;
      clearDictionary = true;
    }

    final driveTrainLossNewest = prefService.get<int>(driveTrainLossTag) ?? driveTrainLossDefault;
    if (driveTrainLossNewest != driveTrainLoss) {
      driveTrainLoss = driveTrainLossNewest;
      clearDictionary = true;
    }

    final airTemperatureNewest = prefService.get<int>(airTemperatureTag) ?? airTemperatureDefault;
    if (airTemperatureNewest != airTemperature) {
      airTemperature = airTemperatureNewest;
      airDensity = _airTemperatureToDensity[airTemperature] ?? airDensityDefault;
      clearDictionary = true;
    }

    final dragForceTuneNewest = prefService.get<int>(dragForceTuneTag) ?? dragForceTuneDefault;
    if (dragForceTuneNewest != dragForceTuneFactor) {
      dragForceTuneFactor = dragForceTuneNewest;
      dragForceTunePercent = dragForceTuneFactor / 100.0;
      clearDictionary = true;
    }

    if (clearDictionary) {
      velocityForPowerDict.clear();
    }

    a = 0.5 * frontalArea * dragCoefficient * airDensity * dragForceTunePercent;
    c = gConst * (athleteWeight + bikeWeight) * rollingResistanceCoefficient;
    q = c / (3 * a);
    driveTrainFraction = 1.0 - (driveTrainLoss / 100.0);
  }

  double sportFactor(String sport) {
    // TODO: elaborate in the future with sport specific algorithms!
    // When power is computed from speed meant to be used with cycling
    // the powerForVelocity would yield too low values. This comes to surface
    // for example with CSC sensor based Old Danube (#384). Kinomap would not
    // progress without power values reported.
    switch (sport) {
      case ActivityType.run:
      case ActivityType.rowing:
        return 1.9;
      case ActivityType.kayaking:
      case ActivityType.canoeing:
      case ActivityType.swim:
        return 3.0;
      case ActivityType.ride:
      case ActivityType.elliptical:
      default:
        return 1.0;
    }
  }

  double powerForVelocity(double velocity, String sport) {
    // https://www.gribble.org/cycling/power_v_speed.html
    // fDrag = 0.5 * frontalArea * dragCoefficient * airDensity * velocity * velocity;
    // totalForce = fRolling + fDrag;
    // wheelPower = totalForce * velocity;
    // driveTrainFraction = 1.0 - (driveTrainLoss / 100.0);
    // legPower = wheelPower / driveTrainFraction;
    return (c + a * velocity * velocity) * velocity / driveTrainFraction * sportFactor(sport);
  }

  double velocityForPowerCardano(int power) {
    // Looking at https://proofwiki.org/wiki/Cardano%27s_Formula
    // https://brilliant.org/wiki/cardano-method/
    // It returns m/s
    if (velocityForPowerDict.containsKey(power)) {
      return velocityForPowerDict[power] ?? 0.0;
    }

    final dNeg = driveTrainFraction * power;
    final r = dNeg / (2 * a);
    final e = sqrt(q * q * q + r * r);
    const third = 1 / 3;
    final rAddE = r + e;
    // Dart pow doesn't like negative bases
    final s = rAddE > 0 ? pow(rAddE, third) : -pow(-rAddE, third);
    final rSubE = r - e;
    final t = rSubE > 0 ? pow(rSubE, third) : -pow(-rSubE, third);
    final speed = (s + t).toDouble();

    velocityForPowerDict[power] = speed;
    return speed;
  }
}

class PowerSpeedMixinImpl with PowerSpeedMixin {}
