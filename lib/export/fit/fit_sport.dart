import 'package:tuple/tuple.dart';
import '../../utils/constants.dart';

const fitnessEquipmentSportId = 4;
const genericSportId = 0;
const runningSportId = 1;
const cyclingSportId = 2;
const swimmingSportId = 5;
const trainingSportId = 10;
const paddlingSportId = 19;

Map<String, Tuple2<int, int>> fitSport = {
  ActivityType.AlpineSki: const Tuple2(13, 9),
  ActivityType.BackcountrySki: const Tuple2(12, 0), // Cross country skiing
  ActivityType.Canoeing: const Tuple2(paddlingSportId, 0), // Paddling
  ActivityType.Crossfit: const Tuple2(trainingSportId, 0), // Training
  ActivityType.EBikeRide: const Tuple2(cyclingSportId, 28),
  ActivityType.Elliptical: const Tuple2(fitnessEquipmentSportId, 15), // Fitness Equipment, Elliptical
  ActivityType.Golf: const Tuple2(25, 0),
  ActivityType.Handcycle: const Tuple2(genericSportId, 12),
  ActivityType.Hike: const Tuple2(17, 3), // Hiking, Trail
  ActivityType.IceSkate: const Tuple2(33, 0),
  "IndoorRowing": const Tuple2(fitnessEquipmentSportId, 14),
  "IndoorRunning": const Tuple2(runningSportId, 45),
  ActivityType.InlineSkate: const Tuple2(30, 0),
  ActivityType.Kayaking: const Tuple2(41, 0),
  ActivityType.Kitesurf: const Tuple2(44, 0),
  ActivityType.NordicSki: const Tuple2(genericSportId, 0),
  "OpenWaterSwim": const Tuple2(swimmingSportId, 18),
  "Paddling": const Tuple2(paddlingSportId, 0),
  ActivityType.Ride: const Tuple2(cyclingSportId, 0), // Cycling
  ActivityType.RockClimbing: const Tuple2(48, 0), // Floor climbing
  ActivityType.RollerSki: const Tuple2(genericSportId, 0),
  ActivityType.Rowing: const Tuple2(15, 0),
  ActivityType.Run: const Tuple2(runningSportId, 0),
  ActivityType.Sail: const Tuple2(32, 0),
  ActivityType.Skateboard: const Tuple2(genericSportId, 0),
  ActivityType.Snowboard: const Tuple2(14, 0),
  ActivityType.Snowshoe: const Tuple2(35, 0),
  ActivityType.Soccer: const Tuple2(7, 0),
  ActivityType.StairStepper: const Tuple2(fitnessEquipmentSportId, 16),
  ActivityType.StandUpPaddling: const Tuple2(37, 0),
  ActivityType.Surfing: const Tuple2(38, 0),
  ActivityType.Swim: const Tuple2(swimmingSportId, 0),
  "Treadmill": const Tuple2(runningSportId, 1), // Treadmill running
  "TrackRide": const Tuple2(cyclingSportId, 13),
  "TrackRun": const Tuple2(runningSportId, 4),
  ActivityType.Velomobile: const Tuple2(genericSportId, 0),
  ActivityType.VirtualRide: const Tuple2(cyclingSportId, 6), // Cycling, Indoor Cycling
  ActivityType.VirtualRun: const Tuple2(runningSportId, 1), // Treadmill running
  "VirtualRowing": const Tuple2(paddlingSportId, 14), // Indoor Rowing
  ActivityType.Walk: const Tuple2(11, 0),
  ActivityType.WeightTraining: const Tuple2(trainingSportId, 0), // Training
  ActivityType.Wheelchair: const Tuple2(genericSportId, 0),
  ActivityType.Windsurf: const Tuple2(43, 0),
  ActivityType.Workout: const Tuple2(genericSportId, 0),
  ActivityType.Yoga: const Tuple2(trainingSportId, 43),
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
