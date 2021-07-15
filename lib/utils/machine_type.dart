enum MachineType {
  NotFitnessMachine,
  IndoorBike,
  Treadmill,
  Rower,
  CrossTrainer,
  StepClimber,
  StairClimber,
  HeartRateMonitor,
}

extension MachineTypeEx on MachineType {
  int get bit {
    switch (this) {
      case MachineType.IndoorBike:
        return 32;
      case MachineType.Treadmill:
        return 1;
      case MachineType.CrossTrainer:
        return 2;
      case MachineType.StepClimber:
        return 4;
      case MachineType.StairClimber:
        return 8;
      case MachineType.Rower:
        return 16;
      default:
        return 0;
    }
  }
}
