import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:preferences/preferences.dart';
import 'package:tuple/tuple.dart';
import '../../persistence/database.dart';
import '../../persistence/models/workout_summary.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';

class DeviceLeaderboardScreen extends StatefulWidget {
  final Tuple2<String, String> device;

  DeviceLeaderboardScreen({key, @required this.device})
      : assert(device != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DeviceLeaderboardScreenState(device: device);
  }
}

class DeviceLeaderboardScreenState extends State<DeviceLeaderboardScreen> {
  final Tuple2<String, String> device;
  AppDatabase _database;
  bool _si;
  int _editCount;
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _textStyle;

  DeviceLeaderboardScreenState({@required this.device}) : assert(device != null);

  @override
  void initState() {
    super.initState();
    _editCount = 0;
    _database = Get.find<AppDatabase>();
    _si = PrefService.getBool(UNIT_SYSTEM_TAG);
  }

  Widget _actionButtonRow(WorkoutSummary workoutSummary, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.delete, color: Colors.redAccent, size: size),
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
    final mediaWidth = Get.mediaQuery.size.width;
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = _mediaWidth / 12;
      _textStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('${device.item2} Leaderboard')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final offset = page * limit;
            final data = await _database.workoutSummaryDao
                .findWorkoutSummaryByDevice(device.item1, limit, offset);
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
          final distanceString = workoutSummary.distanceStringWithUnit(_si);
          final timeDisplay = Duration(seconds: workoutSummary.elapsed).toDisplay();
          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key("${workoutSummary.id}"),
              header: Column(
                children: [
                  TextOneLine(
                    '$index. $speedString',
                    style: _textStyle,
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
              expanded: ListTile(
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.indigo,
                          size: _sizeDefault,
                        ),
                        Text(
                          dateString,
                          style: _textStyle,
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
                          size: _sizeDefault,
                        ),
                        Text(
                          timeString,
                          style: _textStyle,
                        ),
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
