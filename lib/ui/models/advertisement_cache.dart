import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../utils/scan_result_ex.dart';
import 'advertisement_digest.dart';

class AdvertisementCache {
  final Map<String, AdvertisementDigest> _advertisementMap = {};

  void addEntry(ScanResult scanResult) {
    final id = scanResult.device.id.id;
    final machineByteFlag = scanResult.getFtmsServiceDataMachineByte();
    final machineTypes = scanResult.getFtmsServiceDataMachineTypes(machineByteFlag);
    _advertisementMap[id] = AdvertisementDigest(
      id: id,
      serviceUuids: scanResult.serviceUuids,
      companyIds: scanResult.advertisementData.manufacturerData.keys.toList(growable: false),
      manufacturer: scanResult.manufacturerName(),
      txPower: scanResult.advertisementData.txPowerLevel ?? -120,
      machineTypesByte: machineByteFlag,
      machineType: scanResult.getMachineType(machineTypes),
      machineTypes: machineTypes,
    );
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
