import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../devices/gadgets/life_fitness_mixin.dart';
import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/athlete.dart';
import '../device_fourcc.dart';
import 'indoor_bike_device_descriptor.dart';

class LifeFitnessBikeDescriptor extends IndoorBikeDeviceDescriptor with LifeFitnessMixin {
  LifeFitnessBikeDescriptor()
      : super(
          fourCC: lifeFitnessBikeFourCC,
          vendorName: LifeFitnessMixin.lfManufacturer,
          modelName: "${LifeFitnessMixin.lfManufacturer} Bike",
          manufacturerNamePart: LifeFitnessMixin.lfNamePrefix,
          manufacturerFitId: stravaFitId,
          model: "${LifeFitnessMixin.lfManufacturer} Bike",
        );

  @override
  LifeFitnessBikeDescriptor clone() => LifeFitnessBikeDescriptor();

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
