import 'package:floor/floor.dart';
import '../models/activity.dart';

@dao
abstract class ActivityDao {
  @Query('SELECT * FROM `$activitiesTableName` ORDER BY `id`')
  Future<List<Activity>> findAllActivities();

  @update
  Future<int> updateActivity(Activity activity);
}
