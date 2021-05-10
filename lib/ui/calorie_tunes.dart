import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import '../persistence/models/calorie_tune.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../utils/constants.dart';
import 'parts/calorie_factor_tune.dart';

class CalorieTunesScreen extends StatefulWidget {
  CalorieTunesScreen({key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CalorieTunesScreenState();
  }
}

class CalorieTunesScreenState extends State<CalorieTunesScreen> {
  AppDatabase _database;
  int _editCount;
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
    _editCount = 0;
    _database = Get.find<AppDatabase>();
  }

  Widget _actionButtonRow(CalorieTune calorieTune, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.black, size: size),
          onPressed: () async {
            final result = await Get.bottomSheet(
              CalorieFactorTuneBottomSheet(
                deviceId: calorieTune.mac,
                calorieFactor: calorieTune.calorieFactor,
              ),
              enableDrag: false,
            );
            if (result != null) {
              setState(() {
                _editCount++;
              });
            }
          },
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.redAccent, size: size),
          onPressed: () async {
            Get.defaultDialog(
              title: 'Warning!!!',
              middleText: 'Are you sure to delete this Tune?',
              confirm: TextButton(
                child: Text("Yes"),
                onPressed: () async {
                  await _database.calorieTuneDao.deleteCalorieTune(calorieTune);
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
      appBar: AppBar(title: Text('Calorie Tunes')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final offset = page * limit;
            final data = await _database.calorieTuneDao.findCalorieTunes(limit, offset);
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
          child: Text('No tunes found'),
        ),
        itemBuilder: (context, _, item) {
          final calorieTune = item as CalorieTune;
          final timeStamp = DateTime.fromMillisecondsSinceEpoch(calorieTune.time);
          final dateString = DateFormat.yMd().format(timeStamp);
          final timeString = DateFormat.Hms().format(timeStamp);
          final caloriePercent = (calorieTune.calorieFactor * 100).round();
          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key("${calorieTune.id}"),
              header: Column(
                children: [
                  TextOneLine(
                    calorieTune.mac,
                    style: _textStyle,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextOneLine(
                    "$caloriePercent %",
                    style: _textStyle.apply(fontSizeFactor: 2.0),
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
                    _actionButtonRow(calorieTune, _sizeDefault),
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
