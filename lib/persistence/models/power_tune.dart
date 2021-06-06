import 'package:floor/floor.dart';

const String POWER_TUNE_TABLE_NAME = 'power_tune';

@Entity(
  tableName: POWER_TUNE_TABLE_NAME,
  indices: [
    Index(value: ['mac'])
  ],
)
class PowerTune {
  @PrimaryKey(autoGenerate: true)
  int? id;
  final String mac;
  @ColumnInfo(name: 'power_factor')
  double powerFactor;

  late int time; // ms since epoch

  PowerTune({
    this.id,
    required this.mac,
    required this.powerFactor,
    required this.time,
  });

  DateTime get timeStamp => DateTime.fromMillisecondsSinceEpoch(time);
}
