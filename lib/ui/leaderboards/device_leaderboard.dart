import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:listview_utils_plus/listview_utils_plus.dart';
import 'package:pref/pref.dart';
import 'package:tuple/tuple.dart';

import '../../persistence/workout_summary.dart';
import '../../preferences/distance_resolution.dart';
import '../../preferences/speed_spec.dart';
import '../../preferences/sport_spec.dart';
import '../../preferences/unit_system.dart';
import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';
import '../../utils/theme_manager.dart';

class DeviceLeaderboardScreen extends ConsumerStatefulWidget {
  final Tuple3<String, String, String> device;

  const DeviceLeaderboardScreen({super.key, required this.device});

  @override
  DeviceLeaderboardScreenState createState() => DeviceLeaderboardScreenState();
}

class DeviceLeaderboardScreenState extends ConsumerState<DeviceLeaderboardScreen>
    with WidgetsBindingObserver {
  final _database = Get.find<Isar>();
  bool _si = unitSystemDefault;
  bool _highRes = distanceResolutionDefault;
  int _editCount = 0;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  double? _slowSpeed;

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
    _si = Get.find<BasePrefService>().get<bool>(unitSystemTag) ?? unitSystemDefault;
    _highRes =
        Get.find<BasePrefService>().get<bool>(distanceResolutionTag) ?? distanceResolutionDefault;
    if (widget.device.item3 != ActivityType.ride) {
      _slowSpeed = SpeedSpec.slowSpeeds[SportSpec.sport2Sport(widget.device.item3)]!;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _actionButtonRow(WorkoutSummary workoutSummary, double size, ThemeMode themeMode) {
    return Row(
      children: [
        IconButton(
          icon: _themeManager.getDeleteIcon(size, themeMode),
          iconSize: size,
          onPressed: () async {
            Get.defaultDialog(
              title: 'Warning!!!',
              middleText: 'Are you sure to delete this entry?',
              confirm: TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  _database.writeTxnSync(() {
                    _database.workoutSummarys.deleteSync(workoutSummary.id);
                    setState(() {
                      _editCount++;
                    });
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final textStyle = Theme.of(context).textTheme.headlineSmall!.apply(
          fontFamily: fontFamily,
          color: _themeManager.getProtagonistColor(themeMode),
        );
    final sizeDefault = textStyle.fontSize!;
    final textStyle2 = _themeManager.getBlueTextStyle(sizeDefault, themeMode);
    final expandableThemeData = ExpandableThemeData(
      iconColor: _themeManager.getProtagonistColor(themeMode),
    );

    return Scaffold(
      appBar: AppBar(title: Text('${widget.device.item1} Leaderboard')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final data = await _database.workoutSummarys
                .filter()
                .deviceIdEqualTo(widget.device.item2)
                .sortBySpeedDesc()
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
              ElevatedButton(
                onPressed: () => state.loadMore(),
                child: const Text('Retry'),
              ),
            ],
          );
        },
        empty: const Center(
          child: Text('No entries found'),
        ),
        itemBuilder: (context, index, item) {
          final workoutSummary = item as WorkoutSummary;
          final dateString = DateFormat.yMd().format(workoutSummary.start);
          final timeString = DateFormat.Hms().format(workoutSummary.start);
          final speedString = workoutSummary.speedString(_si, _slowSpeed);
          final distanceString = workoutSummary.distanceStringWithUnit(_si, _highRes);
          final timeDisplay = Duration(seconds: workoutSummary.elapsed).toDisplay();
          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key("${workoutSummary.id}"),
              theme: expandableThemeData,
              header: Row(
                children: [
                  SizedBox(
                    width: sizeDefault * 2,
                    height: sizeDefault * 2,
                    child: _themeManager.getRankIcon(index, themeMode, context),
                  ),
                  Column(
                    children: [
                      TextOneLine(
                        speedString,
                        style: textStyle2,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextOneLine(
                        '($distanceString',
                        style: textStyle,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextOneLine(
                        ' / $timeDisplay)',
                        style: textStyle,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
              collapsed: Container(),
              expanded: ListTile(
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.calendar_today, sizeDefault, themeMode),
                        Text(dateString, style: textStyle),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.watch, sizeDefault, themeMode),
                        Text(timeString, style: textStyle),
                      ],
                    ),
                    _actionButtonRow(workoutSummary, sizeDefault, themeMode),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
