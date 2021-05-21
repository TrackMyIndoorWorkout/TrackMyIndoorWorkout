import 'dart:math';
import 'dart:typed_data';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:expandable/expandable.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:preferences/preferences.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../export/activity_export.dart';
import '../export/fit/fit_export.dart';
import '../export/tcx/tcx_export.dart';
import '../persistence/models/activity.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../strava/error_codes.dart';
import '../strava/strava_service.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import '../utils/theme_manager.dart';
import 'calorie_tunes.dart';
import 'device_usages.dart';
import 'find_devices.dart';
import 'import_form.dart';
import 'leaderboards/leaderboard_type_picker.dart';
import 'parts/calorie_override.dart';
import 'parts/data_format_picker.dart';
import 'parts/power_factor_tune.dart';
import 'power_tunes.dart';
import 'records.dart';

class ActivitiesScreen extends StatefulWidget {
  final bool hasLeaderboardData;

  ActivitiesScreen({key, this.hasLeaderboardData}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ActivitiesScreenState(hasLeaderboardData: hasLeaderboardData);
  }
}

class ActivitiesScreenState extends State<ActivitiesScreen> {
  AppDatabase _database;
  int _editCount;
  bool _si;
  bool _leaderboardFeature;
  bool hasLeaderboardData;
  double _mediaWidth;
  double _sizeDefault;
  double _sizeDefault2;
  TextStyle _measurementStyle;
  TextStyle _textStyle;
  TextStyle _headerStyle;
  TextStyle _unitStyle;
  ThemeManager _themeManager;

  ActivitiesScreenState({@required this.hasLeaderboardData}) : assert(hasLeaderboardData != null);

