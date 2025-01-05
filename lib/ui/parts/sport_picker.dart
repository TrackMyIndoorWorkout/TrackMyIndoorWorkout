import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../providers/theme_mode.dart';
import '../../utils/display.dart';
import '../../utils/theme_manager.dart';

class SportPickerBottomSheet extends ConsumerStatefulWidget {
  final List<String> sportChoices;
  final String initialSport;

  const SportPickerBottomSheet({
    super.key,
    required this.sportChoices,
    required this.initialSport,
  });

  @override
  SportPickerBottomSheetState createState() => SportPickerBottomSheetState();
}

class SportPickerBottomSheetState extends ConsumerState<SportPickerBottomSheet> {
  int _sportIndex = 0;

  @override
  void initState() {
    super.initState();
    _sportIndex = max(0, widget.sportChoices.indexOf(widget.initialSport));
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeManager = Get.find<ThemeManager>();
    final largerTextStyle = Theme.of(context).textTheme.headlineMedium!;
    final selectedTextStyle = largerTextStyle.apply(
      color: themeManager.getProtagonistColor(themeMode),
    );

    return Scaffold(
      body: ListView(
        children: widget.sportChoices
            .asMap()
            .entries
            .map(
              (e) => Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 2,
                    child: Radio(
                      value: e.key,
                      groupValue: _sportIndex,
                      onChanged: (value) {
                        setState(() {
                          _sportIndex = value as int;
                        });
                      },
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _sportIndex = e.key;
                      });
                    },
                    icon: themeManager.getBlueIcon(
                        getSportIcon(e.value), largerTextStyle.fontSize!),
                    label: TextOneLine(
                      e.value,
                      style: _sportIndex == e.key ? selectedTextStyle : largerTextStyle,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
            .toList(growable: false),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: themeManager.getGreenFab(
        Icons.check,
        themeMode,
        () => Get.back(result: widget.sportChoices[_sportIndex]),
      ),
    );
  }
}
