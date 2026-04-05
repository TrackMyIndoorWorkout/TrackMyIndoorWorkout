import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../preferences/measurement_ui_state.dart';
import '../../preferences/metric_spec.dart';
import '../../utils/theme_manager.dart';

class RowConfigurationDialog extends StatefulWidget {
  const RowConfigurationDialog({super.key});

  @override
  RowConfigurationDialogState createState() => RowConfigurationDialogState();
}

class RowConfigurationDialogState extends State<RowConfigurationDialog> {
  TextStyle _textStyle = const TextStyle();
  List<bool> _expandedState = [];
  final List<int> _expandedHeights = [];

  @override
  void initState() {
    super.initState();

    final themeManager = Get.find<ThemeManager>();
    _textStyle = Get.textTheme.displaySmall!.apply(color: themeManager.getProtagonistColor());
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
    final gridChildren = <Widget>[];

    // Header Row
    gridChildren.add(
      GridPlacement(
        columnStart: 1,
        columnSpan: 3,
        rowStart: 0,
        child: Center(child: Text("Size", style: _textStyle)),
      ),
    );
    gridChildren.add(
      GridPlacement(
        columnStart: 4,
        rowStart: 0,
        child: Center(child: Icon(Icons.keyboard_arrow_right, size: _textStyle.fontSize)),
      ),
    );

    // Metric Rows
    rowConfigs.forEachIndexed((rowIndex, rowConfig) {
      final gridRow = rowIndex + 1;
      gridChildren.add(
        GridPlacement(
          columnStart: 0,
          rowStart: gridRow,
          child: Center(child: Icon(rowConfig.icon, size: _textStyle.fontSize)),
        ),
      );

      if (rowIndex < 4) {
        gridChildren.add(
          GridPlacement(
            columnStart: 1,
            columnSpan: 3,
            rowStart: gridRow,
            child: Center(
              child: ToggleButtons(
                isSelected: List.generate(3, (index) => index == _expandedHeights[rowIndex]),
                onPressed: (int index) {
                  setState(() {
                    _expandedHeights[rowIndex] = index;
                    applyDetailSizes(_expandedHeights);
                  });
                },
                children: <Widget>[
                  Text(' ¼ ', style: _textStyle),
                  Text(' ⅓ ', style: _textStyle),
                  Text(' ½ ', style: _textStyle),
                ],
              ),
            ),
          ),
        );
      } else {
        gridChildren.add(
          GridPlacement(columnStart: 1, columnSpan: 3, rowStart: gridRow, child: Container()),
        );
      }

      gridChildren.add(
        GridPlacement(
          columnStart: 4,
          rowStart: gridRow,
          child: Center(
            child: Transform.scale(
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
          ),
        ),
      );
    });

    return SizedBox(
      width: Get.mediaQuery.size.width * 0.8,
      height: Get.mediaQuery.size.width * 0.8 / 5 * 6,
      child: LayoutGrid(
        columnSizes: [auto, 1.fr, 1.fr, 1.fr, auto],
        rowSizes: List.generate(rowConfigs.length + 1, (_) => auto),
        children: gridChildren,
      ),
    );
  }
}
