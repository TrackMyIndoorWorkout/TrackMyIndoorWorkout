import 'package:floor/floor.dart';
import '../models/record.dart';

@dao
abstract class RecordDao {
  @Query('SELECT * FROM `$recordsTableName` WHERE `activity_id` = :activityId ORDER BY `id`')
  Future<List<Record>> findActivityRecords(int activityId);

  @Query(
      'SELECT * FROM `$recordsTableName` WHERE `activity_id` = :activityId AND `id` > :recordId ORDER BY `id`')
  Future<List<Record>> findPartialActivityRecords(int activityId, int recordId);
}