  @override
  void initState() {
    super.initState();
    _editCount = 0;
    _si = PrefService.getBool(UNIT_SYSTEM_TAG);
    _leaderboardFeature =
        PrefService.getBool(LEADERBOARD_FEATURE_TAG) ?? LEADERBOARD_FEATURE_DEFAULT;
    _database = Get.find<AppDatabase>();
    _themeManager = Get.find<ThemeManager>();
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

            final records = await _database.recordDao.findAllActivityRecords(activity.id);

            final statusCode = await stravaService.upload(activity, records);
            setState(() {
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
            if (!await Permission.storage.request().isGranted) {
              return false;
            }

            final formatPick = await Get.bottomSheet(
              DataFormatPickerBottomSheet(),
              isDismissible: false,
              enableDrag: false,
            );

            if (formatPick == null) {
              return false;
            }

            final records = await _database.recordDao.findAllActivityRecords(activity.id);
            ActivityExport exporter = formatPick == "TCX" ? TCXExport() : FitExport();
            final fileStream = await exporter.getExport(activity, records, false);
            final persistenceValues = exporter.getPersistenceValues(activity, false);
            ShareFilesAndScreenshotWidgets().shareFile(
              persistenceValues['name'],
              persistenceValues['fileName'],
              Uint8List.fromList(fileStream),
              exporter.mimeType(false),
              text: 'Share a ride on ${activity.deviceName}',
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.bolt, color: Colors.black, size: size),
          onPressed: () async {
            if (activity.powerFactor == null || activity.powerFactor < EPS) {
              Get.snackbar("Error", "Cannot tune power of activity due to lack of reference");
              return;
            }
            await Get.bottomSheet(
              PowerFactorTuneBottomSheet(
                  deviceId: activity.deviceId, powerFactor: activity.powerFactor),
              enableDrag: false,
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.whatshot, color: Colors.black, size: size),
          onPressed: () async {
            if (activity.calories == null || activity.calories == 0) {
              Get.snackbar("Error", "Cannot tune calories of activity with 0 calories");
              return;
            }
            await Get.bottomSheet(
              CalorieOverrideBottomSheet(deviceId: activity.deviceId, calories: activity.calories),
              enableDrag: false,
            );
          },
        ),
        Spacer(),
        IconButton(
          icon: _themeManager.getDeleteIcon(size),
          onPressed: () async {
            Get.defaultDialog(
              title: 'Warning!!!',
              middleText: 'Are you sure to delete this Activity?',
              confirm: TextButton(
                child: Text("Yes"),
                onPressed: () async {
                  await _database.recordDao.deleteAllActivityRecords(activity.id);
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
          onPressed: () async =>
              await Get.to(RecordsScreen(activity: activity, size: Get.mediaQuery.size)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = _mediaWidth / 7;
      _sizeDefault2 = _sizeDefault / 1.5;

      _measurementStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault,
      );
      _textStyle = TextStyle(
        fontSize: _sizeDefault2,
      );
      _headerStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault2,
      );
      _unitStyle = _themeManager.getBlueTextStyle(_sizeDefault / 3);
    }

    List<FloatingActionButton> floatingActionButtons = [
      _themeManager.getBlueFab(Icons.file_upload, () async {
        await Get.to(ImportForm()).whenComplete(() => setState(() {
              _editCount++;
            }));
      }),
      _themeManager.getBlueFab(Icons.collections_bookmark, () async {
        await Get.to(DeviceUsagesScreen());
      }),
      _themeManager.getBlueFab(Icons.bolt, () async {
        await Get.to(PowerTunesScreen());
      }),
      _themeManager.getBlueFab(Icons.whatshot, () async {
        await Get.to(CalorieTunesScreen());
      }),
    ];

    if (_leaderboardFeature && hasLeaderboardData) {
      floatingActionButtons.add(
        _themeManager.getBlueFab(Icons.leaderboard, () async {
          await Get.bottomSheet(LeaderBoardTypeBottomSheet(), enableDrag: false);
        }),
      );
    }

    floatingActionButtons.add(
      _themeManager.getBlueFab(Icons.help, () async {
        if (await canLaunch(HELP_URL)) {
          launch(HELP_URL);
        } else {
          Get.snackbar("Attention", "Cannot open URL");
        }
      }),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Activities')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final offset = page * limit;
            final data = await _database.activityDao.findActivities(limit, offset);
            return ListItems(data, reachedToEnd: data.length < limit);
          },
        ),
        errorBuilder: (context, error, state) {
          return Column(
            children: [
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
          final startStamp = DateTime.fromMillisecondsSinceEpoch(activity.start);
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
                      _themeManager.getBlueIcon(Icons.calendar_today, _sizeDefault2),
                      Text(dateString, style: _headerStyle),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _themeManager.getBlueIcon(Icons.watch, _sizeDefault2),
                      Text(timeString, style: _headerStyle),
                    ],
                  ),
                ],
              ),
              expanded: ListTile(
                onTap: () async =>
                    await Get.to(RecordsScreen(activity: item, size: Get.mediaQuery.size)),
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(getIcon(activity.sport), _sizeDefault),
                        Expanded(
                          child: TextOneLine(
                            activity.deviceName,
                            style: _textStyle,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.timer, _sizeDefault),
                        Spacer(),
                        Text(activity.elapsedString, style: _measurementStyle),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.add_road, _sizeDefault),
                        Spacer(),
                        Text(activity.distanceString(_si), style: _measurementStyle),
                        SizedBox(
                          width: _sizeDefault,
                          child: Text(_si ? 'm' : 'mi', style: _unitStyle),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.whatshot, _sizeDefault),
                        Spacer(),
                        Text('${activity.calories}', style: _measurementStyle),
                        SizedBox(
                          width: _sizeDefault,
                          child: Text('cal', style: _unitStyle),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FabCircularMenu(
        fabOpenIcon: Icon(Icons.menu, color: _themeManager.getAntagonistColor()),
        fabOpenColor: _themeManager.getBlueColor(),
        fabCloseIcon: Icon(Icons.close, color: _themeManager.getAntagonistColor()),
        fabCloseColor: _themeManager.getBlueColor(),
        children: floatingActionButtons,
      ),
    );
  }
}
