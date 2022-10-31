import 'package:floor/floor.dart';
import '../models/record.dart';

@dao
abstract class RecordDao {
  @Query('SELECT * FROM `$recordsTableName` ORDER BY `time_stamp`')
  Future<List<Record>> findAllRecords();

  @Query('SELECT * FROM `$recordsTableName` WHERE `id` = :id')
  Stream<Record?> findRecordById(int id);

  @Query(
      'SELECT * FROM `$recordsTableName` WHERE `activity_id` = :activityId ORDER BY `time_stamp`')
  Future<List<Record>> findAllActivityRecords(int activityId);

  @Query(
      'SELECT * FROM `$recordsTableName` WHERE `activity_id` = :activityId ORDER BY `time_stamp` DESC LIMIT 1')
  Stream<Record?> findLastRecordOfActivity(int activityId);

  @insert
  Future<void> insertRecord(Record record);

  @update
  Future<void> updateRecord(Record record);

  @Query('DELETE FROM `$recordsTableName` WHERE `activity_id` = :activityId')
  Future<List<Record>> deleteAllActivityRecords(int activityId);
}
