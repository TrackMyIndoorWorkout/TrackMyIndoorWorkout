import 'package:listview_utils/listview_utils.dart';
import 'activities.dart';

class ActivityListAdapter<Activity> implements BaseListAdapter<Activity> {
  const ActivityListAdapter(this.state);

  final ActivitiesScreenState state;

  @override
  Future<ListItems<Activity>> getItems(int offset, int limit) async {
    final data = await state.database.activityDao.findActivities(offset, limit);
    return ListItems(data as Iterable<Activity>,
        reachedToEnd: data.length == 0);
  }

  @override
  bool shouldUpdate(ActivityListAdapter<Activity> old) {
    final should = state.shouldUpdate;
    if (should) {
      state.toggleUpdate();
    }
    return should;
  }
}
