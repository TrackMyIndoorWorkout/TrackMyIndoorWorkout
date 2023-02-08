import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum MachineType {
  notFitnessMachine,
  indoorBike,
  treadmill,
  rower,
  crossTrainer,
  stepClimber,
  stairClimber,
  heartRateMonitor,
  multiFtms,
}

extension MachineTypeEx on MachineType {
  int get bit {
    switch (this) {
      case MachineType.indoorBike:
        return 32;
      case MachineType.treadmill:
        return 1;
      case MachineType.crossTrainer:
        return 2;
      case MachineType.stepClimber:
        return 4;
      case MachineType.stairClimber:
        return 8;
      case MachineType.rower:
        return 16;
      default:
        return 0;
    }
  }

  String get sport {
    switch (this) {
      case MachineType.indoorBike:
        return ActivityType.ride;
      case MachineType.treadmill:
        return ActivityType.run;
      case MachineType.crossTrainer:
        return ActivityType.elliptical;
      case MachineType.stepClimber:
        return ActivityType.run;
      case MachineType.stairClimber:
        return ActivityType.run;
      case MachineType.rower:
        return ActivityType.rowing;
      default:
        return "";
    }
  }

  IconData get icon {
    switch (this) {
      case MachineType.indoorBike:
        return Icons.directions_bike;
      case MachineType.treadmill:
        return Icons.directions_run;
      case MachineType.rower:
        return Icons.rowing;
      case MachineType.heartRateMonitor:
        return Icons.favorite;
      case MachineType.crossTrainer:
        return Icons.downhill_skiing;
      case MachineType.stepClimber:
        return Icons.stairs;
      case MachineType.stairClimber:
        return Icons.stairs;
      default:
        return Icons.help;
    }
  }

  bool get isSpecificFtms {
    return [
      MachineType.indoorBike,
      MachineType.treadmill,
      MachineType.rower,
      MachineType.crossTrainer,
      MachineType.stepClimber,
      MachineType.stairClimber,
    ].contains(this);
  }

  static int getMachineByteFlag(String sport) {
    switch (sport) {
      case ActivityType.ride:
        return MachineType.indoorBike.bit;
      case ActivityType.run:
        return MachineType.treadmill.bit;
      case ActivityType.elliptical:
        return MachineType.crossTrainer.bit;
      case ActivityType.rowing:
        return MachineType.rower.bit;
      case ActivityType.kayaking:
        return MachineType.rower.bit;
      case ActivityType.canoeing:
        return MachineType.rower.bit;
      case ActivityType.swim:
        return MachineType.rower.bit;
      default:
        return MachineType.notFitnessMachine.bit;
    }
  }
}
