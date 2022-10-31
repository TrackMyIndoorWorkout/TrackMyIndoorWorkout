import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:pref/pref.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:tuple/tuple.dart';
import '../export/activity_export.dart';
import '../export/csv/csv_export.dart';
import '../export/export_target.dart';
import '../export/fit/fit_export.dart';
import '../export/json/json_export.dart';
import '../export/tcx/tcx_export.dart';
import '../persistence/floor/models/activity.dart';
import '../persistence/floor/database.dart';
import '../preferences/calculate_gps.dart';
import '../preferences/distance_resolution.dart';
import '../preferences/leaderboard_and_rank.dart';
import '../preferences/measurement_font_size_adjust.dart';
import '../preferences/time_display_mode.dart';
import '../preferences/unit_system.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import '../utils/preferences.dart';
import '../utils/theme_manager.dart';
import 'calorie_tunes.dart';
import 'device_usages.dart';
import 'import_form.dart';
import 'leaderboards/leaderboard_type_picker.dart';
import 'parts/calorie_override.dart';
import 'parts/circular_menu.dart';
import 'parts/export_format_picker.dart';
import 'parts/import_format_picker.dart';
import 'parts/legend_dialog.dart';
import 'parts/power_factor_tune.dart';
import 'parts/sport_picker.dart';
import 'parts/upload_portal_picker.dart';
import 'power_tunes.dart';
import 'details/activity_details.dart';

class ActivitiesScreen extends StatefulWidget {
  final bool hasLeaderboardData;

  const ActivitiesScreen({key, required this.hasLeaderboardData}) : super(key: key);

  @override
  ActivitiesScreenState createState() => ActivitiesScreenState();
}

class ActivitiesScreenState extends State<ActivitiesScreen> with WidgetsBindingObserver {
  final AppDatabase _database = Get.find<AppDatabase>();
  int _editCount = 0;
  bool _si = unitSystemDefault;
  bool _highRes = distanceResolutionDefault;
  bool _leaderboardFeature = leaderboardFeatureDefault;
  String _timeDisplayMode = timeDisplayModeDefault;
  bool _calculateGps = calculateGpsDefault;
  double? _mediaWidth;
  double _sizeDefault = 10.0;
  double _sizeDefault2 = 10.0;
  double _sizeAdjust = 1.0;
  TextStyle _measurementStyle = const TextStyle();
  TextStyle _textStyle = const TextStyle();
  TextStyle _headerStyle = const TextStyle();
  TextStyle _unitStyle = const TextStyle();
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  ExpandableThemeData _expandableThemeData = const ExpandableThemeData(iconColor: Colors.black);

