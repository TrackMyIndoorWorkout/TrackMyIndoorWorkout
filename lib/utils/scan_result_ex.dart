import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

import '../devices/company_registry.dart';
import '../devices/device_map.dart';
import '../devices/gatt_constants.dart';
import 'advertisement_data_ex.dart';
import 'constants.dart';

extension ScanResultEx on ScanResult {
  bool isWorthy(bool filterDevices) {
    if (!advertisementData.connectable) {
      return false;
    }

    if (device.name == null || device.name.isEmpty) {
      return false;
    }

    if (device.id.id == null || device.id.id.isEmpty) {
      return false;
    }

    if (!filterDevices) {
      return true;
    }

    for (var dev in deviceMap.values) {
      if (device.name.startsWith(dev.namePrefix)) {
        return true;
      }
      if (advertisementData.serviceUuids.isNotEmpty) {
        final serviceUuids = advertisementData.uuids;
        if (serviceUuids.contains(FITNESS_MACHINE_ID) ||
            serviceUuids.contains(PRECOR_SERVICE_ID) ||
            serviceUuids.contains(HEART_RATE_SERVICE_ID)) {
          return true;
        }
      }
    }

    return false;
  }

  List<String> get serviceUuids => advertisementData.uuids;

  bool hasService(String serviceId) {
    return serviceUuids.contains(serviceId);
  }

  bool get isHeartRateMonitor => hasService(HEART_RATE_SERVICE_ID);

  String manufacturerName() {
    final companyRegistry = Get.find<CompanyRegistry>();

    final companyIds = advertisementData?.manufacturerData?.keys;
    if (companyIds.isEmpty) {
      return NOT_AVAILABLE;
    }

    List<String> nameStrings = [];
    companyIds.forEach((companyId) {
      nameStrings.add(companyRegistry.nameForId(companyId));
    });

    return nameStrings.join(', ');
  }
}
