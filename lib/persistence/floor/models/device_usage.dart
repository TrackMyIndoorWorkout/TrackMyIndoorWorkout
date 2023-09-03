import 'package:floor/floor.dart';

const deviceUsageTableName = 'device_usage';

@Entity(
  tableName: deviceUsageTableName,
  indices: [
    Index(value: ['time']),
    Index(value: ['mac']),
  ],
)
class DeviceUsage {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String sport;
  final String mac;
  final String name;
  final String manufacturer;

  @ColumnInfo(name: 'manufacturer_name')
  String? manufacturerName;

  int time; // ms since epoch

  DeviceUsage({
    this.id,
    required this.sport,
    required this.mac,
    required this.name,
    required this.manufacturer,
    this.manufacturerName,
    required this.time,
  });

  DateTime get timeStamp => DateTime.fromMillisecondsSinceEpoch(time);
}
