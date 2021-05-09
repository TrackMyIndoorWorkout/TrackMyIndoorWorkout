import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import '../persistence/models/power_tune.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../utils/constants.dart';

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
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
    _editCount = 0;
    _database = Get.find<AppDatabase>();
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
          return Card(
            elevation: 6,
            child: Column(
              key: Key("${powerTune.id}"),
              children: [
                TextOneLine(
                  powerTune.mac,
                  style: _textStyle,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
                TextOneLine(
                  powerTune.powerFactor.toPrecision(3).toString(),
                  style: _textStyle.apply(fontSizeFactor: 2.0),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
