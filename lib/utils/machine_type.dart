enum MachineType {
  notFitnessMachine,
  indoorBike,
  treadmill,
  rower,
  crossTrainer,
  stepClimber,
  stairClimber,
  heartRateMonitor,
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
}
