import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import '../utils/address_names.dart';
import '../utils/guid_ex.dart';

extension BluetoothDeviceEx on BluetoothDevice {
  static BluetoothService? filterService(List<BluetoothService> services, String identifier) {
    return services.firstWhereOrNull((service) => service.serviceUuid.uuidString() == identifier);
  }

  static BluetoothCharacteristic? filterCharacteristic(
    List<BluetoothCharacteristic>? characteristics,
    String identifier,
  ) {
    return characteristics?.firstWhereOrNull(
      (ch) => ch.characteristicUuid.uuidString() == identifier,
    );
  }

  String get nonEmptyName => platformName.isNotEmpty
      ? platformName
      : Get.find<AddressNames>().getAddressName(remoteId.str, platformName);
}
