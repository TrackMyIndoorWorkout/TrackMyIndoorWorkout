import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../devices/gadgets/life_fitness_mixin.dart';
import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/athlete.dart';
import '../device_fourcc.dart';
import 'treadmill_device_descriptor.dart';

class LifeFitnessTreadmillDescriptor extends TreadmillDeviceDescriptor with LifeFitnessMixin {
  LifeFitnessTreadmillDescriptor()
    : super(
        fourCC: lifeFitnessTreadmillFourCC,
        vendorName: LifeFitnessMixin.lfManufacturer,
        modelName: "${LifeFitnessMixin.lfManufacturer} Treadmill",
        manufacturerNamePart: LifeFitnessMixin.lfNamePrefix,
        manufacturerFitId: stravaFitId,
        model: "${LifeFitnessMixin.lfManufacturer} Treadmill",
        doNotReadManufacturerName: true,
      );

  @override
  LifeFitnessTreadmillDescriptor clone() => LifeFitnessTreadmillDescriptor();

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
