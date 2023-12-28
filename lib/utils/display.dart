import 'package:flutter/material.dart';
import '../preferences/speed_spec.dart';
import '../preferences/sport_spec.dart';
import 'constants.dart';

extension DurationDisplay on Duration {
  String toDisplay() {
    return toString().split('.').first.padLeft(8, "0");
  }
}

double speedByUnitCore(double speed, bool si) {
  return si ? speed : speed * km2mi;
}

double speedOrPace(double speed, bool si, String sport) {
  if (sport == ActivityType.ride) {
    if (si) return speed;

    return speed * km2mi;
  } else {
    if (speed.abs() < displayEps) return 0.0;

    if (sport == ActivityType.run || sport == ActivityType.elliptical) {
      final pace = 60.0 / speed;

      if (si) return pace;

      return pace / km2mi; // mph is lower than kmh but pace is reciprocal
    } else if (sport == ActivityType.kayaking ||
        sport == ActivityType.canoeing ||
        sport == ActivityType.rowing ||
        sport == ActivityType.nordicSki) {
      return 30.0 / speed;
    } else if (sport == ActivityType.swim) {
      return 6.0 / speed;
    }
    return speed;
  }
}

String speedOrPaceString(double speed, bool si, String sport, {limitSlowSpeed = false}) {
  final spd = speedOrPace(speed, si, sport);
  if (sport == ActivityType.ride) {
    return spd.toStringAsFixed(2);
  } else if (sport == ActivityType.run ||
      sport == ActivityType.kayaking ||
      sport == ActivityType.canoeing ||
      sport == ActivityType.rowing ||
      sport == ActivityType.swim ||
      sport == ActivityType.elliptical ||
      sport == ActivityType.nordicSki) {
    if (speed.abs() < displayEps) return "0:00";

    if (limitSlowSpeed) {
      final slowSpeed = SpeedSpec.slowSpeeds[SportSpec.sport2Sport(sport)]!;
      if (speed < slowSpeed) {
        return "0:00";
      }
    }

    var pace = 60.0 / speed;
    if (sport == ActivityType.kayaking ||
        sport == ActivityType.canoeing ||
        sport == ActivityType.rowing ||
        sport == ActivityType.nordicSki) {
      pace /= 2.0;
    } else if (sport == ActivityType.swim) {
      pace /= 10.0;
    } else if (!si) {
      pace /= km2mi;
    }
    return paceString(pace);
  }
  return spd.toStringAsFixed(2);
}

String paceString(double pace) {
  final minutes = pace.truncate();
  final seconds = ((pace - minutes) * 60.0).truncate();
  return "$minutes:${seconds.toString().padLeft(2, "0")}";
}

String getSpeedUnit(bool si, String sport) {
  if (sport == ActivityType.ride) {
    return si ? 'kmh' : 'mph';
  } else if (sport == ActivityType.run || sport == ActivityType.elliptical) {
    return si ? 'min /km' : 'min /mi';
  } else if (sport == ActivityType.kayaking ||
      sport == ActivityType.canoeing ||
      sport == ActivityType.rowing ||
      sport == ActivityType.nordicSki) {
    return 'min /500';
  } else if (sport == ActivityType.swim) {
    return 'min /100';
  }
  return si ? 'kmh' : 'mph';
}

String speedTitle(String sport) {
  return sport == ActivityType.ride ? "Speed" : "Pace";
}

IconData getSportIcon(String sport) {
  if (sport == ActivityType.ride) {
    return Icons.directions_bike;
  } else if (sport == ActivityType.run) {
    return Icons.directions_run;
  } else if (sport == ActivityType.kayaking) {
    return Icons.kayaking;
  } else if (sport == ActivityType.canoeing || sport == ActivityType.rowing) {
    return Icons.rowing;
  } else if (sport == ActivityType.swim) {
    return Icons.waves;
  } else if (sport == ActivityType.elliptical || sport == ActivityType.nordicSki) {
    return Icons.downhill_skiing;
  } else if (sport == ActivityType.stairStepper) {
    return Icons.stairs;
  }

  return Icons.help;
}

String getCadenceUnit(String sport) {
  if (sport == ActivityType.kayaking ||
      sport == ActivityType.canoeing ||
      sport == ActivityType.rowing ||
      sport == ActivityType.swim ||
      sport == ActivityType.elliptical ||
      sport == ActivityType.nordicSki) {
    return "spm";
  }
  return "rpm";
}

String distanceString(double distance, bool si, bool highRes) {
  if (si) {
    if (highRes) {
      return distance.toStringAsFixed(0);
    } else {
      return (distance / 1000).toStringAsFixed(2);
    }
  }

  if (highRes) {
    return (distance * m2yard).toStringAsFixed(0);
  } else {
    return (distance * m2mile).toStringAsFixed(2);
  }
}

String distanceUnit(bool si, bool highRes) {
  if (si) {
    return highRes ? "m" : "km";
  } else {
    return highRes ? "yd" : "mi";
  }
}

String distanceByUnit(double distance, bool si, bool highRes, {bool autoRes = false}) {
  if (autoRes) {
    final hiResThresholdDistance = si ? 999 : thousandYardsInMeters - 1;
    highRes = distance < hiResThresholdDistance;
  }
  final distanceStr = distanceString(distance, si, highRes);
  final unitStr = distanceUnit(si, highRes);
  return '$distanceStr $unitStr';
}
