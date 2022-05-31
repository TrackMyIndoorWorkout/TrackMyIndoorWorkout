import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../preferences/athlete_body_weight.dart';
import '../preferences/bike_weight.dart';
import '../preferences/drive_train_loss.dart';
import 'constants.dart';
import 'init_preferences.dart';

class PowerSpeedMixin {
  static const energy2speed = 5.28768241564455E-05;
  static const epsilon = 0.001;
  static const maxIterations = 100;
  static int driveTrainLoss = driveTrainLossDefault; // 1 %
  static const gConst = 9.8067;
  static int athleteWeight = athleteBodyWeightDefault; // 80 kg
  static int bikeWeight = bikeWeightDefault; // 9 kg
  static const rollingResistanceCoefficient = 0.005;
  static const dragCoefficient = 0.63;
  // Backup: 5.4788
  static const frontalArea = 4 * ftToM * ftToM; // ft * ft_2_m^2
  static const airDensity = 0.076537 * lbToKg / (ftToM * ftToM * ftToM);
  static double fRolling = 0.0;
  static final Map<int, double> _velocityForPowerDict = <int, double>{};

  Future<void> initPower2SpeedConstants() async {
    if (testing) {
      await initPrefServiceForTest();
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

    final driveTrainLossNewest = prefService.get<int>(bikeWeightTag) ?? bikeWeightDefault;
    if (driveTrainLossNewest != driveTrainLoss) {
      driveTrainLoss = driveTrainLossNewest;
      clearDictionary = true;
    }

    if (clearDictionary) {
      _velocityForPowerDict.clear();
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
