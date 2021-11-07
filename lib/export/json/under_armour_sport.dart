import '../../utils/constants.dart';

Map<String, int> underArmourSport = {
  ActivityType.AlpineSki: 74,
  ActivityType.BackcountrySki: 397, // Cross country skiing
  ActivityType.Canoeing: 57,
  ActivityType.Crossfit: 704,
  ActivityType.EBikeRide: 1246,
  ActivityType.Elliptical: 211,
  ActivityType.Golf: 154,
  ActivityType.Handcycle: 1249,
  ActivityType.Hike: 24,
  ActivityType.IceSkate: 86,
  "IndoorRowing": 99,
  "IndoorRunning": 25,
  ActivityType.InlineSkate: 169,
  ActivityType.Kayaking: 257,
  ActivityType.Kitesurf: 205,
  ActivityType.NordicSki: 1237,
  "OpenWaterSwim": 180,
  "Paddling": 88,
  ActivityType.Ride: 36, // Road Cycling
  ActivityType.RockClimbing: 234, // Indoor rock climbing
  ActivityType.RollerSki: 1255, // Skate skiing (roller skate / ski 101)
  ActivityType.Rowing: 128, // Not indoor
  ActivityType.Run: 16,
  ActivityType.Sail: 29,
  ActivityType.Skateboard: 95,
  ActivityType.Snowboard: 107,
  ActivityType.Snowshoe: 119,
  ActivityType.Soccer: 176,
  ActivityType.StairStepper: 730,
  ActivityType.StandUpPaddling: 863,
  ActivityType.Surfing: 127,
  ActivityType.Swim: 15,
  "Treadmill": 208, // Treadmill running
  "TrackRide": 44,
  "TrackRun": 108,
  ActivityType.Velomobile: 1, // Generic
  ActivityType.VirtualRide: 19, // Indoor Bike Ride
  ActivityType.VirtualRun: 25, // Indoor Run / Jog
  "VirtualRowing": 99, // Rowing Machine
  ActivityType.Walk: 9,
  ActivityType.WeightTraining: 18, // Weight Workout
  ActivityType.Wheelchair: 1201,
  ActivityType.Windsurf: 94,
  ActivityType.Workout: 2,
  ActivityType.Yoga: 78, // Yoga Class
};

int toUnderArmourSport(String sport) {
  if (sport == ActivityType.Swim) {
    sport = "Swim";
  } else if (sport == ActivityType.Canoeing) {
    sport = ActivityType.Kayaking;
  } else if (sport == ActivityType.Run) {
    sport = "Run";
  } else if (sport == ActivityType.Ride) {
    sport = "Ride";
  } else if (sport == ActivityType.Elliptical) {
    sport = "Elliptical";
  }

  if (!underArmourSport.containsKey(sport)) {
    sport = "Workout";
  }

  return underArmourSport[sport] ?? underArmourSport["Workout"]!;
}
