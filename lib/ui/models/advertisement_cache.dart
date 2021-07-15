import 'package:flutter_blue/flutter_blue.dart';

import '../../utils/scan_result_ex.dart';
import 'advertisement_digest.dart';

class AdvertisementCache {
  Map<String, AdvertisementDigest> _advertisementMap = Map<String, AdvertisementDigest>();

  void addEntry(ScanResult scanResult) {
    final id = scanResult.device.id.id;
    _advertisementMap[id] = AdvertisementDigest(
      id: id,
      serviceUuids: scanResult.serviceUuids,
      manufacturer: scanResult.manufacturerName(),
      txPower: scanResult.advertisementData.txPowerLevel ?? -120,
      machineType: scanResult.getMachineType(),
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
