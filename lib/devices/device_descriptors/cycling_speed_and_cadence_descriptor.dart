import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/cycling_speed_and_cadence_sensor.dart';
import 'cycling_sensor_descriptor.dart';
import 'device_descriptor.dart';

class CyclingSpeedAndCadenceDescriptor extends CyclingSensorDescriptor {
  CyclingSpeedAndCadenceDescriptor({
    required fourCC,
    required vendorName,
    required modelName,
    manufacturerNamePart,
    manufacturerFitId,
    model,
  }) : super(
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          manufacturerNamePart: manufacturerNamePart,
          manufacturerFitId: manufacturerFitId,
          model: model,
          deviceCategory: DeviceCategory.secondarySensor,
          flagByteSize: 1,
          tag: "CSC_SENSOR",
          serviceUuid: CyclingSpeedAndCadenceSensor.serviceUuid,
          characteristicUuid: CyclingSpeedAndCadenceSensor.characteristicUuid,
        );

  @override
  CyclingSpeedAndCadenceDescriptor clone() => CyclingSpeedAndCadenceDescriptor(
        fourCC: fourCC,
        vendorName: vendorName,
        modelName: modelName,
        manufacturerNamePart: manufacturerNamePart,
        manufacturerFitId: manufacturerFitId,
        model: model,
      )..sensor = sensor;

  @override
  ComplexSensor? getSensor(BluetoothDevice device) {
    return CyclingSpeedAndCadenceSensor(device);
  }
}
