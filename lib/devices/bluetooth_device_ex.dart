import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../utils/guid_ex.dart';

extension BluetoothDeviceEx on BluetoothDevice {
  static BluetoothService? filterService(List<BluetoothService> services, String identifier) {
    return services.firstWhereOrNull((service) => service.uuid.uuidString() == identifier);
  }

  static BluetoothCharacteristic? filterCharacteristic(
      List<BluetoothCharacteristic>? characteristics, String identifier) {
    return characteristics?.firstWhereOrNull((ch) => ch.uuid.uuidString() == identifier);
  }

  String get nonEmptyName => name.isNotEmpty ? name : unnamedDevice;
}
