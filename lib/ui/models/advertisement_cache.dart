import 'package:flutter_blue/flutter_blue.dart';

import '../../devices/gatt_constants.dart';
import '../../utils/scan_result_ex.dart';
import '../../utils/string_ex.dart';
import 'advertisement_digest.dart';
import 'machine_type.dart';

class AdvertisementCache {
  Map<String, AdvertisementDigest> _advertisementMap = Map<String, AdvertisementDigest>();

  void addEntry(ScanResult scanResult) {
    final id = scanResult.device.id.id;
    _advertisementMap[id] = AdvertisementDigest(
      id: id,
      serviceUuids: scanResult.serviceUuids,
      manufacturer: scanResult.manufacturerName(),
      txPower: scanResult.advertisementData.txPowerLevel ?? -120,
      machineType: getMachineType(scanResult),
    );
  }

  MachineType getMachineType(ScanResult scanResult) {
    if (!scanResult.serviceUuids.contains(FITNESS_MACHINE_ID)) {
      return MachineType.NotFitnessMachine;
    }

    for (MapEntry<String, List<int>> entry in scanResult.advertisementData.serviceData.entries) {
      if (entry.key.uuidString() == FITNESS_MACHINE_ID) {
        final serviceData = entry.value;
        if (serviceData.length > 2 && serviceData[0] >= 1) {
          for (final machineType in MachineType.values) {
            if (serviceData[1] & machineType.bit >= 1) {
              return machineType;
            }
          }
        }
      }
    }

    return MachineType.NotFitnessMachine;
  }

  bool hasEntry(String id) {
    return _advertisementMap.containsKey(id);
  }

  bool hasAnyEntry(List<String> ids) {
    return ids.fold<bool>(false, (a, b) => a || _advertisementMap.containsKey(b));
  }

  AdvertisementDigest? getEntry(String id) {
    return _advertisementMap[id];
  }
}
