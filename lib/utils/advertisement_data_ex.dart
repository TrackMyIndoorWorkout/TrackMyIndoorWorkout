import 'package:flutter_blue/flutter_blue.dart';
import 'string_ex.dart';

extension AdvertisementDataEx on AdvertisementData {
  List<String> get uuids => serviceUuids.isEmpty ? [] : serviceUuids.map((x) => x.uuidString()).toList();
}
