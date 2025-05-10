import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:listview_utils_plus/listview_utils_plus.dart';

import '../persistence/calorie_tune.dart';
import '../utils/string_ex.dart';
import '../utils/theme_manager.dart';
import 'parts/calorie_factor_tune.dart';

class CalorieTunesScreen extends StatefulWidget {
  const CalorieTunesScreen({super.key});

  @override
  CalorieTunesScreenState createState() => CalorieTunesScreenState();
}

class CalorieTunesScreenState extends State<CalorieTunesScreen> with WidgetsBindingObserver {
  final _database = Get.find<Isar>();
  int _editCount = 0;
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _textStyle = const TextStyle();
  double _sizeDefault = 10.0;
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

  Widget _actionButtonRow(CalorieTune calorieTune, double size) {
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
                      child: Center(child: CalorieFactorTuneBottomSheet(calorieTune: calorieTune)),
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
      appBar: AppBar(title: const Text('Calorie Tunes')),
      body: CustomListView(
        key: Key("CLV$_editCount"),
        paginationMode: PaginationMode.page,
        initialOffset: 0,
        loadingBuilder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
        adapter: ListAdapter(
          fetchItems: (int page, int limit) async {
            final data =
                await _database.calorieTunes
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
          final calorieTune = item as CalorieTune;
          final dateString = DateFormat.yMd().format(calorieTune.time);
          final timeString = DateFormat.Hms().format(calorieTune.time);
          final hrBasedString = calorieTune.hrBased ? "HR based" : "Non HR based";
          final caloriePercent = (calorieTune.calorieFactor * 100).round();
          return Card(
            elevation: 6,
            child: ExpandablePanel(
              key: Key("${calorieTune.id}"),
              theme: _expandableThemeData,
              header: Column(
                children: [
                  TextOneLine(
                    calorieTune.mac.shortAddressString(),
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
                        _themeManager.getBlueIcon(Icons.access_time_filled, _sizeDefault),
                        Text(timeString, style: _textStyle),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        calorieTune.hrBased
                            ? _themeManager.getBlueIcon(Icons.favorite, _sizeDefault)
                            : _themeManager.getGreyIcon(Icons.favorite, _sizeDefault),
                        Text(hrBasedString, style: _textStyle),
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
