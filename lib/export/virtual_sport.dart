import '../utils/constants.dart';

/// Mapping and helpers for virtual sports support (#564).
///
/// Keeps [Activity.sport] canonical internally while projecting to virtual sports
/// during export and upload when enabled by user preferences or inline toggles.
class VirtualSport {
  /// Maps a canonical sport to its virtual sport equivalent.
  /// If the sport has no virtual counterpart, returns the original sport unchanged.
  static String getVirtualSport(String sport) {
    switch (sport) {
      case ActivityType.ride:
        return ActivityType.virtualRide;
      case ActivityType.run:
        return ActivityType.virtualRun;
      case ActivityType.rowing:
        return ActivityType.virtualRow;
      default:
        return sport;
    }
  }

  /// Whether the given [sport] has a supported virtual counterpart in the FIT SDK
  /// and target upload platforms (Cycling -> VirtualRide, Running -> VirtualRun, Rowing -> VirtualRow).
  static bool hasVirtualCounterpart(String sport) {
    return sport == ActivityType.ride || sport == ActivityType.run || sport == ActivityType.rowing;
  }

  /// Returns the effective sport for an export/upload given the [sport] and [virtualWorkout] flag.
  static String resolveSport(String sport, bool virtualWorkout) {
    if (virtualWorkout && hasVirtualCounterpart(sport)) {
      return getVirtualSport(sport);
    }
    return sport;
  }
}
