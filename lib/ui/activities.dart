import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:preferences/preferences.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../persistence/models/activity.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../strava/error_codes.dart';
import '../strava/strava_service.dart';
import '../tcx/tcx_output.dart';
import 'find_devices.dart';
import 'import_form.dart';
import 'records.dart';

class ActivitiesScreen extends StatefulWidget {
  ActivitiesScreen({key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ActivitiesScreenState();
  }
}

class ActivitiesScreenState extends State<ActivitiesScreen> {
  AppDatabase _database;
  bool _isLoading;
  int _editCount;
  bool _si;
  bool _compress;
  FontFamilyProperties _fontFamilyProperties;
  double _mediaWidth;
  double _sizeDefault;
  double _sizeDefault2;
  TextStyle _measurementStyle;
  TextStyle _textStyle;
  TextStyle _headerStyle;
  TextStyle _unitStyle;

  AppDatabase get database => _database;

  @override
  initState() {
    super.initState();
    _isLoading = true;
    _editCount = 0;
    _si = PrefService.getBool(UNIT_SYSTEM_TAG);
    _compress = PrefService.getBool(COMPRESS_DOWNLOAD_TAG);
    _fontFamilyProperties = getFontFamilyProperties();
    $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .addMigrations([migration1to2, migration2to3])
        .build()
        .then((db) {
          setState(() {
            _database = db;
            _isLoading = false;
          });
        });
  }

