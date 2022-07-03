import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:pref/pref.dart';
import 'package:tuple/tuple.dart';
import '../../persistence/database.dart';
import '../../persistence/models/workout_summary.dart';
import '../../preferences/distance_resolution.dart';
import '../../preferences/generic.dart';
import '../../preferences/speed_spec.dart';
import '../../preferences/sport_spec.dart';
import '../../preferences/unit_system.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class DeviceLeaderboardScreen extends StatefulWidget {
  final Tuple3<String, String, String> device;

  const DeviceLeaderboardScreen({key, required this.device}) : super(key: key);

  @override
  DeviceLeaderboardScreenState createState() => DeviceLeaderboardScreenState();
}

class DeviceLeaderboardScreenState extends State<DeviceLeaderboardScreen>
    with WidgetsBindingObserver {
  final AppDatabase _database = Get.find<AppDatabase>();
  bool _si = unitSystemDefault;
  bool _highRes = distanceResolutionDefault;
  int _editCount = 0;
  double _sizeDefault = 10.0;
  TextStyle _textStyle = const TextStyle();
  TextStyle _textStyle2 = const TextStyle();
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
    _textStyle = Get.textTheme.headline5!
        .apply(fontFamily: fontFamily, color: _themeManager.getProtagonistColor());
    _sizeDefault = _textStyle.fontSize!;
    _textStyle2 = _themeManager.getBlueTextStyle(_sizeDefault);
    _expandableThemeData = ExpandableThemeData(iconColor: _themeManager.getProtagonistColor());
    if (widget.device.item3 != ActivityType.ride) {
      _slowSpeed = SpeedSpec.slowSpeeds[SportSpec.sport2Sport(widget.device.item3)]!;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _actionButtonRow(WorkoutSummary workoutSummary, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: _themeManager.getDeleteIcon(size),
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
    return Scaffold(
      appBar: AppBar(title: Text('${widget.device.item2} Leaderboard')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final offset = page * limit;
            final data = await _database.workoutSummaryDao
                .findWorkoutSummaryByDevice(widget.device.item1, limit, offset);
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
              header: Row(
                children: [
                  SizedBox(
                    width: _sizeDefault * 2,
                    height: _sizeDefault * 2,
                    child: _themeManager.getRankIcon(index),
                  ),
                  Column(
                    children: [
                      TextOneLine(
                        speedString,
                        style: _textStyle2,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextOneLine(
                        '($distanceString',
                        style: _textStyle,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                      TextOneLine(
                        ' / $timeDisplay)',
                        style: _textStyle,
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
                        _themeManager.getBlueIcon(Icons.calendar_today, _sizeDefault),
                        Text(dateString, style: _textStyle),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.watch, _sizeDefault),
                        Text(timeString, style: _textStyle),
                      ],
                    ),
                    _actionButtonRow(workoutSummary, _sizeDefault),
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
