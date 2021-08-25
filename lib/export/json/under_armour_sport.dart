import '../../utils/constants.dart';

Map<String, int> underArmourSport = {
  ActivityType.AlpineSki: 74,
  ActivityType.BackcountrySki: 397, // Crosscountry skiing
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
  ActivityType.Sail: Tuple2(32, 0),
  ActivityType.Skateboard: Tuple2(GENERIC_SPORT_ID, 0),
  ActivityType.Snowboard: Tuple2(14, 0),
  ActivityType.Snowshoe: Tuple2(35, 0),
  ActivityType.Soccer: Tuple2(7, 0),
  ActivityType.StairStepper: Tuple2(FITNESS_EQUIPMENT_SPORT_ID, 16),
  ActivityType.StandUpPaddling: Tuple2(37, 0),
  ActivityType.Surfing: Tuple2(38, 0),
  ActivityType.Swim: Tuple2(SWIMMING_SPORT_ID, 0),
  "Treadmill": 208, // Treadmill running
  "TrackRide": 44,
  "TrackRun": 108,
  ActivityType.Velomobile: Tuple2(GENERIC_SPORT_ID, 0),
  ActivityType.VirtualRide: Tuple2(CYCLING_SPORT_ID, 6), // Cycling, Indoor Cycling
  ActivityType.VirtualRun: Tuple2(RUNNING_SPORT_ID, 1), // Treadmill running
  "VirtualRowing": Tuple2(PADDLING_SPORT_ID, 14), // Indoor Rowing
  ActivityType.Walk: Tuple2(11, 0),
  ActivityType.WeightTraining: Tuple2(TRAINING_SPORT_ID, 0), // Training
  ActivityType.Wheelchair: Tuple2(GENERIC_SPORT_ID, 0),
  ActivityType.Windsurf: Tuple2(43, 0),
  ActivityType.Workout: Tuple2(GENERIC_SPORT_ID, 0),
  ActivityType.Yoga: Tuple2(TRAINING_SPORT_ID, 43),
};

int toFitSport(String sport) {
  if (sport == ActivityType.Swim) {
    sport = "OpenWaterSwim";
  } else if (sport == ActivityType.Canoeing) {
    sport = ActivityType.Kayaking;
  } else if (sport == ActivityType.Run) {
    sport = "TrackRun";
  } else if (sport == ActivityType.Ride) {
    sport = "TrackRide";
  } else if (sport == ActivityType.Elliptical) {
    sport = "Elliptical";
  }

  if (!fitSport.containsKey(sport)) {
    sport = "Workout";
  }

  return fitSport[sport] ?? fitSport["Workout"]!;
}
