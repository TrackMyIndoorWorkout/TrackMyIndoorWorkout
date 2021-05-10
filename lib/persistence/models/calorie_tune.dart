import 'package:floor/floor.dart';
import 'package:meta/meta.dart';

const String CALORIE_TUNE_TABLE_NAME = 'calorie_tune';

@Entity(
  tableName: CALORIE_TUNE_TABLE_NAME,
  indices: [
    Index(value: ['mac'])
  ],
)
class CalorieTune {
  @PrimaryKey(autoGenerate: true)
  int id;
  @required
  final String mac;
  @ColumnInfo(name: 'calorie_factor')
  double calorieFactor;

  int time; // ms since epoch

  CalorieTune({
    this.id,
    this.mac,
    this.calorieFactor,
    this.time,
  })  : assert(mac != null),
        assert(calorieFactor != null) {
    if (time == null) {
      time = DateTime.now().millisecondsSinceEpoch;
    }
  }

  DateTime get timeStamp => DateTime.fromMillisecondsSinceEpoch(time);
}
