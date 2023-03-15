import 'package:floor/floor.dart';
import '../models/record.dart';

@dao
abstract class RecordDao {
  @Query('SELECT * FROM `$recordsTableName` ORDER BY `time_stamp`')
  Future<List<Record>> findAllRecords();

  @Query('SELECT COUNT(`id`) FROM `$recordsTableName`')
  Future<int?> getRecordCount();

  @Query('SELECT COUNT(`id`) FROM `$recordsTableName` WHERE `activity_id` = :activityId')
  Future<int?> getActivityRecordCount(int activityId);
}
