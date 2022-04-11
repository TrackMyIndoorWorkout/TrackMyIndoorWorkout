import '../utils/constants.dart';
import 'sport_spec.dart';

const slowSpeedPostfix = " Slow Speed (kmh): the Speed Considered Too Slow to Display";
const slowSpeedTagPrefix = "slow_speed_";
const pacerSpeedPostfix = " Pacer Speed (kmh): the Speed of the Pacer";
const pacerSpeedTagPrefix = "pacer_speed_";

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

  static final pacerSpeedDefaults = {
    ActivityType.ride: 40.0,
    ActivityType.run: 14.85, // 6:30 min/mi
    SportSpec.paddleSport: 10.65, // ~2:49 min / 500m
    ActivityType.swim: 3.43, // 1:45 min / 100m
    ActivityType.elliptical: 10.65, // ~5:38 min / km
  };

  static final pacerSpeeds = {
    ActivityType.ride: pacerSpeedDefaults[ActivityType.ride],
    ActivityType.run: pacerSpeedDefaults[ActivityType.run],
    SportSpec.paddleSport: pacerSpeedDefaults[SportSpec.paddleSport],
    ActivityType.swim: pacerSpeedDefaults[ActivityType.swim],
    ActivityType.elliptical: pacerSpeedDefaults[ActivityType.elliptical],
  };

  static String slowSpeedTag(String sport) {
    return slowSpeedTagPrefix + SportSpec.sport2Sport(sport);
  }

  static String pacerSpeedTag(String sport) {
    return pacerSpeedTagPrefix + SportSpec.sport2Sport(sport);
  }
}
