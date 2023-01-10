import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/cycling_power_meter_sensor.dart';
import 'cycling_sensor_descriptor.dart';
import 'device_descriptor.dart';

class CyclingPowerMeterDescriptor extends CyclingSensorDescriptor {
  CyclingPowerMeterDescriptor({
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
          deviceCategory: DeviceCategory.primarySensor,
          tag: "Cycling Power Meter Device",
          serviceUuid: CyclingPowerMeterSensor.serviceUuid,
          characteristicUuid: CyclingPowerMeterSensor.characteristicUuid,
        );

  @override
  CyclingPowerMeterDescriptor clone() => CyclingPowerMeterDescriptor(
        fourCC: fourCC,
        vendorName: vendorName,
        modelName: modelName,
        manufacturerNamePart: manufacturerNamePart,
        manufacturerFitId: manufacturerFitId,
        model: model,
      )..sensor = sensor;

  @override
  ComplexSensor? getSensor(BluetoothDevice device) {
    return CyclingPowerMeterSensor(device);
  }
}
