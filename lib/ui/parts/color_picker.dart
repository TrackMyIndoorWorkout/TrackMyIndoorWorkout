import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class ColorPickerBottomSheet extends ConsumerStatefulWidget {
  final Color color;
  const ColorPickerBottomSheet({Key? key, required this.color}) : super(key: key);

  @override
  ColorPickerBottomSheetState createState() => ColorPickerBottomSheetState();
}

class ColorPickerBottomSheetState extends ConsumerState<ColorPickerBottomSheet> {
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  late final CircleColorPickerController _controller;
  Color _color = Colors.white;
  Color _initialColor = Colors.white;
  double? _mediaWidth;

  @override
  void initState() {
    super.initState();
    _controller = CircleColorPickerController(initialColor: widget.color);
    _color = Color(widget.color.value);
    _initialColor = Color(widget.color.value);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final textStyle = Theme.of(context).textTheme.headline5!.apply(
          fontFamily: fontFamily,
          color: _themeManager.getProtagonistColor(themeMode),
        );

    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth! - mediaWidth).abs() > eps) {
      _mediaWidth = mediaWidth;
    }

    return Scaffold(
      body: Center(
        child: CircleColorPicker(
          controller: _controller,
          onChanged: (color) {
            setState(() {
              _color = color;
            });
          },
          size: Size(_mediaWidth!, _mediaWidth!),
          strokeWidth: 5,
          thumbSize: _mediaWidth! / 5,
          textStyle: textStyle,
        ),
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
            _themeManager.getBlueFab(
              Icons.refresh,
              themeMode,
              () => _controller.color = _initialColor,
            ),
            const SizedBox(width: 10, height: 10),
            _themeManager.getGreenFab(Icons.check, themeMode, () => Get.back(result: _color)),
          ],
        ),
      ),
    );
  }
}
