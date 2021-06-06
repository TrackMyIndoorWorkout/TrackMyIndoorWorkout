import 'package:floor/floor.dart';
import '../models/calorie_tune.dart';

@dao
abstract class CalorieTuneDao {
  @Query('SELECT * FROM `$CALORIE_TUNE_TABLE_NAME` ORDER BY `time` DESC')
  Future<List<CalorieTune>> findAllCalorieTunes();

  @Query('SELECT * FROM `$CALORIE_TUNE_TABLE_NAME` WHERE `id` = :id')
  Stream<CalorieTune?> findCalorieTuneById(int id);

  @Query('SELECT * FROM `$CALORIE_TUNE_TABLE_NAME` WHERE `mac` = :mac ORDER BY `time` DESC LIMIT 1')
  Stream<CalorieTune?> findCalorieTuneByMac(String mac);

  @Query('SELECT * FROM `$CALORIE_TUNE_TABLE_NAME` ORDER BY `time` DESC LIMIT :limit OFFSET :offset')
  Future<List<CalorieTune>> findCalorieTunes(int limit, int offset);

  @insert
  Future<int> insertCalorieTune(CalorieTune calorieTune);

  @update
  Future<int> updateCalorieTune(CalorieTune calorieTune);

  @delete
  Future<int> deleteCalorieTune(CalorieTune calorieTune);
}
