import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../preferences/athlete_body_weight.dart';
import 'constants.dart';

class PowerSpeedMixin {
  static const energy2speed = 5.28768241564455E-05;
  static const epsilon = 0.001;
  static const maxIterations = 100;
  static const driveTrainLoss = 1; // %
  static const gConst = 9.8067;
  static const bikerWeightDefault = 81; // kg
  static int bikerWeight = bikerWeightDefault; // kg
  static int bikeWeight = 9; // kg
  static const rollingResistanceCoefficient = 0.005;
  static const dragCoefficient = 0.63;
  // Backup: 5.4788
  static const frontalArea = 4 * ftToM * ftToM; // ft * ft_2_m^2
  static const airDensity = 0.076537 * lbToKg / (ftToM * ftToM * ftToM);
  static double fRolling = 0.0;
  static final Map<int, double> _velocityForPowerDict = <int, double>{};

  void initPower2SpeedConstants() {
    final prefService = Get.find<BasePrefService>();
    final bikeWeightNewest = prefService.get<int>(athleteBodyWeightIntTag) ?? bikerWeightDefault;
    if (bikeWeightNewest != bikerWeight) {
      _velocityForPowerDict.clear();
      bikerWeight = bikeWeightNewest;
    }

    fRolling = gConst * (bikerWeight + bikeWeight) * rollingResistanceCoefficient;
  }

  double powerForVelocity(velocity) {
    final fDrag = 0.5 * frontalArea * dragCoefficient * airDensity * velocity * velocity;
    final totalForce = fRolling + fDrag;
    final wheelPower = totalForce * velocity;
    const driveTrainFraction = 1.0 - (driveTrainLoss / 100.0);
    final legPower = wheelPower / driveTrainFraction;
    return legPower;
  }

  double velocityForPower(int power) {
    if (_velocityForPowerDict.containsKey(power)) {
      return _velocityForPowerDict[power] ?? 0.0;
    }

    var lowerVelocity = 0.0;
    var upperVelocity = 2000.0;
    var middleVelocity = power * energy2speed * 1000;
    var middlePower = powerForVelocity(middleVelocity);

    var i = 0;
    do {
      if ((middlePower - power).abs() < epsilon) break;

      if (middlePower > power) {
        upperVelocity = middleVelocity;
      } else {
        lowerVelocity = middleVelocity;
      }

      middleVelocity = (upperVelocity + lowerVelocity) / 2.0;
      middlePower = powerForVelocity(middleVelocity);
    } while (i++ < maxIterations);

    _velocityForPowerDict[power] = middleVelocity;
    return middleVelocity;
  }
}
