import '../utils/constants.dart';

enum TrackKind {
  forRun,
  forRide,
  forLand,
  forWater,
  forDisplay,
}

Map<String, List<TrackKind>> trackKindSportMap = {
  ActivityType.ride: [TrackKind.forRide, TrackKind.forLand],
  ActivityType.virtualRide: [TrackKind.forRide, TrackKind.forLand],
  ActivityType.run: [TrackKind.forRun, TrackKind.forLand],
  ActivityType.virtualRun: [TrackKind.forRun, TrackKind.forLand],
  ActivityType.elliptical: [TrackKind.forRun, TrackKind.forLand],
  ActivityType.stairStepper: [TrackKind.forRun, TrackKind.forLand],
  ActivityType.kayaking: [TrackKind.forWater],
  ActivityType.canoeing: [TrackKind.forWater],
  ActivityType.rowing: [TrackKind.forWater],
  ActivityType.swim: [TrackKind.forWater],
};

List<TrackKind> getTrackKindForSport(String sport) {
  if (trackKindSportMap.containsKey(sport)) {
    return trackKindSportMap[sport]!;
  }

  return [TrackKind.forLand];
}
