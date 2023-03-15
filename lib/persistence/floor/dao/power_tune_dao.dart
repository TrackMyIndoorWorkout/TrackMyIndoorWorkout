import 'package:floor/floor.dart';
import '../models/power_tune.dart';

@dao
abstract class PowerTuneDao {
  @Query('SELECT * FROM `$powerTuneTableName` ORDER BY `time` DESC')
  Future<List<PowerTune>> findAllPowerTunes();

  @Query('SELECT COUNT(`id`) FROM `$powerTuneTableName`')
  Future<int?> getPowerTuneCount();
}
