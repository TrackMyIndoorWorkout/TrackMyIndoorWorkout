import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../utils/constants.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/cycling_speed_and_cadence_sensor.dart';
import '../gadgets/paddling_speed_and_cadence_sensor.dart';
import 'cycling_sensor_descriptor.dart';
import 'device_descriptor.dart';

class PaddlingSpeedAndCadenceDescriptor extends CyclingSensorDescriptor {
  PaddlingSpeedAndCadenceDescriptor({
    required super.fourCC,
    required super.vendorName,
    required super.modelName,
    required super.manufacturerNamePart,
    required super.manufacturerFitId,
    required super.model,
  }) : super(
          deviceCategory: DeviceCategory.secondarySensor,
          tag: "Paddling Speed and Cadence Device",
          serviceUuid: CyclingSpeedAndCadenceSensor.serviceUuid,
          characteristicUuid: CyclingSpeedAndCadenceSensor.characteristicUuid,
          flagByteSize: 1,
        ) {
    sport = ActivityType.kayaking;
  }

  @override
  PaddlingSpeedAndCadenceDescriptor clone() => PaddlingSpeedAndCadenceDescriptor(
        fourCC: fourCC,
        vendorName: vendorName,
        modelName: modelName,
        manufacturerNamePart: manufacturerNamePart,
        manufacturerFitId: manufacturerFitId,
        model: model,
      )..sensor = sensor;

  @override
  ComplexSensor? getSensor(BluetoothDevice device) {
    return PaddlingSpeedAndCadenceSensor(device);
  }
}
