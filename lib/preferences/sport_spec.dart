import '../utils/constants.dart';

class SportSpec {
  static const paddleSport = "Paddle";
  static const sportPrefixes = [
    ActivityType.ride,
    ActivityType.run,
    paddleSport,
    ActivityType.swim,
    ActivityType.elliptical,
  ];

  static String sport2Sport(String sport) {
    return sport == ActivityType.kayaking ||
            sport == ActivityType.canoeing ||
            sport == ActivityType.rowing ||
            sport == ActivityType.nordicSki
        ? SportSpec.paddleSport
        : sport;
  }
}