  Widget _actionButtonRow(Activity activity, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            BrandIcons.strava,
            color: activity.uploaded ? Colors.grey : Colors.deepOrangeAccent,
            size: size,
          ),
          onPressed: () async {
            if (!await DataConnectionChecker().hasConnection) {
              Get.snackbar("Warning", "No data connection detected");
              return;
            }

            StravaService stravaService;
            if (!Get.isRegistered<StravaService>()) {
              stravaService = Get.put<StravaService>(StravaService());
            } else {
              stravaService = Get.find<StravaService>();
            }
            final success = await stravaService.login();
            if (!success) {
              Get.snackbar("Warning", "Strava login unsuccessful");
              return;
            }

            final records =
                await _database.recordDao.findAllActivityRecords(activity.id);

            setState(() {
              _isLoading = true;
            });
            final statusCode = await stravaService.upload(activity, records);
            setState(() {
              _isLoading = false;
              _editCount++;
            });
            Get.snackbar(
                "Upload",
                statusCode == statusOk || statusCode >= 200 && statusCode < 300
                    ? "Activity ${activity.id} submitted successfully"
                    : "Activity ${activity.id} upload failure");
          },
        ),
        IconButton(
          icon: Icon(Icons.file_download, color: Colors.black, size: size),
          onPressed: () async {
            final records =
                await _database.recordDao.findAllActivityRecords(activity.id);
            final tcxGzip = await TCXOutput()
                .getTcxOfActivity(activity, records, _compress);
            final persistenceValues = activity.getPersistenceValues();
            ShareFilesAndScreenshotWidgets().shareFile(
                persistenceValues['name'],
                persistenceValues['fileName'],
                tcxGzip,
                TCXOutput.MIME_TYPE,
                text: 'Share a ride on ${activity.deviceName}');
          },
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.redAccent, size: size),
          onPressed: () async {
            Get.defaultDialog(
              title: 'Warning!!!',
              middleText: 'Are you sure to delete this Activity?',
              confirm: TextButton(
                child: Text("Yes"),
                onPressed: () async {
                  await _database.recordDao
                      .deleteAllActivityRecords(activity.id);
                  await _database.activityDao.deleteActivity(activity);
                  setState(() {
                    _editCount++;
                  });
                  Get.close(1);
                },
              ),
              cancel: TextButton(
                child: Text("No"),
                onPressed: () => Get.close(1),
              ),
            );
          },
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.chevron_right, color: Colors.black, size: size),
          onPressed: () async => await Get.to(
              RecordsScreen(activity: activity, size: Get.mediaQuery.size)),
        ),
      ],
    );
  }

  @override
  dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = Get.mediaQuery.size.width;
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > 1e-6) {
      _mediaWidth = mediaWidth;
      _sizeDefault = _mediaWidth / 7;
      _sizeDefault2 = _sizeDefault / 1.5;

      _measurementStyle = TextStyle(
        fontFamily: _fontFamilyProperties.primary,
        fontSize: _sizeDefault,
      );
      _textStyle = TextStyle(
        fontSize: _sizeDefault2,
      );
      _headerStyle = TextStyle(
        fontFamily: _fontFamilyProperties.secondary,
        fontSize: _sizeDefault2,
      );
      _unitStyle = TextStyle(
        fontFamily: _fontFamilyProperties.secondary,
        fontSize: _sizeDefault / 3,
        color: Colors.indigo,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () async {
              await Get.to(ImportForm()).whenComplete(() => setState(() {
                    _editCount++;
                  }));
            },
          ),
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () async {
              if (await canLaunch(HELP_URL)) {
                launch(HELP_URL);
              } else {
                Get.snackbar("Attention", "Cannot open URL");
              }
            },
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _database == null
            ? Container()
            : CustomListView(
                key: Key("CLV$_editCount"),
                paginationMode: PaginationMode.page,
                initialOffset: 0,
                loadingBuilder: (BuildContext context) =>
                    Center(child: CircularProgressIndicator()),
                adapter: ListAdapter(
                  fetchItems: (int offset, int limit) async {
                    final data = await _database.activityDao
                        .findActivities(offset, limit);
                    return ListItems(data, reachedToEnd: data.length < limit);
                  },
                ),
                errorBuilder: (context, error, state) {
                  return Column(
                    children: <Widget>[
                      Text(error.toString()),
                      ElevatedButton(
                        onPressed: () => state.loadMore(),
                        child: Text('Retry'),
                      ),
                    ],
                  );
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
                  return Card(
                    elevation: 6,
                    child: ExpandablePanel(
                      key: Key("${activity.id} ${activity.stravaId}"),
                      header: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.indigo,
                                size: _sizeDefault2,
                              ),
                              Text(
                                dateString,
                                style: _headerStyle,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.watch,
                                color: Colors.indigo,
                                size: _sizeDefault2,
                              ),
                              Text(
                                timeString,
                                style: _headerStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                      collapsed: ListTile(
                        trailing: _actionButtonRow(activity, _sizeDefault2),
                      ),
                      expanded: ListTile(
                        onTap: () async => await Get.to(RecordsScreen(
                            activity: item, size: Get.mediaQuery.size)),
                        title: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_bike,
                                  color: Colors.indigo,
                                  size: _sizeDefault,
                                ),
                                Spacer(),
                                Text(
                                  activity.deviceName,
                                  style: _textStyle,
                                  maxLines: 4,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: Colors.indigo,
                                  size: _sizeDefault,
                                ),
                                Spacer(),
                                Text(
                                  activity.elapsedString,
                                  style: _measurementStyle,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_road,
                                  color: Colors.indigo,
                                  size: _sizeDefault,
                                ),
                                Spacer(),
                                Text(
                                  activity.distanceString(_si),
                                  style: _measurementStyle,
                                ),
                                SizedBox(
                                  width: _sizeDefault,
                                  child: Text(
                                    _si ? 'm' : 'mi',
                                    style: _unitStyle,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.whatshot,
                                  color: Colors.indigo,
                                  size: _sizeDefault,
                                ),
                                Spacer(),
                                Text(
                                  '${activity.calories}',
                                  style: _measurementStyle,
                                ),
                                SizedBox(
                                  width: _sizeDefault,
                                  child: Text(
                                    'cal',
                                    style: _unitStyle,
                                  ),
                                ),
                              ],
                            ),
                            _actionButtonRow(activity, _sizeDefault2),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