  @override
  void didChangeMetrics() {
    setState(() {
      _editCount++;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final prefService = Get.find<BasePrefService>();
    _si = prefService.get<bool>(unitSystemTag) ?? unitSystemDefault;
    _highRes =
        Get.find<BasePrefService>().get<bool>(distanceResolutionTag) ?? distanceResolutionDefault;
    _leaderboardFeature = prefService.get<bool>(leaderboardFeatureTag) ?? leaderboardFeatureDefault;
    _timeDisplayMode = prefService.get<String>(timeDisplayModeTag) ?? timeDisplayModeDefault;
    _calculateGps = prefService.get<bool>(calculateGpsTag) ?? calculateGpsDefault;
    _expandableThemeData = ExpandableThemeData(iconColor: _themeManager.getProtagonistColor());
    final sizeAdjustInt =
        prefService.get<int>(measurementFontSizeAdjustTag) ?? measurementFontSizeAdjustDefault;
    if (sizeAdjustInt != 100) {
      _sizeAdjust = sizeAdjustInt / 100.0;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ActivityExport getExporter(String format) {
    switch (format.toUpperCase()) {
      case "TCX":
        return TCXExport();
      case "FIT":
        return FitExport();
      case "JSON":
        return JsonExport();
      case "CSV":
      default:
        return CsvExport();
    }
  }

  Widget _actionButtonRow(Activity activity, double size) {
    final actionsRow = <Widget>[
      IconButton(
        icon: _themeManager.getActionIcon(Icons.cloud_upload, size),
        iconSize: size,
        onPressed: () async {
          if (!await hasInternetConnection()) {
            Get.snackbar("Warning", "No data connection detected, try again later!");
            return;
          }

          Get.bottomSheet(
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: UploadPortalPickerBottomSheet(activity: activity),
                    ),
                  ),
                ],
              ),
            ),
            isScrollControlled: true,
            ignoreSafeArea: false,
            enableDrag: false,
          );
        },
      ),
      IconButton(
        icon: _themeManager.getActionIcon(Icons.file_download, size),
        iconSize: size,
        onPressed: () async {
          final formatPick = await Get.bottomSheet(
            SafeArea(
              child: Column(
                children: const [
                  Expanded(
                    child: Center(
                      child: ExportFormatPickerBottomSheet(),
                    ),
                  ),
                ],
              ),
            ),
            isScrollControlled: true,
            ignoreSafeArea: false,
            enableDrag: false,
          );

          if (formatPick == null) {
            return;
          }

          final records = await _database.recordDao.findAllActivityRecords(activity.id ?? 0);
          ActivityExport exporter = getExporter(formatPick);
          final fileBytes = await exporter.getExport(
            activity,
            records,
            formatPick == "CSV",
            _calculateGps,
            false,
            ExportTarget.regular,
          );
          final persistenceValues = exporter.getPersistenceValues(activity, false);
          ShareFilesAndScreenshotWidgets().shareFile(
            persistenceValues['name'],
            persistenceValues['fileName'],
            Uint8List.fromList(fileBytes),
            exporter.mimeType(false),
            text: 'Share a ride on ${activity.deviceName}',
          );
        },
      ),
      IconButton(
        icon: _themeManager.getActionIcon(Icons.bolt, size),
        iconSize: size,
        onPressed: () async {
          if (activity.powerFactor < eps) {
            Get.snackbar("Error", "Cannot tune power of activity due to lack of reference");
            return;
          }
          Get.bottomSheet(
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: PowerFactorTuneBottomSheet(
                        deviceId: activity.deviceId,
                        oldPowerFactor: activity.powerFactor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isScrollControlled: true,
            ignoreSafeArea: false,
            enableDrag: false,
          );
        },
      ),
      IconButton(
        icon: _themeManager.getActionIcon(Icons.whatshot, size),
        iconSize: size,
        onPressed: () async {
          if (activity.calories == 0) {
            Get.snackbar("Error", "Cannot tune calories of activity with 0 calories");
            return;
          }
          Get.bottomSheet(
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: CalorieOverrideBottomSheet(activity: activity),
                    ),
                  ),
                ],
              ),
            ),
            isScrollControlled: true,
            ignoreSafeArea: false,
            enableDrag: false,
          );
        },
      ),
    ];

    if (kDebugMode) {
      actionsRow.add(
        IconButton(
          icon: _themeManager.getActionIcon(Icons.edit, size),
          iconSize: size,
          onPressed: () async {
            final sportPick = await Get.bottomSheet(
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SportPickerBottomSheet(
                          sportChoices: allSports,
                          initialSport: activity.sport,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              isScrollControlled: true,
              ignoreSafeArea: false,
              enableDrag: false,
            );
            if (sportPick != null) {
              activity.sport = sportPick;
              await _database.activityDao.updateActivity(activity);
              setState(() {
                _editCount++;
              });
            }
          },
        ),
      );
    }

    actionsRow.addAll([
      const Spacer(),
      IconButton(
        icon: _themeManager.getDeleteIcon(size),
        iconSize: size,
        onPressed: () async {
          Get.defaultDialog(
            title: 'Warning!!!',
            middleText: 'Are you sure to delete this Activity?',
            confirm: TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                await _database.recordDao.deleteAllActivityRecords(activity.id ?? 0);
                await _database.activityDao.deleteActivity(activity);
                setState(() {
                  _editCount++;
                });
                Get.close(1);
              },
            ),
            cancel: TextButton(
              child: const Text("No"),
              onPressed: () => Get.close(1),
            ),
          );
        },
      ),
      const Spacer(),
      IconButton(
        icon: _themeManager.getActionIcon(Icons.chevron_right, size),
        iconSize: size,
        onPressed: () async => await Get.to(
            () => ActivityDetailsScreen(activity: activity, size: Get.mediaQuery.size)),
      ),
    ]);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actionsRow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth! - mediaWidth).abs() > eps) {
      _mediaWidth = mediaWidth;
      _sizeDefault = _mediaWidth! / 7 * _sizeAdjust;
      _sizeDefault2 = _sizeDefault / 1.5;

      _measurementStyle = TextStyle(
        fontFamily: fontFamily,
        fontSize: _sizeDefault,
      );
      _textStyle = TextStyle(
        fontSize: _sizeDefault2,
      );
      _headerStyle = TextStyle(
        fontFamily: fontFamily,
        fontSize: _sizeDefault2,
      );
      _unitStyle = _themeManager.getBlueTextStyle(_sizeDefault / 3);
    }

    List<Widget> floatingActionButtons = [
      _themeManager.getAboutFab(),
      _themeManager.getBlueFab(Icons.file_upload, () async {
        final formatPick = await Get.bottomSheet(
          SafeArea(
            child: Column(
              children: const [
                Expanded(
                  child: Center(
                    child: ImportFormatPickerBottomSheet(),
                  ),
                ),
              ],
            ),
          ),
          isScrollControlled: true,
          ignoreSafeArea: false,
          enableDrag: false,
        );

        if (formatPick == null) {
          return;
        }

        await Get.to(() => ImportForm(migration: formatPick == "Migration"))
            ?.whenComplete(() => setState(() {
                  _editCount++;
                }));
      }),
      _themeManager.getBlueFab(Icons.collections_bookmark, () async {
        await Get.to(() => const DeviceUsagesScreen());
      }),
      _themeManager.getBlueFab(Icons.bolt, () async {
        await Get.to(() => const PowerTunesScreen());
      }),
      _themeManager.getBlueFab(Icons.whatshot, () async {
        await Get.to(() => const CalorieTunesScreen());
      }),
    ];

    if (_leaderboardFeature && widget.hasLeaderboardData) {
      floatingActionButtons.add(
        _themeManager.getBlueFab(Icons.leaderboard, () async {
          Get.bottomSheet(
            SafeArea(
              child: Column(
                children: const [
                  Expanded(
                    child: Center(
                      child: LeaderBoardTypeBottomSheet(),
                    ),
                  ),
                ],
              ),
            ),
            isScrollControlled: true,
            ignoreSafeArea: false,
            enableDrag: false,
          );
        }),
      );
    }

    final circularFabMenu = CircularFabMenu(
      fabOpenIcon: Icon(Icons.menu, color: _themeManager.getAntagonistColor()),
      fabOpenColor: _themeManager.getBlueColor(),
      fabCloseIcon: Icon(Icons.close, color: _themeManager.getAntagonistColor()),
      fabCloseColor: _themeManager.getBlueColor(),
      ringColor: _themeManager.getBlueColorInverse(),
      children: floatingActionButtons,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        actions: [
          IconButton(
              icon: const Icon(Icons.info_rounded),
              onPressed: () {
                legendDialog([
                  const Tuple2<IconData, String>(Icons.file_upload, "Import Workout"),
                  const Tuple2<IconData, String>(Icons.collections_bookmark, "Device Usages"),
                  const Tuple2<IconData, String>(Icons.bolt, "Power Tunes"),
                  const Tuple2<IconData, String>(Icons.whatshot, "Calorie Tunes"),
                  const Tuple2<IconData, String>(Icons.leaderboard, "Leaderboards"),
                  const Tuple2<IconData, String>(Icons.help, "About"),
                  const Tuple2<IconData, String>(Icons.info_rounded, "Help Legend"),
                  const Tuple2<IconData, String>(Icons.cloud_upload, "Upload / Sync"),
                  const Tuple2<IconData, String>(Icons.file_download, "Download Workout"),
                  const Tuple2<IconData, String>(Icons.delete, "Delete Workout"),
                  const Tuple2<IconData, String>(Icons.chevron_right, "Workout Details"),
                ]);
              }),
        ],
      ),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
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
                child: const Text('Retry'),
              ),
            ],
          );
        },
        empty: const Center(child: Text('No activities found')),
        itemBuilder: (context, _, item) {
          final activity = item as Activity;
          final startStamp = DateTime.fromMillisecondsSinceEpoch(activity.start);
          final dateString = DateFormat.yMd().format(startStamp);
          final timeString = DateFormat.Hms().format(startStamp);
          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key(activity.uniqueIntegrationString()),
              theme: _expandableThemeData,
              header: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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
              collapsed: Container(),
              expanded: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                minLeadingWidth: 0,
                horizontalTitleGap: 0,
                onTap: () =>
                    Get.to(() => ActivityDetailsScreen(activity: item, size: Get.mediaQuery.size)),
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(getSportIcon(activity.sport), _sizeDefault),
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
                        const Spacer(),
                        FitHorizontally(
                          child: Text(
                            _timeDisplayMode == timeDisplayModeElapsed
                                ? activity.elapsedString
                                : activity.movingTimeString,
                            style: _measurementStyle,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.add_road, _sizeDefault),
                        const Spacer(),
                        Text(activity.distanceString(_si, _highRes), style: _measurementStyle),
                        SizedBox(
                          width: _sizeDefault,
                          child: Text(distanceUnit(_si, _highRes), style: _unitStyle),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.whatshot, _sizeDefault),
                        const Spacer(),
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
      floatingActionButton: circularFabMenu,
    );
  }
}
