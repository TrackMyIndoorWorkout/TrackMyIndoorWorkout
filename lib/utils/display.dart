import 'package:flutter/material.dart';

import '../persistence/preferences_spec.dart';
import 'constants.dart';

double speedByUnitCore(double speed, bool si) {
  return si ? speed : speed * KM2MI;
}

double speedOrPace(double speed, bool si, String sport) {
  if (sport == ActivityType.Ride) {
    if (si) return speed;

    return speed * KM2MI;
  } else {
    if (speed.abs() < DISPLAY_EPS) return 0.0;

    if (sport == ActivityType.Run) {
      final pace = 60.0 / speed;

      if (si) return pace;

      return pace / KM2MI; // mph is lower than kmh but pace is reciprocal
    } else if (sport == ActivityType.Kayaking ||
        sport == ActivityType.Canoeing ||
        sport == ActivityType.Rowing) {
      return 30.0 / speed;
    } else if (sport == ActivityType.Swim) {
      return 6.0 / speed;
    }
    return speed;
  }
}

String speedOrPaceString(double speed, bool si, String sport, {limitSlowSpeed = false}) {
  final spd = speedOrPace(speed, si, sport);
  if (sport == ActivityType.Ride) {
    return spd.toStringAsFixed(2);
  } else if (sport == ActivityType.Run ||
      sport == ActivityType.Kayaking ||
      sport == ActivityType.Canoeing ||
      sport == ActivityType.Rowing ||
      sport == ActivityType.Swim ||
      sport == ActivityType.Elliptical) {
    if (speed.abs() < DISPLAY_EPS) return "0:00";

    if (limitSlowSpeed) {
      final slowSpeed = PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(sport)]!;
      if (speed < slowSpeed) {
        return "0:00";
      }
    }

    var pace = 60.0 / speed;
    if (sport == ActivityType.Kayaking ||
        sport == ActivityType.Canoeing ||
        sport == ActivityType.Rowing) {
      pace /= 2.0;
    } else if (sport == ActivityType.Swim) {
      pace /= 10.0;
    } else if (!si) {
      pace /= KM2MI;
    }
    return paceString(pace);
  }
  return spd.toStringAsFixed(2);
}

String paceString(double pace) {
  final minutes = pace.truncate();
  final seconds = ((pace - minutes) * 60.0).truncate();
  return "$minutes:" + seconds.toString().padLeft(2, "0");
}

String tcxSport(String sport) {
  return sport == ActivityType.Ride || sport == ActivityType.Run ? sport : "Other";
}

String getSpeedUnit(bool si, String sport) {
  if (sport == ActivityType.Ride) {
    return si ? 'kmh' : 'mph';
  } else if (sport == ActivityType.Run) {
    return si ? 'min /km' : 'min /mi';
  } else if (sport == ActivityType.Kayaking ||
      sport == ActivityType.Canoeing ||
      sport == ActivityType.Rowing) {
    return 'min /500';
  } else if (sport == ActivityType.Swim) {
    return 'min /100';
  }
  return si ? 'kmh' : 'mph';
}

String speedTitle(String sport) {
  return sport == ActivityType.Ride ? "Speed" : "Pace";
}

IconData getIcon(String? sport) {
  if (sport == ActivityType.Ride) {
    return Icons.directions_bike;
  } else if (sport == ActivityType.Run) {
    return Icons.directions_run;
  } else if (sport == ActivityType.Kayaking ||
      sport == ActivityType.Canoeing ||
      sport == ActivityType.Rowing) {
    return Icons.rowing;
  } else if (sport == ActivityType.Swim) {
    return Icons.waves;
  }
  return Icons.directions_bike;
}

String getCadenceUnit(String sport) {
  if (sport == ActivityType.Kayaking ||
      sport == ActivityType.Canoeing ||
      sport == ActivityType.Rowing ||
      sport == ActivityType.Swim) {
    return "spm";
  }
  return "rpm";
}

String distanceString(double distance, bool si) {
  if (si) return distance.toStringAsFixed(0);

  return '${(distance * M2MILE).toStringAsFixed(2)}';
}

String distanceByUnit(double distance, bool si) {
  final distanceStr = distanceString(distance, si);
  return '$distanceStr ${si ? "m" : "mi"}';
}
