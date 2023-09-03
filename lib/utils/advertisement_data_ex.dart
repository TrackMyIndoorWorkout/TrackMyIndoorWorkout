import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'string_ex.dart';

extension AdvertisementDataEx on AdvertisementData {
  List<String> get uuids =>
      serviceUuids.isEmpty ? [] : serviceUuids.map((x) => x.uuidString()).toList(growable: false);
}
