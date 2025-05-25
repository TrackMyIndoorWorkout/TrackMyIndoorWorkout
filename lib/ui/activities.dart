import 'dart:io';
import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:listview_utils_plus/listview_utils_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pref/pref.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';

import '../export/activity_export.dart';
import '../export/csv/csv_export.dart';
import '../export/export_target.dart';
import '../export/fit/fit_export.dart';
import '../export/json/json_export.dart';
import '../export/tcx/tcx_export.dart';
import '../persistence/activity.dart';
import '../persistence/db_utils.dart';
import '../persistence/record.dart';
import '../preferences/activity_ui.dart';
import '../preferences/calculate_gps.dart';
import '../preferences/distance_resolution.dart';
import '../preferences/leaderboard_and_rank.dart';
import '../preferences/measurement_font_size_adjust.dart';
import '../preferences/time_display_mode.dart';
import '../preferences/unit_system.dart';
import '../preferences/upload_display_mode.dart';
import '../upload/constants.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import '../utils/preferences.dart';
import '../utils/string_ex.dart';
import '../utils/theme_manager.dart';
import 'calorie_tunes.dart';
import 'details/activity_detail_header_row_base.dart';
import 'details/activity_detail_header_text_row.dart';
import 'details/activity_detail_row_one_line.dart';
import 'details/activity_detail_row_w_spacer.dart';
import 'details/activity_detail_row_w_unit.dart';
import 'details/activity_details.dart';
import 'device_usages.dart';
import 'import_form.dart';
import 'leaderboards/leaderboard_type_picker.dart';
import 'parts/calorie_override.dart';
import 'parts/export_format_picker.dart';
import 'parts/import_format_picker.dart';
import 'parts/legend_dialog.dart';
import 'parts/power_factor_tune.dart';
import 'parts/sport_picker.dart';
import 'parts/upload_portal_picker.dart';
import 'power_tunes.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ActivitiesScreenState createState() => ActivitiesScreenState();
}

