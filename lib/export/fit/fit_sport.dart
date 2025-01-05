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
  ActivityType.alpineSki: Tuple2(13, 9),
  ActivityType.backcountrySki: Tuple2(12, 0),
  ActivityType.canoeing: Tuple2(paddlingSportId, 0), // Paddling
  ActivityType.crossfit: Tuple2(trainingSportId, 0), // Training
  ActivityType.eBikeRide: Tuple2(cyclingSportId, 28),
  ActivityType.elliptical: Tuple2(fitnessEquipmentSportId, 15), // Fitness Equipment, Elliptical
  ActivityType.golf: Tuple2(25, 0),
  ActivityType.handcycle: Tuple2(genericSportId, 12),
  ActivityType.hike: Tuple2(17, 3), // Hiking, Trail
  ActivityType.iceSkate: Tuple2(33, 0),
  "IndoorRowing": Tuple2(fitnessEquipmentSportId, 14),
  "IndoorRunning": Tuple2(runningSportId, 45),
  ActivityType.inlineSkate: Tuple2(30, 0),
  ActivityType.kayaking: Tuple2(41, 0),
  ActivityType.kitesurf: Tuple2(44, 0),
  ActivityType.nordicSki: Tuple2(12, 0), // Cross country skiing
  "OpenWaterSwim": Tuple2(swimmingSportId, 18),
  "Paddling": Tuple2(paddlingSportId, 0),
  ActivityType.ride: Tuple2(cyclingSportId, 0), // Cycling
  ActivityType.rockClimbing: Tuple2(48, 0), // Floor climbing
  ActivityType.rollerSki: Tuple2(genericSportId, 0),
  ActivityType.rowing: Tuple2(15, 0),
  ActivityType.run: Tuple2(runningSportId, 0),
  ActivityType.sail: Tuple2(32, 0),
  ActivityType.skateboard: Tuple2(genericSportId, 0),
  ActivityType.snowboard: Tuple2(14, 0),
  ActivityType.snowshoe: Tuple2(35, 0),
  ActivityType.soccer: Tuple2(7, 0),
  ActivityType.stairStepper: Tuple2(fitnessEquipmentSportId, 16),
  ActivityType.standUpPaddling: Tuple2(37, 0),
  ActivityType.surfing: Tuple2(38, 0),
  ActivityType.swim: Tuple2(swimmingSportId, 0),
  "Treadmill": Tuple2(runningSportId, 1), // Treadmill running
  "TrackRide": Tuple2(cyclingSportId, 13),
  "TrackRun": Tuple2(runningSportId, 4),
  ActivityType.velomobile: Tuple2(genericSportId, 0),
  ActivityType.virtualRide: Tuple2(cyclingSportId, 6), // Cycling, Indoor Cycling
  ActivityType.virtualRun: Tuple2(runningSportId, 1), // Treadmill running
  "VirtualRowing": Tuple2(paddlingSportId, 14), // Indoor Rowing
  ActivityType.walk: Tuple2(11, 0),
  ActivityType.weightTraining: Tuple2(trainingSportId, 0), // Training
  ActivityType.wheelchair: Tuple2(genericSportId, 0),
  ActivityType.windsurf: Tuple2(43, 0),
  ActivityType.workout: Tuple2(genericSportId, 0),
  ActivityType.yoga: Tuple2(trainingSportId, 43),
};

Tuple2 toFitSport(String sport) {
  if (sport == ActivityType.canoeing) {
    sport = ActivityType.kayaking;
  }

  if (!fitSport.containsKey(sport)) {
    sport = "Workout";
  }

  return fitSport[sport] ?? fitSport["Workout"]!;
}
