import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:listview_utils_plus/listview_utils_plus.dart';

import '../persistence/isar/device_usage.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import '../utils/string_ex.dart';
import '../utils/theme_manager.dart';
import 'parts/sport_picker.dart';

class DeviceUsagesScreen extends StatefulWidget {
  const DeviceUsagesScreen({key}) : super(key: key);

  @override
  DeviceUsagesScreenState createState() => DeviceUsagesScreenState();
}

class DeviceUsagesScreenState extends State<DeviceUsagesScreen> with WidgetsBindingObserver {
  final _database = Get.find<Isar>();
  int _editCount = 0;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  double _sizeDefault = 10.0;
  TextStyle _textStyle = const TextStyle();
  ExpandableThemeData _expandableThemeData = const ExpandableThemeData(iconColor: Colors.black);

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
    _textStyle = Get.textTheme.headlineSmall!
        .apply(fontFamily: fontFamily, color: _themeManager.getProtagonistColor());
    _sizeDefault = _textStyle.fontSize!;
    _expandableThemeData = ExpandableThemeData(iconColor: _themeManager.getProtagonistColor());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _actionButtonRow(DeviceUsage deviceUsage, double size) {
    return Row(
      children: [
        IconButton(
          icon: _themeManager.getActionIcon(Icons.edit, size),
          iconSize: size,
          onPressed: () async {
            final sportPick = await Get.bottomSheet(
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SportPickerBottomSheet(
                          sportChoices: allSports,
                          initialSport: deviceUsage.sport,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              isScrollControlled: true,
              ignoreSafeArea: false,
              enableDrag: false,
            );
            if (sportPick != null) {
              deviceUsage.sport = sportPick;
              deviceUsage.time = DateTime.now();
              await _database.writeTxn(() async {
                await _database.deviceUsages.put(deviceUsage);
                setState(() {
                  _editCount++;
                });
              });
            }
          },
        ),
        const Spacer(),
        IconButton(
          icon: _themeManager.getDeleteIcon(size),
          iconSize: size,
          onPressed: () async {
            Get.defaultDialog(
              title: 'Warning!!!',
              middleText: 'Are you sure to delete this Usage?',
              confirm: TextButton(
                child: const Text("Yes"),
                onPressed: () async {
                  await _database.writeTxn(() async {
                    await _database.deviceUsages.delete(deviceUsage.id);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Device Usages')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final data = await _database.deviceUsages
                .where()
                .sortByTimeDesc()
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
          child: Text('No usages found'),
        ),
        itemBuilder: (context, _, item) {
          final deviceUsage = item as DeviceUsage;
          final dateString = DateFormat.yMd().format(deviceUsage.time);
          final timeString = DateFormat.Hms().format(deviceUsage.time);
          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key("${deviceUsage.id}"),
              theme: _expandableThemeData,
              header: Column(
                children: [
                  TextOneLine(
                    deviceUsage.name,
                    style: _textStyle,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextOneLine(
                    deviceUsage.mac.shortAddressString(),
                    style: _textStyle,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _themeManager.getBlueIcon(getSportIcon(deviceUsage.sport), _sizeDefault),
                      Text(deviceUsage.sport, style: _textStyle),
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
