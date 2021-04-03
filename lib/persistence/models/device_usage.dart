import 'package:floor/floor.dart';
import 'package:meta/meta.dart';

const String DEVICE_USAGE_TABLE_NAME = 'device_usage';

@Entity(
  tableName: DEVICE_USAGE_TABLE_NAME,
  indices: [
    Index(value: ['time']),
    Index(value: ['mac']),
  ],
)
class DeviceUsage {
  @PrimaryKey(autoGenerate: true)
  int id;
  @required
  String sport;
  @required
  final String mac;
  @required
  final String name;
  @required
  final String manufacturer;

  @ColumnInfo(name: 'manufacturer_name')
  String manufacturerName;

  int time; // ms since epoch

  DeviceUsage({
    this.id,
    this.sport,
    this.mac,
    this.name,
    this.manufacturer,
    this.manufacturerName,
    this.time,
  })  : assert(sport != null),
        assert(mac != null),
        assert(name != null),
        assert(manufacturer != null) {
    if (time == null) {
      time = DateTime.now().millisecondsSinceEpoch;
    }
  }

  DateTime get timeStamp => DateTime.fromMillisecondsSinceEpoch(time);
}
