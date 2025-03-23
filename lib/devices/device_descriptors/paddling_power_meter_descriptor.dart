import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../utils/constants.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/cycling_power_meter_sensor.dart';
import '../gadgets/paddling_power_meter_sensor.dart';
import 'cycling_sensor_descriptor.dart';
import 'device_descriptor.dart';

class PaddlingPowerMeterDescriptor extends CyclingSensorDescriptor {
  PaddlingPowerMeterDescriptor({
    required super.fourCC,
    required super.vendorName,
    required super.modelName,
    required super.manufacturerNamePart,
    required super.manufacturerFitId,
    required super.model,
  }) : super(
         deviceCategory: DeviceCategory.secondarySensor,
         tag: "Paddling Power Meter Device",
         serviceUuid: CyclingPowerMeterSensor.serviceUuid,
         characteristicUuid: CyclingPowerMeterSensor.characteristicUuid,
         flagByteSize: 1,
       ) {
    sport = ActivityType.kayaking;
  }

  @override
  PaddlingPowerMeterDescriptor clone() => PaddlingPowerMeterDescriptor(
    fourCC: fourCC,
    vendorName: vendorName,
    modelName: modelName,
    manufacturerNamePart: manufacturerNamePart,
    manufacturerFitId: manufacturerFitId,
    model: model,
  )..sensor = sensor;

  @override
  ComplexSensor? getSensor(BluetoothDevice device) {
    return PaddlingPowerMeterSensor(device);
  }
}
