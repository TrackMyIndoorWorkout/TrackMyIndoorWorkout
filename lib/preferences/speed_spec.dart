import '../utils/constants.dart';
import 'sport_spec.dart';

const slowSpeedPostfix = " Slow Speed (kmh): the Speed Considered Too Slow to Display";
const slowSpeedTagPrefix = "slow_speed_";
const pacerSpeedPostfix = " Pacer Speed (kmh): the Speed of the Pacer";
const pacerSpeedTagPrefix = "pacer_speed_";

class SpeedSpec {
  static final slowSpeedDefaults = {
    ActivityType.ride: 1.0,
    ActivityType.run: 0.5,
    SportSpec.paddleSport: 0.2,
    ActivityType.swim: 0.1,
    ActivityType.elliptical: 0.2,
    ActivityType.stairStepper: 0.1,
    ActivityType.rockClimbing: 0.1,
  };

  static final slowSpeeds = {
    ActivityType.ride: slowSpeedDefaults[ActivityType.ride],
    ActivityType.run: slowSpeedDefaults[ActivityType.run],
    SportSpec.paddleSport: slowSpeedDefaults[SportSpec.paddleSport],
    ActivityType.swim: slowSpeedDefaults[ActivityType.swim],
    ActivityType.elliptical: slowSpeedDefaults[ActivityType.elliptical],
    ActivityType.stairStepper: slowSpeedDefaults[ActivityType.swim],
    ActivityType.rockClimbing: slowSpeedDefaults[ActivityType.swim],
  };

  static final pacerSpeedDefaults = {
    ActivityType.ride: 40.0,
    ActivityType.run: 14.85, // 6:30 min/mi
    SportSpec.paddleSport: 10.65, // ~2:49 min / 500m
    ActivityType.swim: 3.43, // 1:45 min / 100m
    ActivityType.elliptical: 10.65, // ~5:38 min / km
    ActivityType.stairStepper: 3.43, // 1:45 min / 100m
    ActivityType.rockClimbing: 3.43, // 1:45 min / 100m
  };

  static final pacerSpeeds = {
    ActivityType.ride: pacerSpeedDefaults[ActivityType.ride],
    ActivityType.run: pacerSpeedDefaults[ActivityType.run],
    SportSpec.paddleSport: pacerSpeedDefaults[SportSpec.paddleSport],
    ActivityType.swim: pacerSpeedDefaults[ActivityType.swim],
    ActivityType.elliptical: pacerSpeedDefaults[ActivityType.elliptical],
    ActivityType.stairStepper: pacerSpeedDefaults[ActivityType.swim],
    ActivityType.rockClimbing: pacerSpeedDefaults[ActivityType.swim],
  };

  static String slowSpeedTag(String sport) {
    return slowSpeedTagPrefix + SportSpec.sport2Sport(sport);
  }

  static String pacerSpeedTag(String sport) {
    return pacerSpeedTagPrefix + SportSpec.sport2Sport(sport);
  }
}
