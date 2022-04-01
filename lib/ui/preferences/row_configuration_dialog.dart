import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../preferences/measurement_ui_state.dart';
import '../../preferences/metric_spec.dart';
import '../../utils/theme_manager.dart';

class RowConfigurationDialog extends StatefulWidget {
  const RowConfigurationDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RowConfigurationDialogState();
}

class RowConfigurationDialogState extends State<RowConfigurationDialog> {
  TextStyle _textStyle = const TextStyle();
  List<bool> _expandedState = [];
  final List<int> _expandedHeights = [];

  @override
  void initState() {
    super.initState();

    final themeManager = Get.find<ThemeManager>();
    _textStyle = Get.textTheme.headline3!.apply(color: themeManager.getProtagonistColor());
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
    var rowConfigs = MetricSpec.getRowConfigurations();
    List<Widget> children = [
      Container(),
      Text("\u00BC", style: _textStyle),
      Text("\u2153", style: _textStyle),
      Text("\u00BD", style: _textStyle),
      Icon(Icons.keyboard_arrow_right, size: _textStyle.fontSize),
    ];
    rowConfigs.forEachIndexed((rowIndex, rowConfig) {
      children.add(Icon(rowConfig.icon, size: _textStyle.fontSize));
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
