import 'package:floor/floor.dart';
import '../models/power_tune.dart';

@dao
abstract class PowerTuneDao {
  @Query('SELECT * FROM `$powerTuneTableName` ORDER BY `id`')
  Future<List<PowerTune>> findAllPowerTunes();
}
