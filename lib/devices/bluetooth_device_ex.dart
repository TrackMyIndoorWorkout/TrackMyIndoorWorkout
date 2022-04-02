import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import '../persistence/database.dart';
import '../utils/guid_ex.dart';

extension BluetoothDeviceEx on BluetoothDevice {
  static BluetoothService? filterService(
      List<BluetoothService> services, identifier) {
    return services
        .firstWhereOrNull((service) => service.uuid.uuidString() == identifier);
  }

  static BluetoothCharacteristic? filterCharacteristic(
      List<BluetoothCharacteristic>? characteristics, identifier) {
    return characteristics
        ?.firstWhereOrNull((ch) => ch.uuid.uuidString() == identifier);
  }

  Future<Tuple3<double, double, double>> getFactors(
      AppDatabase? database) async {
    database ??= Get.find<AppDatabase>();
    return await database.getFactors(id.id);
  }
}
