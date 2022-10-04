import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/cycling_power_meter_sensor.dart';
import 'cycling_sensor_descriptor.dart';

class CyclingPowerMeterDescriptor extends CyclingSensorDescriptor {
  static const tag = "Cycling Power Meter Device";
  static const serviceUuid = CyclingPowerMeterSensor.serviceUuid;
  static const characteristicUuid = CyclingPowerMeterSensor.characteristicUuid;

  CyclingPowerMeterDescriptor({
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
        );

  @override
  CyclingPowerMeterDescriptor clone() => CyclingPowerMeterDescriptor(
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
    return CyclingPowerMeterSensor(device);
  }
}
