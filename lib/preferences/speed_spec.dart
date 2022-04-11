import '../utils/constants.dart';
import 'sport_spec.dart';

const slowSpeedPostfix = " Speed (kmh) Considered Too Slow to Display";
const slowSpeedTagPrefix = "slow_speed_";

class SpeedSpec {
  static final slowSpeedDefaults = {
    ActivityType.ride: 4.0,
    ActivityType.run: 2.0,
    SportSpec.paddleSport: 1.0,
    ActivityType.swim: 0.5,
    ActivityType.elliptical: 1.0,
  };

  static final slowSpeeds = {
    ActivityType.ride: slowSpeedDefaults[ActivityType.ride],
    ActivityType.run: slowSpeedDefaults[ActivityType.run],
    SportSpec.paddleSport: slowSpeedDefaults[SportSpec.paddleSport],
    ActivityType.swim: slowSpeedDefaults[ActivityType.swim],
    ActivityType.elliptical: slowSpeedDefaults[ActivityType.elliptical],
  };

  static String slowSpeedTag(String sport) {
    return slowSpeedTagPrefix + SportSpec.sport2Sport(sport);
  }
}
