import 'package:tuple/tuple.dart';
import '../../utils/constants.dart';

const FITNESS_EQUIPMENT_SPORT_ID = 4;
const GENERIC_SPORT_ID = 0;
const RUNNING_SPORT_ID = 1;
const CYCLING_SPORT_ID = 2;
const SWIMMING_SPORT_ID = 5;
const TRAINING_SPORT_ID = 10;
const PADDLING_SPORT_ID = 19;

Map<String, Tuple2<int, int>> fitSport = {
  "AlpineSki": Tuple2(13, 9),
  "BackcountrySki": Tuple2(12, 0), // Crosscountry skiing
  "Canoeing": Tuple2(PADDLING_SPORT_ID, 0), // Paddling
  "Crossfit": Tuple2(TRAINING_SPORT_ID, 0), // Training
  "EBikeRide": Tuple2(CYCLING_SPORT_ID, 28),
  "Elliptical": Tuple2(FITNESS_EQUIPMENT_SPORT_ID, 15), // Fitness Equipment, Elliptical
  "Golf": Tuple2(25, 0),
  "Handcycle": Tuple2(GENERIC_SPORT_ID, 12),
  "Hike": Tuple2(17, 3), // Hiking, Trail
  "IceSkate": Tuple2(33, 0),
  "IndoorRowing": Tuple2(FITNESS_EQUIPMENT_SPORT_ID, 14),
  "IndoorRunning": Tuple2(RUNNING_SPORT_ID, 45),
  "InlineSkate": Tuple2(30, 0),
  "Kayaking": Tuple2(41, 0),
  "Kitesurf": Tuple2(44, 0),
  "NordicSki": Tuple2(GENERIC_SPORT_ID, 0),
  "OpenWaterSwim": Tuple2(SWIMMING_SPORT_ID, 18),
  "Paddling": Tuple2(PADDLING_SPORT_ID, 0),
  "Ride": Tuple2(CYCLING_SPORT_ID, 0), // Cycling
  "RockClimbing": Tuple2(48, 0), // Floor climbing
  "RollerSki": Tuple2(GENERIC_SPORT_ID, 0),
  "Rowing": Tuple2(15, 0),
  "Run": Tuple2(RUNNING_SPORT_ID, 0),
  "Sail": Tuple2(32, 0),
  "Skateboard": Tuple2(GENERIC_SPORT_ID, 0),
  "Snowboard": Tuple2(14, 0),
  "Snowshoe": Tuple2(35, 0),
  "Soccer": Tuple2(7, 0),
  "StairStepper": Tuple2(FITNESS_EQUIPMENT_SPORT_ID, 16),
  "StandUpPaddling": Tuple2(37, 0),
  "Surfing": Tuple2(38, 0),
  "Swim": Tuple2(SWIMMING_SPORT_ID, 0),
  "Treadmill": Tuple2(RUNNING_SPORT_ID, 1), // Treadmill running
  "TrackRide": Tuple2(CYCLING_SPORT_ID, 13),
  "TrackRun": Tuple2(RUNNING_SPORT_ID, 4),
  "Velomobile": Tuple2(GENERIC_SPORT_ID, 0),
  "VirtualRide": Tuple2(CYCLING_SPORT_ID, 6), // Cycling, Indoor Cycling
  "VirtualRun": Tuple2(RUNNING_SPORT_ID, 1), // Treadmill running
  "VirtualRowing": Tuple2(PADDLING_SPORT_ID, 14), // Indoor Rowing
  "Walk": Tuple2(11, 0),
  "WeightTraining": Tuple2(TRAINING_SPORT_ID, 0), // Training
  "Wheelchair": Tuple2(GENERIC_SPORT_ID, 0),
  "Windsurf": Tuple2(43, 0),
  "Workout": Tuple2(GENERIC_SPORT_ID, 0),
  "Yoga": Tuple2(TRAINING_SPORT_ID, 43),
};

Tuple2 activityType2FitSport(String sport) {
  if (sport == ActivityType.Swim) {
    sport = "OpenWaterSwim";
  } else if (sport == ActivityType.Canoeing) {
    sport = "Paddling";
  } else if (sport == ActivityType.Kayaking) {
    sport = "Paddling";
  } else if (sport == ActivityType.Run) {
    sport = "TrackRun";
  } else if (sport == ActivityType.Ride) {
    sport = "TrackRide";
  }

  if (!fitSport.containsKey(sport)) {
    sport = "Workout";
  }

  return fitSport[sport];
}
