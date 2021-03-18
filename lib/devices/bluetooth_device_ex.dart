import 'package:flutter_blue/flutter_blue.dart';
import '../utils/guid_ex.dart';
import 'device_descriptors/device_descriptor.dart';
import 'device_map.dart';

extension BluetoothDeviceEx on BluetoothDevice {
  DeviceDescriptor getDescriptor(List<String> serviceUuids) {
    for (var dev in deviceMap.values) {
      if (name.startsWith(dev.namePrefix)) {
        return dev;
      }
    }

    // TODO: branch here based on FTMS data
    // TODO: Needs adding generic FTMS types #80
    // Default to FTMS Indoor Bike (Schwinn IC4/IC8)
    return deviceMap['SIC4'];
  }

  static BluetoothService filterService(List<BluetoothService> services, identifier) {
    return services?.firstWhere((service) => service.uuid.uuidString() == identifier,
        orElse: () => null);
  }

  static BluetoothCharacteristic filterCharacteristic(
      List<BluetoothCharacteristic> characteristics, identifier) {
    return characteristics?.firstWhere((ch) => ch.uuid.uuidString() == identifier,
        orElse: () => null);
  }
}
