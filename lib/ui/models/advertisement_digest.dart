import '../../devices/gatt_constants.dart';

class AdvertisementDigest {
  String id;
  List<String> serviceUuids;
  String manufacturer;

  AdvertisementDigest({this.id, this.serviceUuids, this.manufacturer});

  bool isHeartRateMonitor() {
    return serviceUuids?.contains(HEART_RATE_SERVICE_ID) ?? false;
  }
}
