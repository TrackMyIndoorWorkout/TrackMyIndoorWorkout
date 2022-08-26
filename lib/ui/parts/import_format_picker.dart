import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme_manager.dart';

class ImportFormatPickerBottomSheet extends StatefulWidget {
  const ImportFormatPickerBottomSheet({Key? key}) : super(key: key);

  @override
  ImportFormatPickerBottomSheetState createState() => ImportFormatPickerBottomSheetState();
}

class ImportFormatPickerBottomSheetState extends State<ImportFormatPickerBottomSheet> {
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
    _selectedTextStyle = _largerTextStyle.apply(color: _themeManager.getProtagonistColor());
  }

  @override
  Widget build(BuildContext context) {
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
            _themeManager.getBlueFab(Icons.clear, () => Get.back()),
            const SizedBox(width: 10, height: 10),
            _themeManager.getGreenFab(
              Icons.check,
              () => Get.back(result: _formatChoices[_formatIndex]),
            ),
          ],
        ),
      ),
    );
  }
}
