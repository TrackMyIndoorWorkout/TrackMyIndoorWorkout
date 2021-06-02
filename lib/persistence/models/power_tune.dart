import 'package:floor/floor.dart';
import 'package:meta/meta.dart';

const String POWER_TUNE_TABLE_NAME = 'power_tune';

@Entity(
  tableName: POWER_TUNE_TABLE_NAME,
  indices: [
    Index(value: ['mac'])
  ],
)
class PowerTune {
  @PrimaryKey(autoGenerate: true)
  int id;
  @required
  final String mac;
  @ColumnInfo(name: 'power_factor')
  double powerFactor;

  int time; // ms since epoch

  PowerTune({
    this.id,
    this.mac,
    this.powerFactor,
    this.time,
  })  : assert(mac != null),
        assert(powerFactor != null) {
    if (time == null) {
      time = DateTime.now().millisecondsSinceEpoch;
    }
  }

  DateTime get timeStamp => DateTime.fromMillisecondsSinceEpoch(time);
}
