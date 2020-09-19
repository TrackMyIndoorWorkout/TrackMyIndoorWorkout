import 'package:flutter/material.dart';
import 'package:listview_utils/listview_utils.dart';
import '../persistence/database.dart';
import 'activity_list_adapter.dart';

class ActivitiesScreen extends StatefulWidget {
  ActivitiesScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ActivitiesScreenState();
  }
}

class ActivitiesScreenState extends State<ActivitiesScreen> {
  AppDatabase _database;

  _openDatabase() async {
    _database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  }

  @override
  initState() {
    super.initState();
    _openDatabase();
  }

  @override
  dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(title: Text('Activities')),
      body: SafeArea(
        child: CustomListView(
          paginationMode: PaginationMode.page,
          initialOffset: 0,
          loadingBuilder: CustomListLoading.defaultBuilder,
          adapter: ActivityListAdapter(_database),
          errorBuilder: (context, error, state) {
            return Column(
              children: <Widget>[
                Text(error.toString()),
                RaisedButton(
                  onPressed: () => state.loadMore(),
                  child: Text('Retry'),
                ),
              ],
            );
          },
          separatorBuilder: (context, _) {
            return Divider(height: 1);
          },
          empty: Center(
            child: Text('No activities found'),
          ),
          itemBuilder: (context, _, item) {
            return ListTile(
              title: Text(item['title']),
              leading: Icon(Icons.assignment),
            );
          },
        ),
      ),
    );
  }
}
