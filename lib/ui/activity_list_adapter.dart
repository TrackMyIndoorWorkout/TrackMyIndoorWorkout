import 'package:listview_utils/listview_utils.dart';
import '../persistence/database.dart';

class ActivityListAdapter implements BaseListAdapter {
  const ActivityListAdapter(this.database);

  final AppDatabase database;

  @override
  Future<ListItems> getItems(int offset, int limit) async {
    final data = await database.activityDao.findActivities(offset, limit);
    return ListItems(data, reachedToEnd: data.length == 0);
  }

  @override
  bool shouldUpdate(ActivityListAdapter old) {
    return false;
  }
}
