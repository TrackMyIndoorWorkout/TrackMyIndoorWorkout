import 'package:floor/floor.dart';
import '../models/activity.dart';

@dao
abstract class ActivityDao {
  @Query('SELECT * FROM $ACTIVITIES_TABLE_NAME ORDER BY start DESC')
  Future<List<Activity>> findAllActivities();

  @Query('SELECT * FROM $ACTIVITIES_TABLE_NAME WHERE id = :id')
  Stream<Activity> findActivityById(int id);

  @Query(
      'SELECT * FROM $ACTIVITIES_TABLE_NAME ORDER BY start DESC LIMIT :offset, :limit')
  Future<List<Activity>> findActivities(int offset, int limit);

  @insert
  Future<int> insertActivity(Activity activity);

  @update
  Future<int> updateActivity(Activity activity);

  @delete
  Future<int> deleteActivity(Activity activity);
}
