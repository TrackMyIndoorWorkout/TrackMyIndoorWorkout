import 'package:isar/isar.dart';

part 'device_usage.g.dart';

@Collection(inheritance: false)
class DeviceUsage {
  Id id;
  String sport;
  @Index()
  final String mac;
  @Index()
  final String name;
  final String manufacturer;
  String? manufacturerName;
  @Index()
  DateTime time;

  DeviceUsage({
    this.id = Isar.autoIncrement,
    required this.sport,
    required this.mac,
    required this.name,
    required this.manufacturer,
    this.manufacturerName,
    required this.time,
  });
}
