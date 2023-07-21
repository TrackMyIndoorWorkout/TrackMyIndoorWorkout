import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import '../persistence/database.dart';
import '../utils/address_names.dart';
import '../utils/guid_ex.dart';

extension BluetoothDeviceEx on BluetoothDevice {
  static BluetoothService? filterService(List<BluetoothService> services, String identifier) {
    return services.firstWhereOrNull((service) => service.serviceUuid.uuidString() == identifier);
  }

  static BluetoothCharacteristic? filterCharacteristic(
      List<BluetoothCharacteristic>? characteristics, String identifier) {
    return characteristics
        ?.firstWhereOrNull((ch) => ch.characteristicUuid.uuidString() == identifier);
  }

  Future<Tuple3<double, double, double>> getFactors(AppDatabase? database) async {
    database ??= Get.find<AppDatabase>();
    return await database.getFactors(remoteId.str);
  }

  String get nonEmptyName => localName.isNotEmpty
      ? localName
      : Get.find<AddressNames>().getAddressName(localName, remoteId.str);
}
