import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../devices/gadgets/life_fitness_mixin.dart';
import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/athlete.dart';
import '../device_fourcc.dart';
import 'stair_climber_device_descriptor.dart';

class LifeFitnessStairClimberDescriptor extends StairClimberDeviceDescriptor with LifeFitnessMixin {
  LifeFitnessStairClimberDescriptor()
      : super(
          fourCC: lifeFitnessStairClimberFourCC,
          vendorName: LifeFitnessMixin.lfManufacturer,
          modelName: "${LifeFitnessMixin.lfManufacturer} Stair Climber",
          manufacturerNamePart: LifeFitnessMixin.lfNamePrefix,
          manufacturerFitId: stravaFitId,
          model: "${LifeFitnessMixin.lfManufacturer} Stair Climber",
          doNotReadManufacturerName: true,
        );

  @override
  LifeFitnessStairClimberDescriptor clone() => LifeFitnessStairClimberDescriptor();

  @override
  Future<void> prePumpConfiguration(
      List<BluetoothService> svcs, Athlete athlete, int logLvl) async {
    await prePumpConfig(svcs, athlete, logLvl);
  }

  @override
  void stopWorkout() {
    return stopWorkoutExt();
  }
}
