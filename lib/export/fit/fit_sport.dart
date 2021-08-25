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
  ActivityType.AlpineSki: Tuple2(13, 9),
  ActivityType.BackcountrySki: Tuple2(12, 0), // Crosscountry skiing
  ActivityType.Canoeing: Tuple2(PADDLING_SPORT_ID, 0), // Paddling
  ActivityType.Crossfit: Tuple2(TRAINING_SPORT_ID, 0), // Training
  ActivityType.EBikeRide: Tuple2(CYCLING_SPORT_ID, 28),
  ActivityType.Elliptical: Tuple2(FITNESS_EQUIPMENT_SPORT_ID, 15), // Fitness Equipment, Elliptical
  ActivityType.Golf: Tuple2(25, 0),
  ActivityType.Handcycle: Tuple2(GENERIC_SPORT_ID, 12),
  ActivityType.Hike: Tuple2(17, 3), // Hiking, Trail
  ActivityType.IceSkate: Tuple2(33, 0),
  "IndoorRowing": Tuple2(FITNESS_EQUIPMENT_SPORT_ID, 14),
  "IndoorRunning": Tuple2(RUNNING_SPORT_ID, 45),
  ActivityType.InlineSkate: Tuple2(30, 0),
  ActivityType.Kayaking: Tuple2(41, 0),
  ActivityType.Kitesurf: Tuple2(44, 0),
  ActivityType.NordicSki: Tuple2(GENERIC_SPORT_ID, 0),
  "OpenWaterSwim": Tuple2(SWIMMING_SPORT_ID, 18),
  "Paddling": Tuple2(PADDLING_SPORT_ID, 0),
  ActivityType.Ride: Tuple2(CYCLING_SPORT_ID, 0), // Cycling
  ActivityType.RockClimbing: Tuple2(48, 0), // Floor climbing
  ActivityType.RollerSki: Tuple2(GENERIC_SPORT_ID, 0),
  ActivityType.Rowing: Tuple2(15, 0),
  ActivityType.Run: Tuple2(RUNNING_SPORT_ID, 0),
  ActivityType.Sail: Tuple2(32, 0),
  ActivityType.Skateboard: Tuple2(GENERIC_SPORT_ID, 0),
  ActivityType.Snowboard: Tuple2(14, 0),
  ActivityType.Snowshoe: Tuple2(35, 0),
  ActivityType.Soccer: Tuple2(7, 0),
  ActivityType.StairStepper: Tuple2(FITNESS_EQUIPMENT_SPORT_ID, 16),
  ActivityType.StandUpPaddling: Tuple2(37, 0),
  ActivityType.Surfing: Tuple2(38, 0),
  ActivityType.Swim: Tuple2(SWIMMING_SPORT_ID, 0),
  "Treadmill": Tuple2(RUNNING_SPORT_ID, 1), // Treadmill running
  "TrackRide": Tuple2(CYCLING_SPORT_ID, 13),
  "TrackRun": Tuple2(RUNNING_SPORT_ID, 4),
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

Tuple2 toFitSport(String sport) {
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
