import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../devices/gadgets/life_fitness_mixin.dart';
import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/athlete.dart';
import '../device_fourcc.dart';
import 'step_climber_device_descriptor.dart';

class LifeFitnessStepClimberDescriptor extends StepClimberDeviceDescriptor with LifeFitnessMixin {
  LifeFitnessStepClimberDescriptor()
    : super(
        fourCC: lifeFitnessStepClimberFourCC,
        vendorName: LifeFitnessMixin.lfManufacturer,
        modelName: "${LifeFitnessMixin.lfManufacturer} Step Climber",
        manufacturerNamePart: LifeFitnessMixin.lfNamePrefix,
        manufacturerFitId: stravaFitId,
        model: "${LifeFitnessMixin.lfManufacturer} Step Climber",
        doNotReadManufacturerName: true,
      );

  @override
  LifeFitnessStepClimberDescriptor clone() => LifeFitnessStepClimberDescriptor();

  @override
  Future<void> prePumpConfiguration(
    List<BluetoothService> svcs,
    Athlete athlete,
    int logLvl,
  ) async {
    await prePumpConfig(svcs, athlete, logLvl);
  }

  @override
  void stopWorkout() {
    return stopWorkoutExt();
  }
}
