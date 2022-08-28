import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:pref/pref.dart';
import '../../utils/constants.dart';
import '../../persistence/database.dart';
import '../../preferences/speed_spec.dart';
import '../../preferences/sport_spec.dart';
import '../../persistence/models/workout_summary.dart';
import '../../preferences/distance_resolution.dart';
import '../../preferences/generic.dart';
import '../../preferences/unit_system.dart';
import '../../providers/theme_mode.dart';
import '../../utils/theme_manager.dart';

class SportLeaderboardScreen extends ConsumerStatefulWidget {
  final String sport;

  const SportLeaderboardScreen({key, required this.sport}) : super(key: key);

  @override
  SportLeaderboardScreenState createState() => SportLeaderboardScreenState();
}

class SportLeaderboardScreenState extends ConsumerState<SportLeaderboardScreen>
    with WidgetsBindingObserver {
  final AppDatabase _database = Get.find<AppDatabase>();
  bool _si = unitSystemDefault;
  bool _highRes = distanceResolutionDefault;
  int _editCount = 0;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  ExpandableThemeData _expandableThemeData = const ExpandableThemeData(iconColor: Colors.black);
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
    final themeMode = ref.watch(themeModeProvider);
    _expandableThemeData = ExpandableThemeData(
      iconColor: _themeManager.getProtagonistColor(themeMode),
    );
    if (widget.sport != ActivityType.ride) {
      _slowSpeed = SpeedSpec.slowSpeeds[SportSpec.sport2Sport(widget.sport)]!;
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
                onPressed: () async {
                  await _database.workoutSummaryDao.deleteWorkoutSummary(workoutSummary);
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final textStyle = Theme.of(context).textTheme.headline5!.apply(
          fontFamily: fontFamily,
          color: _themeManager.getProtagonistColor(themeMode),
        );
    final sizeDefault = textStyle.fontSize!;
    final textStyle2 = _themeManager.getBlueTextStyle(sizeDefault, themeMode);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.sport} Leaderboard')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final offset = page * limit;
            final data = await _database.workoutSummaryDao
                .findWorkoutSummaryBySport(widget.sport, limit, offset);
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
          final timeStamp = DateTime.fromMillisecondsSinceEpoch(workoutSummary.start);
          final dateString = DateFormat.yMd().format(timeStamp);
          final timeString = DateFormat.Hms().format(timeStamp);
          final speedString = workoutSummary.speedString(_si, _slowSpeed);
          final distanceString = workoutSummary.distanceStringWithUnit(_si, _highRes);
          final timeDisplay = Duration(seconds: workoutSummary.elapsed).toDisplay();
          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key("${workoutSummary.id}"),
              theme: _expandableThemeData,
              header: Column(
                children: [
                  Row(
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
                            '($distanceString /',
                            style: textStyle,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                          TextOneLine(
                            '$timeDisplay)',
                            style: textStyle,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextOneLine(
                    workoutSummary.deviceName,
                    style: textStyle,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
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
