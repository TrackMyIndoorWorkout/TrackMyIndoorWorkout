import '../utils/constants.dart';

class SportSpec {
  static const paddleSport = "Paddle";
  static const sportPrefixes = [
    ActivityType.ride,
    ActivityType.run,
    paddleSport,
    ActivityType.swim,
    ActivityType.elliptical,
    ActivityType.stairStepper,
    ActivityType.rockClimbing
  ];

  static String sport2Sport(String sport) {
    if (sport == ActivityType.kayaking ||
        sport == ActivityType.canoeing ||
        sport == ActivityType.rowing ||
        sport == ActivityType.nordicSki) {
      return SportSpec.paddleSport;
    }

    if (sport == ActivityType.stairStepper || sport == ActivityType.rockClimbing) {
      return ActivityType.swim;
    }

    return sport;
  }
}
