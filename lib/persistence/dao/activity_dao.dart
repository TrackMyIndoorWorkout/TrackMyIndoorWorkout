import 'package:floor/floor.dart';
import '../models/activity.dart';

@dao
abstract class ActivityDao {
  @Query('SELECT * FROM `$activitiesTableName` ORDER BY `start` DESC')
  Future<List<Activity>> findAllActivities();

  @Query('SELECT * FROM `$activitiesTableName` WHERE `id` = :id')
  Stream<Activity?> findActivityById(int id);

  @Query('SELECT * FROM `$activitiesTableName` ORDER BY `start` DESC LIMIT :limit OFFSET :offset')
  Future<List<Activity>> findActivities(int limit, int offset);

  @Query(
      'SELECT * FROM `$activitiesTableName` WHERE `deviceId` = :deviceId and `end` = 0 and `start` >= :thresholdTime ORDER BY `start` DESC')
  Future<List<Activity>> findRecentUnfinishedActivities(String deviceId, int thresholdTime);

  @Query(
      'SELECT * FROM `$activitiesTableName` WHERE `deviceId` = :deviceId and `end` = 0 and `start` < :thresholdTime ORDER BY `start` DESC')
  Future<List<Activity>> findStaleUnfinishedActivities(String deviceId, int thresholdTime);

  @insert
  Future<int> insertActivity(Activity activity);

  @update
  Future<int> updateActivity(Activity activity);

  @delete
  Future<int> deleteActivity(Activity activity);
}