class ActivitiesScreenState extends State<ActivitiesScreen> with WidgetsBindingObserver {
  final _database = Get.find<Isar>();
  int _editCount = 0;
  bool _si = unitSystemDefault;
  bool _highRes = distanceResolutionDefault;
  bool _leaderboardFeature = leaderboardFeatureDefault;
  String _timeDisplayMode = timeDisplayModeDefault;
  String _uploadDisplayMode = uploadDisplayModeDefault;
  bool _calculateGps = calculateGpsDefault;
  bool _machineNameInHeader = activityListMachineNameInHeaderDefault;
  bool _bluetoothAddressInHeader = activityListBluetoothAddressInHeaderDefault;
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
    _uploadDisplayMode = prefService.get<String>(uploadDisplayModeTag) ?? uploadDisplayModeDefault;
    _calculateGps = prefService.get<bool>(calculateGpsTag) ?? calculateGpsDefault;
    _machineNameInHeader =
        prefService.get<bool>(activityListMachineNameInHeaderTag) ??
        activityListMachineNameInHeaderDefault;
    _bluetoothAddressInHeader =
        prefService.get<bool>(activityListBluetoothAddressInHeaderTag) ??
        activityListBluetoothAddressInHeaderDefault;
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
                    child: Center(child: UploadPortalPickerBottomSheet(activity: activity)),
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
            const SafeArea(
              child: Column(
                children: [Expanded(child: Center(child: ExportFormatPickerBottomSheet()))],
              ),
            ),
            isScrollControlled: true,
            ignoreSafeArea: false,
            enableDrag: false,
          );

          if (formatPick == null) {
            return;
          }

          ActivityExport exporter = getExporter(formatPick);
          final fileBytes = await exporter.getExport(
            activity,
            formatPick == "CSV",
            _calculateGps,
            false,
            ExportTarget.regular,
          );
          final fileName = activity.getFileNameStub() + exporter.fileExtension(false);
          final Directory tempDir = await getTemporaryDirectory();
          final workoutFilePath = "${tempDir.path}/$fileName";
          final workoutFile = await File(workoutFilePath).writeAsBytes(fileBytes, flush: true);
          Share.shareXFiles([XFile(workoutFile.path)], text: activity.getTitle(false));
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
                    child: Center(child: CalorieOverrideBottomSheet(activity: activity)),
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
              _database.writeTxnSync(() {
                _database.activitys.putSync(activity);
              });

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
                _database.writeTxnSync(() {
                  _database.records.filter().activityIdEqualTo(activity.id).deleteAllSync();
                  _database.activitys.deleteSync(activity.id);
                  setState(() {
                    _editCount++;
                  });
                });
                Get.close(1);
              },
            ),
            cancel: TextButton(child: const Text("No"), onPressed: () => Get.close(1)),
          );
        },
      ),
      const Spacer(),
      IconButton(
        icon: _themeManager.getActionIcon(Icons.chevron_right, size),
        iconSize: size,
        onPressed: () async => await Get.to(
          () => ActivityDetailsScreen(activity: activity, size: Get.mediaQuery.size),
        ),
      ),
    ]);

    return FitHorizontally(
      shrinkLimit: shrinkLimit,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: actionsRow),
    );
  }

  void invokeLegendDialog() {
    legendDialog([
      const Tuple2<IconData, String>(Icons.file_upload, "Import Workout"),
      const Tuple2<IconData, String>(Icons.collections_bookmark, "Device Usages"),
      const Tuple2<IconData, String>(Icons.bolt, "Power & Tunes"),
      const Tuple2<IconData, String>(Icons.whatshot, "Calorie & Tunes"),
      const Tuple2<IconData, String>(Icons.leaderboard, "Leaderboards"),
      const Tuple2<IconData, String>(Icons.help, "About"),
      const Tuple2<IconData, String>(Icons.info_rounded, "Help Legend"),
      const Tuple2<IconData, String>(Icons.cloud_upload, "Upload / Sync"),
      const Tuple2<IconData, String>(Icons.file_download, "Download Workout"),
      const Tuple2<IconData, String>(Icons.delete, "Delete Workout"),
      const Tuple2<IconData, String>(Icons.chevron_right, "Workout Details"),
      const Tuple2<IconData, String>(Icons.calendar_today, "Activity Date"),
      const Tuple2<IconData, String>(Icons.access_time_filled, "Activity Time"),
      const Tuple2<IconData, String>(Icons.timer, "Activity Duration"),
      const Tuple2<IconData, String>(Icons.add_road, "Activity Distance"),
      const Tuple2<IconData, String>(Icons.numbers, "Bluetooth ID"),
      const Tuple2<IconData, String>(Icons.directions_bike, "Bike Sport"),
      const Tuple2<IconData, String>(Icons.directions_run, "Run Sport"),
      const Tuple2<IconData, String>(Icons.kayaking, "Kayak / Canoe Sport"),
      const Tuple2<IconData, String>(Icons.rowing, "Rowing Sport"),
      const Tuple2<IconData, String>(Icons.waves, "Swimming Sport"),
      const Tuple2<IconData, String>(Icons.downhill_skiing, "Elliptical / Nordic Ski Sport"),
      const Tuple2<IconData, String>(Icons.stairs, "Stair Stepper / Climber Sport"),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth! - mediaWidth).abs() > eps) {
      _mediaWidth = mediaWidth;
      _sizeDefault = _mediaWidth! / 7 * _sizeAdjust;
      _sizeDefault2 = _sizeDefault / 1.5;

      _measurementStyle = TextStyle(fontFamily: fontFamily, fontSize: _sizeDefault);
      _textStyle = TextStyle(fontSize: _sizeDefault2);
      _headerStyle = TextStyle(fontFamily: fontFamily, fontSize: _sizeDefault2);
      _unitStyle = _themeManager.getBlueTextStyle(_sizeDefault / 3);
    }

    List<Widget> floatingActionButtons = [
      _themeManager.getTutorialFab(() => invokeLegendDialog()),
      _themeManager.getAboutFab(),
      _themeManager.getBlueFab(Icons.file_upload, () async {
        final formatPick = await Get.bottomSheet(
          const SafeArea(
            child: Column(
              children: [Expanded(child: Center(child: ImportFormatPickerBottomSheet()))],
            ),
          ),
          isScrollControlled: true,
          ignoreSafeArea: false,
          enableDrag: false,
        );

        if (formatPick == null) {
          return;
        }

        await Get.to(() => ImportForm(migration: formatPick == "Migration"))?.whenComplete(
          () => setState(() {
            _editCount++;
          }),
        );
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

    if (_leaderboardFeature && DbUtils().hasLeaderboardData()) {
      floatingActionButtons.add(
        _themeManager.getBlueFab(Icons.leaderboard, () async {
          Get.bottomSheet(
            const SafeArea(
              child: Column(
                children: [Expanded(child: Center(child: LeaderBoardTypeBottomSheet()))],
              ),
            ),
            isScrollControlled: true,
            ignoreSafeArea: false,
            enableDrag: false,
          );
        }),
      );
    }

    final circularFabMenu = FabCircularMenuPlus(
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
          IconButton(icon: const Icon(Icons.info_rounded), onPressed: () => invokeLegendDialog()),
        ],
      ),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final data = await _database.activitys
                .where()
                .sortByStartDesc()
                .offset(page * limit)
                .limit(limit)
                .findAll();
            return ListItems(data, reachedToEnd: data.length < limit);
          },
        ),
        errorBuilder: (context, error, state) {
          return Column(
            children: [
              Text(error.toString()),
              ElevatedButton(onPressed: () => state.loadMore(), child: const Text('Retry')),
            ],
          );
        },
        empty: const Center(child: Text('No activities found')),
        itemBuilder: (context, _, item) {
          final activity = item as Activity;
          final dateString = DateFormat.yMd().format(activity.start);
          var timeString = DateFormat.Hms().format(activity.start);
          if (_uploadDisplayMode == uploadDisplayModeAggregate && activity.isUploaded(anyChoice)) {
            timeString += "\u2601";
          }

          final List<Widget> header = [
            ActivityDetailHeaderTextRow(
              themeManager: _themeManager,
              icon: Icons.calendar_today,
              iconSize: _sizeDefault2,
              text: dateString,
              textStyle: _headerStyle,
            ),
            ActivityDetailHeaderTextRow(
              themeManager: _themeManager,
              icon: Icons.access_time_filled,
              iconSize: _sizeDefault2,
              text: timeString,
              textStyle: _headerStyle,
            ),
          ];

          if (_machineNameInHeader) {
            header.add(
              ActivityDetailHeaderTextRow(
                themeManager: _themeManager,
                icon: getSportIcon(activity.sport),
                iconSize: _sizeDefault,
                text: activity.deviceName,
                textStyle: _headerStyle,
              ),
            );
          }

          if (_bluetoothAddressInHeader && activity.deviceId.isNotEmpty) {
            header.add(
              ActivityDetailHeaderTextRow(
                themeManager: _themeManager,
                icon: Icons.numbers,
                iconSize: _sizeDefault,
                text: activity.deviceId.shortAddressString(),
                textStyle: _headerStyle,
              ),
            );
          }

          if (_uploadDisplayMode == uploadDisplayModeDetailed && activity.isUploaded(anyChoice)) {
            List<Widget> uploadIcons = [];
            for (var portal in getPortalChoices(false, _themeManager)) {
              if (activity.isUploaded(portal.name)) {
                uploadIcons.add(portal.getSvg(true, _sizeDefault / 2));
              }
            }

            header.add(
              ActivityDetailHeaderRowBase(
                themeManager: _themeManager,
                icon: Icons.cloud_upload,
                iconSize: _sizeDefault,
                widget: Row(children: uploadIcons),
              ),
            );
          }

          List<Widget> body = [];
          if (!_machineNameInHeader) {
            body.add(
              ActivityDetailRowOneLine(
                themeManager: _themeManager,
                icon: getSportIcon(activity.sport),
                iconSize: _sizeDefault,
                text: activity.deviceName,
                textStyle: _textStyle,
              ),
            );
          }

          if (!_bluetoothAddressInHeader && activity.deviceId.isNotEmpty) {
            body.add(
              ActivityDetailRowOneLine(
                themeManager: _themeManager,
                icon: Icons.numbers,
                iconSize: _sizeDefault,
                text: activity.deviceId.shortAddressString(),
                textStyle: _textStyle,
              ),
            );
          }

          body.addAll([
            ActivityDetailRowWithSpacer(
              themeManager: _themeManager,
              icon: Icons.timer,
              iconSize: _sizeDefault,
              text: _timeDisplayMode == timeDisplayModeElapsed
                  ? activity.elapsedString
                  : activity.movingTimeString,
              textStyle: _measurementStyle,
            ),
            ActivityDetailRowWithUnit(
              themeManager: _themeManager,
              icon: Icons.add_road,
              iconSize: _sizeDefault,
              text: activity.distanceString(_si, _highRes),
              textStyle: _measurementStyle,
              unitText: distanceUnit(_si, _highRes),
              unitStyle: _unitStyle,
            ),
            ActivityDetailRowWithUnit(
              themeManager: _themeManager,
              icon: Icons.whatshot,
              iconSize: _sizeDefault,
              text: '${activity.calories}',
              textStyle: _measurementStyle,
              unitText: 'cal',
              unitStyle: _unitStyle,
            ),
            _actionButtonRow(activity, _sizeDefault2),
          ]);

          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key(activity.uniqueIntegrationString()),
              theme: _expandableThemeData,
              header: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: header,
              ),
              collapsed: Container(),
              expanded: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                minLeadingWidth: 0,
                horizontalTitleGap: 0,
                onTap: () =>
                    Get.to(() => ActivityDetailsScreen(activity: item, size: Get.mediaQuery.size)),
                title: Column(children: body),
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
