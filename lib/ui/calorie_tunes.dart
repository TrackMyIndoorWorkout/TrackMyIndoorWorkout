import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:listview_utils_plus/listview_utils_plus.dart';

import '../persistence/calorie_tune.dart';
import '../providers/theme_mode.dart';
import '../utils/string_ex.dart';
import '../utils/theme_manager.dart';
import 'parts/calorie_factor_tune.dart';

class CalorieTunesScreen extends ConsumerStatefulWidget {
  const CalorieTunesScreen({super.key});

  @override
  CalorieTunesScreenState createState() => CalorieTunesScreenState();
}

class CalorieTunesScreenState extends ConsumerState<CalorieTunesScreen>
    with WidgetsBindingObserver {
  final _database = Get.find<Isar>();
  int _editCount = 0;
  final ThemeManager _themeManager = Get.find<ThemeManager>();

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _actionButtonRow(CalorieTune calorieTune, double size, ThemeMode themeMode) {
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
                        child: CalorieFactorTuneBottomSheet(calorieTune: calorieTune),
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
                onPressed: () {
                  _database.writeTxnSync(() {
                    _database.calorieTunes.deleteSync(calorieTune.id);
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
    final textStyle = Theme.of(context).textTheme.headlineMedium!;
    final sizeDefault = textStyle.fontSize!;
    final themeMode = ref.watch(themeModeProvider);
    final expandableThemeData = ExpandableThemeData(
      iconColor: _themeManager.getProtagonistColor(themeMode),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Calorie Tunes')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final data = await _database.calorieTunes
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
          child: Text('No tunes found'),
        ),
        itemBuilder: (context, _, item) {
          final calorieTune = item as CalorieTune;
          final dateString = DateFormat.yMd().format(calorieTune.time);
          final timeString = DateFormat.Hms().format(calorieTune.time);
          final hrBasedString = calorieTune.hrBased ? "HR based" : "Non HR based";
          final caloriePercent = (calorieTune.calorieFactor * 100).round();
          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key("${calorieTune.id}"),
              theme: expandableThemeData,
              header: Column(
                children: [
                  TextOneLine(
                    calorieTune.mac.shortAddressString(),
                    style: textStyle,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextOneLine(
                    "$caloriePercent %",
                    style: textStyle.apply(fontSizeFactor: 2.0),
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
                        _themeManager.getBlueIcon(Icons.calendar_today, sizeDefault, themeMode),
                        Text(dateString, style: textStyle),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _themeManager.getBlueIcon(Icons.watch, sizeDefault, themeMode),
                        Text(timeString, style: textStyle),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        calorieTune.hrBased
                            ? _themeManager.getBlueIcon(Icons.favorite, sizeDefault, themeMode)
                            : _themeManager.getGreyIcon(Icons.favorite, sizeDefault, themeMode),
                        Text(hrBasedString, style: textStyle),
                      ],
                    ),
                    _actionButtonRow(calorieTune, sizeDefault, themeMode),
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
