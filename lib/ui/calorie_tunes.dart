import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import '../persistence/models/calorie_tune.dart';
import '../persistence/database.dart';
import '../utils/theme_manager.dart';
import 'parts/calorie_factor_tune.dart';

class CalorieTunesScreen extends StatefulWidget {
  CalorieTunesScreen({key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CalorieTunesScreenState();
}

class CalorieTunesScreenState extends State<CalorieTunesScreen> {
  AppDatabase _database = Get.find<AppDatabase>();
  int _editCount = 0;
  ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _textStyle = TextStyle();
  double _sizeDefault = 10.0;
  ExpandableThemeData _expandableThemeData =
      ExpandableThemeData(iconColor: Get.find<ThemeManager>().getProtagonistColor());

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.headline3!;
    _sizeDefault = _textStyle.fontSize!;
  }

  Widget _actionButtonRow(CalorieTune calorieTune, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: _themeManager.getActionIcon(Icons.edit, size),
          onPressed: () async {
            final result = await Get.bottomSheet(
              CalorieFactorTuneBottomSheet(
                deviceId: calorieTune.mac,
                oldCalorieFactor: calorieTune.calorieFactor,
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
          icon: _themeManager.getDeleteIcon(size),
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
              theme: _expandableThemeData,
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
