import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import '../persistence/models/activity.dart';
import '../persistence/database.dart';
import '../strava/error_codes.dart';
import '../strava/strava_service.dart';
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

  @override
  initState() {
    super.initState();
    $FloorAppDatabase.databaseBuilder('app_database.db').build().then((db) {
      setState(() {
        _database = db;
      });
    });
  }

  @override
  dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activities')),
      body: SafeArea(
        child: _database == null
            ? Text('Initializing...')
            : CustomListView<Activity>(
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
                  final activity = item as Activity;
                  final startStamp =
                      DateTime.fromMillisecondsSinceEpoch(activity.start);
                  final dateString = DateFormat.yMd().format(startStamp);
                  final timeString = DateFormat.Hms().format(startStamp);
                  return ListTile(
                    leading: activity.uploaded
                        ? Icon(Icons.check, color: Colors.lightGreenAccent)
                        : Icon(Icons.close, color: Colors.red),
                    title: Text(
                        '$dateString $timeString on ${activity.deviceName}'),
                    subtitle: Text(
                        '${activity.elapsed} s, ${activity.distance} m, ${activity.calories} kCal'),
                    trailing: IconButton(
                      icon: Icon(Icons.file_upload,
                          color:
                              activity.uploaded ? Colors.grey : Colors.green),
                      onPressed: () async {
                        StravaService stravaService;
                        if (!Get.isRegistered<StravaService>()) {
                          stravaService =
                              Get.put<StravaService>(StravaService());
                        } else {
                          stravaService = Get.find<StravaService>();
                        }
                        final success = await stravaService.login();
                        if (!success) {
                          Get.snackbar("Warning", "Strava login unsuccessful");
                        } else {
                          final records = await _database.recordDao
                              .findAllActivityRecords(activity.id);
                          final statusCode =
                              await stravaService.upload(activity, records);
                          if (statusCode == statusOk) {
                            activity.uploaded = true; // TODO trigger UI update
                            await _database.activityDao
                                .updateActivity(activity);
                          }
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
