import 'package:listview_utils/listview_utils.dart';
import '../persistence/database.dart';

class ActivityListAdapter<Activity> implements BaseListAdapter<Activity> {
  const ActivityListAdapter(this.database);

  final AppDatabase database;

  @override
  Future<ListItems<Activity>> getItems(int offset, int limit) async {
    final data = await database.activityDao.findActivities(offset, limit);
    return ListItems(data as Iterable<Activity>,
        reachedToEnd: data.length == 0);
  }

  @override
  bool shouldUpdate(ActivityListAdapter<Activity> old) {
    return false;
  }
}
