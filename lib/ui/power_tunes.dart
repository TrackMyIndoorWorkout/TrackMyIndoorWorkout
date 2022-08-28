import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';
import '../persistence/models/power_tune.dart';
import '../persistence/database.dart';
import '../providers/theme_mode.dart';
import '../utils/theme_manager.dart';
import 'parts/power_factor_tune.dart';

class PowerTunesScreen extends ConsumerStatefulWidget {
  const PowerTunesScreen({key}) : super(key: key);

  @override
  PowerTunesScreenState createState() => PowerTunesScreenState();
}

class PowerTunesScreenState extends ConsumerState<PowerTunesScreen> with WidgetsBindingObserver {
  final AppDatabase _database = Get.find<AppDatabase>();
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
    _textStyle = Get.textTheme.headline4!;
    _sizeDefault = _textStyle.fontSize!;
    final themeMode = ref.watch(themeModeProvider);
    _expandableThemeData = ExpandableThemeData(
      iconColor: _themeManager.getProtagonistColor(themeMode),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _actionButtonRow(PowerTune powerTune, double size, ThemeMode themeMode) {
    return Row(
      children: [
        IconButton(
          icon: _themeManager.getActionIcon(Icons.edit, size, themeMode),
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
          icon: _themeManager.getDeleteIcon(size, themeMode),
          iconSize: size,
          onPressed: () async {
            Get.defaultDialog(
              title: 'Warning!!!',
              middleText: 'Are you sure to delete this Tune?',
              confirm: TextButton(
                child: const Text("Yes"),
                onPressed: () async {
                  await _database.powerTuneDao.deletePowerTune(powerTune);
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
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Power Tunes')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
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
                child: const Text('Retry'),
              ),
            ],
          );
        },
        empty: const Center(
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
              collapsed: Container(),
              expanded: ListTile(
                title: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.calendar_today, _sizeDefault, themeMode),
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
                        _themeManager.getBlueIcon(Icons.watch, _sizeDefault, themeMode),
                        Text(
                          timeString,
                          style: _textStyle,
                        ),
                      ],
                    ),
                    _actionButtonRow(powerTune, _sizeDefault, themeMode),
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
