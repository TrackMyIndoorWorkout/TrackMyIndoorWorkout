import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:listview_utils_plus/listview_utils_plus.dart';

import '../persistence/power_tune.dart';
import '../utils/string_ex.dart';
import '../utils/theme_manager.dart';
import 'parts/power_factor_tune.dart';

class PowerTunesScreen extends StatefulWidget {
  const PowerTunesScreen({super.key});

  @override
  PowerTunesScreenState createState() => PowerTunesScreenState();
}

class PowerTunesScreenState extends State<PowerTunesScreen> with WidgetsBindingObserver {
  final _database = Get.find<Isar>();
  int _editCount = 0;
  double _sizeDefault = 10.0;
  TextStyle _textStyle = const TextStyle();
  final ThemeManager _themeManager = Get.find<ThemeManager>();
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
    _textStyle = Get.textTheme.headlineMedium!;
    _sizeDefault = _textStyle.fontSize!;
    _expandableThemeData = ExpandableThemeData(iconColor: _themeManager.getProtagonistColor());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _actionButtonRow(PowerTune powerTune, double size) {
    return Row(
      children: [
        IconButton(
          icon: _themeManager.getActionIcon(Icons.edit, size),
          iconSize: size,
          onPressed: () async {
            final result = await Get.bottomSheet(
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: PowerFactorTuneBottomSheet(
                          deviceId: powerTune.mac,
                          oldPowerFactor: powerTune.powerFactor,
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
            if (result != null) {
              setState(() {
                _editCount++;
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
              middleText: 'Are you sure to delete this Tune?',
              confirm: TextButton(
                child: const Text("Yes"),
                onPressed: () async {
                  _database.writeTxnSync(() {
                    _database.powerTunes.deleteSync(powerTune.id);
                    setState(() {
                      _editCount++;
                    });
                  });
                  Get.close(1);
                },
              ),
              cancel: TextButton(child: const Text("No"), onPressed: () => Get.close(1)),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Power Tunes')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final data = await _database.powerTunes
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
              ElevatedButton(onPressed: () => state.loadMore(), child: const Text('Retry')),
            ],
          );
        },
        empty: const Center(child: Text('No tunes found')),
        itemBuilder: (context, _, item) {
          final powerTune = item as PowerTune;
          final dateString = DateFormat.yMd().format(powerTune.time);
          final timeString = DateFormat.Hms().format(powerTune.time);
          final powerPercent = (powerTune.powerFactor * 100).round();
          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key("${powerTune.id}"),
              theme: _expandableThemeData,
              header: Column(
                children: [
                  TextOneLine(
                    powerTune.mac.shortAddressString(),
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
                        _themeManager.getBlueIcon(Icons.access_time_filled, _sizeDefault),
                        Text(timeString, style: _textStyle),
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
