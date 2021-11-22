import 'package:tuple/tuple.dart';
import '../../utils/constants.dart';

const fitnessEquipmentSportId = 4;
const genericSportId = 0;
const runningSportId = 1;
const cyclingSportId = 2;
const swimmingSportId = 5;
const trainingSportId = 10;
const paddlingSportId = 19;

const Map<String, Tuple2<int, int>> fitSport = {
  ActivityType.AlpineSki: Tuple2(13, 9),
  ActivityType.BackcountrySki: Tuple2(12, 0), // Cross country skiing
  ActivityType.Canoeing: Tuple2(paddlingSportId, 0), // Paddling
  ActivityType.Crossfit: Tuple2(trainingSportId, 0), // Training
  ActivityType.EBikeRide: Tuple2(cyclingSportId, 28),
  ActivityType.Elliptical: Tuple2(fitnessEquipmentSportId, 15), // Fitness Equipment, Elliptical
  ActivityType.Golf: Tuple2(25, 0),
  ActivityType.Handcycle: Tuple2(genericSportId, 12),
  ActivityType.Hike: Tuple2(17, 3), // Hiking, Trail
  ActivityType.IceSkate: Tuple2(33, 0),
  "IndoorRowing": Tuple2(fitnessEquipmentSportId, 14),
  "IndoorRunning": Tuple2(runningSportId, 45),
  ActivityType.InlineSkate: Tuple2(30, 0),
  ActivityType.Kayaking: Tuple2(41, 0),
  ActivityType.Kitesurf: Tuple2(44, 0),
  ActivityType.NordicSki: Tuple2(genericSportId, 0),
  "OpenWaterSwim": Tuple2(swimmingSportId, 18),
  "Paddling": Tuple2(paddlingSportId, 0),
  ActivityType.Ride: Tuple2(cyclingSportId, 0), // Cycling
  ActivityType.RockClimbing: Tuple2(48, 0), // Floor climbing
  ActivityType.RollerSki: Tuple2(genericSportId, 0),
  ActivityType.Rowing: Tuple2(15, 0),
  ActivityType.Run: Tuple2(runningSportId, 0),
  ActivityType.Sail: Tuple2(32, 0),
  ActivityType.Skateboard: Tuple2(genericSportId, 0),
  ActivityType.Snowboard: Tuple2(14, 0),
  ActivityType.Snowshoe: Tuple2(35, 0),
  ActivityType.Soccer: Tuple2(7, 0),
  ActivityType.StairStepper: Tuple2(fitnessEquipmentSportId, 16),
  ActivityType.StandUpPaddling: Tuple2(37, 0),
  ActivityType.Surfing: Tuple2(38, 0),
  ActivityType.Swim: Tuple2(swimmingSportId, 0),
  "Treadmill": Tuple2(runningSportId, 1), // Treadmill running
  "TrackRide": Tuple2(cyclingSportId, 13),
  "TrackRun": Tuple2(runningSportId, 4),
  ActivityType.Velomobile: Tuple2(genericSportId, 0),
  ActivityType.VirtualRide: Tuple2(cyclingSportId, 6), // Cycling, Indoor Cycling
  ActivityType.VirtualRun: Tuple2(runningSportId, 1), // Treadmill running
  "VirtualRowing": Tuple2(paddlingSportId, 14), // Indoor Rowing
  ActivityType.Walk: Tuple2(11, 0),
  ActivityType.WeightTraining: Tuple2(trainingSportId, 0), // Training
  ActivityType.Wheelchair: Tuple2(genericSportId, 0),
  ActivityType.Windsurf: Tuple2(43, 0),
  ActivityType.Workout: Tuple2(genericSportId, 0),
  ActivityType.Yoga: Tuple2(trainingSportId, 43),
};

Tuple2 toFitSport(String sport) {
  if (sport == ActivityType.Canoeing) {
    sport = ActivityType.Kayaking;
  }

  if (!fitSport.containsKey(sport)) {
    sport = "Workout";
  }

  return fitSport[sport] ?? fitSport["Workout"]!;
}
