import 'package:floor/floor.dart';
import '../models/calorie_tune.dart';

@dao
abstract class CalorieTuneDao {
  @Query('SELECT * FROM `$calorieTuneTableName` ORDER BY `time` DESC')
  Future<List<CalorieTune>> findAllCalorieTunes();

  @Query('SELECT * FROM `$calorieTuneTableName` WHERE `id` = :id')
  Future<CalorieTune?> findCalorieTuneById(int id);

  @Query(
      'SELECT * FROM `$calorieTuneTableName` WHERE `mac` = :mac AND `hr_based` = 0 ORDER BY `time` DESC LIMIT 1')
  Future<CalorieTune?> findCalorieTuneByMac(String mac);

  @Query(
      'SELECT * FROM `$calorieTuneTableName` WHERE `mac` = :mac AND `hr_based` = 1 ORDER BY `time` DESC LIMIT 1')
  Future<CalorieTune?> findHrCalorieTuneByMac(String mac);

  @Query('SELECT * FROM `$calorieTuneTableName` ORDER BY `time` DESC LIMIT :limit OFFSET :offset')
  Future<List<CalorieTune>> findCalorieTunes(int limit, int offset);

  @insert
  Future<int> insertCalorieTune(CalorieTune calorieTune);

  @update
  Future<int> updateCalorieTune(CalorieTune calorieTune);

  @delete
  Future<int> deleteCalorieTune(CalorieTune calorieTune);
}
