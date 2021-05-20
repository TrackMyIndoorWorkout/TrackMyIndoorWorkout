import 'package:flutter_blue/flutter_blue.dart';
import '../utils/guid_ex.dart';

extension BluetoothDeviceEx on BluetoothDevice {
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
