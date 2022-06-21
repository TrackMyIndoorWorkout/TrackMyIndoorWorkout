import 'package:floor/floor.dart';

const calorieTuneTableName = 'calorie_tune';

@Entity(
  tableName: calorieTuneTableName,
  indices: [
    Index(value: ['mac'])
  ],
)
class CalorieTune {
  @PrimaryKey(autoGenerate: true)
  int? id;
  final String mac;
  @ColumnInfo(name: 'calorie_factor')
  double calorieFactor;
  @ColumnInfo(name: 'hr_based')
  bool hrBased;

  int time; // ms since epoch

  CalorieTune({
    this.id,
    required this.mac,
    required this.calorieFactor,
    required this.hrBased,
    required this.time,
  });

  DateTime get timeStamp => DateTime.fromMillisecondsSinceEpoch(time);
}
