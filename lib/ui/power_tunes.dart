import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import '../persistence/models/power_tune.dart';
import '../persistence/database.dart';
import '../utils/theme_manager.dart';
import 'parts/power_factor_tune.dart';

class PowerTunesScreen extends StatefulWidget {
  PowerTunesScreen({key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PowerTunesScreenState();
  }
}

class PowerTunesScreenState extends State<PowerTunesScreen> {
  AppDatabase _database;
  int _editCount;
  double _sizeDefault;
  TextStyle _textStyle;
  ThemeManager _themeManager;
  ExpandableThemeData _expandableThemeData;

  @override
  void initState() {
    super.initState();
    _editCount = 0;
    _database = Get.find<AppDatabase>();
    _themeManager = Get.find<ThemeManager>();
    _textStyle = Get.textTheme.headline3;
    _sizeDefault = _textStyle.fontSize;
    _expandableThemeData = ExpandableThemeData(iconColor: _themeManager.getProtagonistColor());
  }

  Widget _actionButtonRow(PowerTune powerTune, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: _themeManager.getActionIcon(Icons.edit, size),
          onPressed: () async {
            final result = await Get.bottomSheet(
              PowerFactorTuneBottomSheet(
                deviceId: powerTune.mac,
                powerFactor: powerTune.powerFactor,
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
                  await _database.powerTuneDao.deletePowerTune(powerTune);
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
      appBar: AppBar(title: Text('Power Tunes')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final offset = page * limit;
            final data = await _database.powerTuneDao.findPowerTunes(limit, offset);
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
          final powerTune = item as PowerTune;
          final timeStamp = DateTime.fromMillisecondsSinceEpoch(powerTune.time);
          final dateString = DateFormat.yMd().format(timeStamp);
          final timeString = DateFormat.Hms().format(timeStamp);
          final powerPercent = (powerTune.powerFactor * 100).round();
          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key("${powerTune.id}"),
              theme: _expandableThemeData,
              header: Column(
                children: [
                  TextOneLine(
                    powerTune.mac,
                    style: _textStyle,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextOneLine(
                    "$powerPercent %",
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
                        _themeManager.getBlueIcon(Icons.calendar_today, _sizeDefault),
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
                        _themeManager.getBlueIcon(Icons.watch, _sizeDefault),
                        Text(
                          timeString,
                          style: _textStyle,
                        ),
                      ],
                    ),
                    _actionButtonRow(powerTune, _sizeDefault),
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
