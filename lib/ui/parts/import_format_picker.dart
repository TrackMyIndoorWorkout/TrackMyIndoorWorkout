import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../providers/theme_mode.dart';
import '../../utils/theme_manager.dart';

class ImportFormatPickerBottomSheet extends ConsumerStatefulWidget {
  const ImportFormatPickerBottomSheet({Key? key}) : super(key: key);

  @override
  ImportFormatPickerBottomSheetState createState() => ImportFormatPickerBottomSheetState();
}

class ImportFormatPickerBottomSheetState extends ConsumerState<ImportFormatPickerBottomSheet> {
  int _formatIndex = 0;
  final List<String> _formatChoices = [
    "MPower Echelon",
    "Migration",
  ];
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  TextStyle _largerTextStyle = const TextStyle();
  TextStyle _selectedTextStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _formatIndex = max(0, _formatChoices.indexOf("MPower Echelon"));
    _largerTextStyle = Get.textTheme.headline4!;
    final themeMode = ref.watch(themeModeProvider);
    _selectedTextStyle =
        _largerTextStyle.apply(color: _themeManager.getProtagonistColor(themeMode));
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      body: ListView(
        children: _formatChoices
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
                      groupValue: _formatIndex,
                      onChanged: (value) {
                        setState(() {
                          _formatIndex = value as int;
                        });
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _formatIndex = e.key;
                      });
                    },
                    child: Text(e.value,
                        style: _formatIndex == e.key ? _selectedTextStyle : _largerTextStyle),
                  ),
                ],
              ),
            )
            .toList(growable: false),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _themeManager.getBlueFab(Icons.clear, themeMode, () => Get.back()),
            const SizedBox(width: 10, height: 10),
            _themeManager.getGreenFab(
              Icons.check,
              themeMode,
              () => Get.back(result: _formatChoices[_formatIndex]),
            ),
          ],
        ),
      ),
    );
  }
}
