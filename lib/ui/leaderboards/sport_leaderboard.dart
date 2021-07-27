import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:pref/pref.dart';
import '../../utils/constants.dart';
import '../../persistence/database.dart';
import '../../persistence/models/workout_summary.dart';
import '../../persistence/preferences.dart';
import '../../utils/theme_manager.dart';

class SportLeaderboardScreen extends StatefulWidget {
  final String sport;

  SportLeaderboardScreen({key, required this.sport}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SportLeaderboardScreenState();
}

class SportLeaderboardScreenState extends State<SportLeaderboardScreen> {
  AppDatabase _database = Get.find<AppDatabase>();
  bool _si = UNIT_SYSTEM_DEFAULT;
  bool _highRes = DISTANCE_RESOLUTION_DEFAULT;
  int _editCount = 0;
  double _sizeDefault = 10.0;
  TextStyle _textStyle = TextStyle();
  TextStyle _textStyle2 = TextStyle();
  ThemeManager _themeManager = Get.find<ThemeManager>();
  ExpandableThemeData _expandableThemeData = ExpandableThemeData(iconColor: Colors.black);

  @override
  void initState() {
    super.initState();
    _si = Get.find<BasePrefService>().get<bool>(UNIT_SYSTEM_TAG) ?? UNIT_SYSTEM_DEFAULT;
    _highRes = Get.find<BasePrefService>().get<bool>(DISTANCE_RESOLUTION_TAG) ??
        DISTANCE_RESOLUTION_DEFAULT;
    _textStyle = Get.textTheme.headline5!
        .apply(fontFamily: FONT_FAMILY, color: _themeManager.getProtagonistColor());
    _sizeDefault = _textStyle.fontSize!;
    _textStyle2 = _themeManager.getBlueTextStyle(_sizeDefault);
    _expandableThemeData = ExpandableThemeData(iconColor: _themeManager.getProtagonistColor());
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
                child: Text("Yes"),
                onPressed: () async {
                  await _database.workoutSummaryDao.deleteWorkoutSummary(workoutSummary);
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.sport} Leaderboard')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => Center(child: CircularProgressIndicator()),
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
                child: Text('Retry'),
              ),
            ],
          );
        },
        empty: Center(
          child: Text('No entries found'),
        ),
        itemBuilder: (context, index, item) {
          final workoutSummary = item as WorkoutSummary;
          final timeStamp = DateTime.fromMillisecondsSinceEpoch(workoutSummary.start);
          final dateString = DateFormat.yMd().format(timeStamp);
          final timeString = DateFormat.Hms().format(timeStamp);
          final speedString = workoutSummary.speedString(_si);
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
                            '($distanceString /',
                            style: _textStyle,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                          TextOneLine(
                            '$timeDisplay)',
                            style: _textStyle,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextOneLine(
                    workoutSummary.deviceName,
                    style: _textStyle,
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
