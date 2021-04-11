import 'package:meta/meta.dart';

import '../../devices/gatt_constants.dart';

class AdvertisementDigest {
  final String id;
  final List<String> serviceUuids;
  final String manufacturer;
  final int txPower;

  AdvertisementDigest({
    @required this.id,
    @required this.serviceUuids,
    @required this.manufacturer,
    @required this.txPower,
  });

  bool isHeartRateMonitor() {
    return serviceUuids?.contains(HEART_RATE_SERVICE_ID) ?? false;
  }
}
