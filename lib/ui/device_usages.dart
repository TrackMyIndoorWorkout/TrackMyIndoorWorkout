import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import '../persistence/models/device_usage.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import 'parts/sport_picker.dart';

class DeviceUsagesScreen extends StatefulWidget {
  DeviceUsagesScreen({key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DeviceUsagesScreenState();
  }
}

class DeviceUsagesScreenState extends State<DeviceUsagesScreen> {
  AppDatabase _database;
  int _editCount;
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _headerStyle;

  @override
  void initState() {
    super.initState();
    _editCount = 0;
    _database = Get.find<AppDatabase>();
  }

  Widget _actionButtonRow(DeviceUsage deviceUsage, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.black, size: size),
          onPressed: () async {
            final sportPick = await Get.bottomSheet(
              SportPickerBottomSheet(initialSport: deviceUsage.sport, allSports: true),
              isDismissible: false,
              enableDrag: false,
            );
            if (sportPick != null) {
              deviceUsage.sport = sportPick;
              deviceUsage.time = DateTime.now().millisecondsSinceEpoch;
              await _database?.deviceUsageDao?.updateDeviceUsage(deviceUsage);
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
              middleText: 'Are you sure to delete this Usage?',
              confirm: TextButton(
                child: Text("Yes"),
                onPressed: () async {
                  await _database.deviceUsageDao.deleteDeviceUsage(deviceUsage);
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
      _headerStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Device Usages')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int offset, int limit) async {
            final data = await _database.deviceUsageDao.findDeviceUsages(offset, limit);
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
          child: Text('No usages found'),
        ),
        itemBuilder: (context, _, item) {
          final deviceUsage = item as DeviceUsage;
          final timeStamp = DateTime.fromMillisecondsSinceEpoch(deviceUsage.time);
          final dateString = DateFormat.yMd().format(timeStamp);
          final timeString = DateFormat.Hms().format(timeStamp);
          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key("${deviceUsage.id}"),
              header: Column(
                children: [
                  TextOneLine(
                    deviceUsage.name,
                    style: _headerStyle,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextOneLine(
                    deviceUsage.mac,
                    style: _headerStyle,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        getIcon(deviceUsage.sport),
                        color: Colors.indigo,
                        size: _sizeDefault,
                      ),
                      Text(
                        deviceUsage.sport,
                        style: _headerStyle,
                      ),
                    ],
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
                          style: _headerStyle,
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
                          style: _headerStyle,
                        ),
                      ],
                    ),
                    _actionButtonRow(deviceUsage, _sizeDefault),
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
