import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/cycling_speed_and_cadence_sensor.dart';
import 'cycling_sensor_descriptor.dart';

class CyclingSpeedAndCadenceDescriptor extends CyclingSensorDescriptor {
  static const tag = "Cycling Speed and Cadence Device";
  static const serviceUuid = CyclingSpeedAndCadenceSensor.serviceUuid;
  static const characteristicUuid = CyclingSpeedAndCadenceSensor.characteristicUuid;

  CyclingSpeedAndCadenceDescriptor({
    required fourCC,
    required vendorName,
    required modelName,
    required namePrefixes,
    manufacturerPrefix,
    manufacturerFitId,
    model,
  }) : super(
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          namePrefixes: namePrefixes,
          manufacturerPrefix: manufacturerPrefix,
          manufacturerFitId: manufacturerFitId,
          model: model,
          flagByteSize: 1,
        );

  @override
  CyclingSpeedAndCadenceDescriptor clone() => CyclingSpeedAndCadenceDescriptor(
        fourCC: fourCC,
        vendorName: vendorName,
        modelName: modelName,
        namePrefixes: namePrefixes,
        manufacturerPrefix: manufacturerPrefix,
        manufacturerFitId: manufacturerFitId,
        model: model,
      )..sensor = sensor;

  @override
  ComplexSensor? getSensor(BluetoothDevice device) {
    return CyclingSpeedAndCadenceSensor(device);
  }
}
