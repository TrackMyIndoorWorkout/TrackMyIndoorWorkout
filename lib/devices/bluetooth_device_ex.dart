import 'package:collection/collection.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../utils/guid_ex.dart';

extension BluetoothDeviceEx on BluetoothDevice {
  static BluetoothService? filterService(List<BluetoothService> services, String identifier) {
    return services.firstWhereOrNull((service) => service.uuid.uuidString() == identifier);
  }

  static BluetoothCharacteristic? filterCharacteristic(
      List<BluetoothCharacteristic>? characteristics, String identifier) {
    return characteristics?.firstWhereOrNull((ch) => ch.uuid.uuidString() == identifier);
  }
}
