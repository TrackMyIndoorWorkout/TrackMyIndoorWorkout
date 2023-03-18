import 'package:floor/floor.dart';
import '../models/calorie_tune.dart';

@dao
abstract class CalorieTuneDao {
  @Query('SELECT * FROM `$calorieTuneTableName` ORDER BY `time` DESC')
  Future<List<CalorieTune>> findAllCalorieTunes();

  @update
  Future<int> updateCalorieTune(CalorieTune calorieTune);
}
