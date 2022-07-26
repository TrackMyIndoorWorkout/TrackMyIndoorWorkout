import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../device_fourcc.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/running_cadence_sensor.dart';
import 'treadmill_device_descriptor.dart';

class NpeRunnTreadmill extends TreadmillDeviceDescriptor {
  NpeRunnTreadmill()
      : super(
          fourCC: npeRunnFourCC,
          vendorName: "North Pole Engineering Inc.",
          modelName: "Generic Treadmill",
          namePrefixes: ["RUNN"],
          manufacturerPrefix: "North Pole Engineering",
          manufacturerFitId: northPoleEngineeringFitId,
          model: "77",
        );

  @override
  NpeRunnTreadmill clone() => NpeRunnTreadmill();

  @override
  ComplexSensor? getExtraSensor(BluetoothDevice device) {
    return RunningCadenceSensor(device);
  }
}
