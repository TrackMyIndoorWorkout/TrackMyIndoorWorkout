import '../utils/constants.dart';
import 'sport_spec.dart';

const slowSpeedPostfix = " Speed (kmh) Considered Too Slow to Display";
const slowSpeedTagPrefix = "slow_speed_";

class SpeedSpec {
  static final slowSpeeds = {
    ActivityType.ride: 4.0,
    ActivityType.run: 2.0,
    SportSpec.paddleSport: 1.0,
    ActivityType.swim: 0.5,
    ActivityType.elliptical: 1.0,
  };

  static String slowSpeedTag(String sport) {
    return slowSpeedTagPrefix + SportSpec.sport2Sport(sport);
  }
}
