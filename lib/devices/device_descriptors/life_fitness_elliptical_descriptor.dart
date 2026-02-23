import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../devices/gadgets/life_fitness_mixin.dart';
import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/athlete.dart';
import '../device_fourcc.dart';
import 'cross_trainer_device_descriptor.dart';

class LifeFitnessEllipticalDescriptor extends CrossTrainerDeviceDescriptor with LifeFitnessMixin {
  LifeFitnessEllipticalDescriptor()
    : super(
        fourCC: lifeFitnessEllipticalFourCC,
        vendorName: lifeFitnessManufacturerNamePrefix,
        modelName: "$lifeFitnessManufacturerNamePrefix Elliptical",
        manufacturerNamePart: lifeFitnessDeviceNamePrefix,
        manufacturerFitId: stravaFitId,
        model: "$lifeFitnessManufacturerNamePrefix Elliptical",
        doNotReadManufacturerName: true,
      );

  @override
  LifeFitnessEllipticalDescriptor clone() => LifeFitnessEllipticalDescriptor();

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
