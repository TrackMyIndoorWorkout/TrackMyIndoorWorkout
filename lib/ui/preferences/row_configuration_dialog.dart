import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/measurement_ui_state.dart';
import '../../preferences/metric_spec.dart';
import '../../providers/theme_mode.dart';
import '../../utils/theme_manager.dart';

class RowConfigurationDialog extends ConsumerStatefulWidget {
  const RowConfigurationDialog({Key? key}) : super(key: key);

  @override
  RowConfigurationDialogState createState() => RowConfigurationDialogState();
}

class RowConfigurationDialogState extends ConsumerState<RowConfigurationDialog> {
  List<bool> _expandedState = [];
  final List<int> _expandedHeights = [];

  @override
  void initState() {
    super.initState();

    final prefService = Get.find<BasePrefService>();
    final expandedStateStr =
        prefService.get<String>(measurementPanelsExpandedTag) ?? measurementPanelsExpandedDefault;
    final expandedHeightStr =
        prefService.get<String>(measurementDetailSizeTag) ?? measurementDetailSizeDefault;
    _expandedState = List<bool>.generate(expandedStateStr.length, (int index) {
      final expanded = expandedStateStr[index] == "1";
      final expandedHeight = int.tryParse(expandedHeightStr[index]) ?? 0;
      _expandedHeights.add(expandedHeight);
      return expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Get.find<ThemeManager>();
    final themeMode = ref.watch(themeModeProvider);
    final textStyle = Theme.of(context).textTheme.headline3!.apply(
          color: themeManager.getProtagonistColor(themeMode),
        );

    var rowConfigs = MetricSpec.getRowConfigurations();
    List<Widget> children = [
      Container(),
      Text("\u00BC", style: textStyle),
      Text("\u2153", style: textStyle),
      Text("\u00BD", style: textStyle),
      Icon(Icons.keyboard_arrow_right, size: textStyle.fontSize),
    ];
    rowConfigs.forEachIndexed((rowIndex, rowConfig) {
      children.add(Icon(rowConfig.icon, size: textStyle.fontSize));
      children.addAll(
        List<Widget>.generate(
          3,
          (index) => rowIndex < 4
              ? Transform.scale(
                  scale: 2,
                  child: Radio<int>(
                    value: index,
                    groupValue: _expandedHeights[rowIndex],
                    onChanged: (int? value) {
                      if (value == null) return;

                      setState(() {
                        _expandedHeights[rowIndex] = index;
                        applyDetailSizes(_expandedHeights);
                      });
                    },
                  ),
                )
              : Container(),
        ),
      );

      children.add(
        Transform.scale(
          scale: 2,
          child: Checkbox(
            value: _expandedState[rowIndex],
            onChanged: (bool? value) {
              if (value == null) return;

              setState(() {
                _expandedState[rowIndex] = value;
                applyExpandedStates(_expandedState);
              });
            },
          ),
        ),
      );
    });

    return SizedBox(
      width: Get.mediaQuery.size.width * 0.8,
      height: Get.mediaQuery.size.width * 0.8 / 5 * 6,
      child: GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        childAspectRatio: 1.0,
        children: children
            .map(
              (w) => GridTile(
                child: Center(child: w),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
