import '../../utils/constants.dart';

Map<String, int> underArmourSport = {
  ActivityType.alpineSki: 74,
  ActivityType.backcountrySki: 397, // Cross country skiing
  ActivityType.canoeing: 57,
  ActivityType.crossfit: 704,
  ActivityType.eBikeRide: 1246,
  ActivityType.elliptical: 211,
  ActivityType.golf: 154,
  ActivityType.handcycle: 1249,
  ActivityType.hike: 24,
  ActivityType.iceSkate: 86,
  "IndoorRowing": 99,
  "IndoorRunning": 25,
  ActivityType.inlineSkate: 169,
  ActivityType.kayaking: 257,
  ActivityType.kitesurf: 205,
  ActivityType.nordicSki: 1237,
  "OpenWaterSwim": 180,
  "Paddling": 88,
  ActivityType.ride: 36, // Road Cycling
  ActivityType.rockClimbing: 234, // Indoor rock climbing
  ActivityType.rollerSki: 1255, // Skate skiing (roller skate / ski 101)
  ActivityType.rowing: 128, // Not indoor
  ActivityType.run: 16,
  ActivityType.sail: 29,
  ActivityType.skateboard: 95,
  ActivityType.snowboard: 107,
  ActivityType.snowshoe: 119,
  ActivityType.soccer: 176,
  ActivityType.stairStepper: 730,
  ActivityType.standUpPaddling: 863,
  ActivityType.surfing: 127,
  ActivityType.swim: 15,
  "Treadmill": 208, // Treadmill running
  "TrackRide": 44,
  "TrackRun": 108,
  ActivityType.velomobile: 1, // Generic
  ActivityType.virtualRide: 19, // Indoor Bike Ride
  ActivityType.virtualRun: 25, // Indoor Run / Jog
  "VirtualRowing": 99, // Rowing Machine
  ActivityType.walk: 9,
  ActivityType.weightTraining: 18, // Weight Workout
  ActivityType.wheelchair: 1201,
  ActivityType.windsurf: 94,
  ActivityType.workout: 2,
  ActivityType.yoga: 78, // Yoga Class
};

int toUnderArmourSport(String sport) {
  if (sport == ActivityType.canoeing) {
    sport = ActivityType.kayaking;
  }

  if (!underArmourSport.containsKey(sport)) {
    sport = ActivityType.workout;
  }

  return underArmourSport[sport] ?? underArmourSport[ActivityType.workout]!;
}
