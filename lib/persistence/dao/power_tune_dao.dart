import 'package:floor/floor.dart';
import '../models/power_tune.dart';

@dao
abstract class PowerTuneDao {
  @Query('SELECT * FROM `$POWER_TUNE_TABLE_NAME` ORDER BY `time` DESC')
  Future<List<PowerTune>> findAllPowerTunes();

  @Query('SELECT * FROM `$POWER_TUNE_TABLE_NAME` WHERE `id` = :id')
  Stream<PowerTune?> findPowerTuneById(int id);

  @Query('SELECT * FROM `$POWER_TUNE_TABLE_NAME` WHERE `mac` = :mac ORDER BY `time` DESC LIMIT 1')
  Stream<PowerTune?> findPowerTuneByMac(String mac);

  @Query('SELECT * FROM `$POWER_TUNE_TABLE_NAME` ORDER BY `time` DESC LIMIT :limit OFFSET :offset')
  Future<List<PowerTune>> findPowerTunes(int limit, int offset);

  @insert
  Future<int> insertPowerTune(PowerTune powerTune);

  @update
  Future<int> updatePowerTune(PowerTune powerTune);

  @delete
  Future<int> deletePowerTune(PowerTune powerTune);
}
