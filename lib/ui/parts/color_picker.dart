import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class ColorPickerBottomSheet extends StatefulWidget {
  final Color color;
  const ColorPickerBottomSheet({Key? key, required this.color}) : super(key: key);

  @override
  ColorPickerBottomSheetState createState() => ColorPickerBottomSheetState();
}

class ColorPickerBottomSheetState extends State<ColorPickerBottomSheet> {
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  late final CircleColorPickerController _controller;
  Color _color = Colors.white;
  double? _mediaWidth;

  @override
  void initState() {
    super.initState();
    _controller = CircleColorPickerController(initialColor: widget.color);
    _color = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth! - mediaWidth).abs() > eps) {
      _mediaWidth = mediaWidth;
    }

    return Scaffold(
      body: Center(
        child: CircleColorPicker(
          controller: _controller,
          onChanged: (color) {
            _color = color;
          },
          size: Size(_mediaWidth!, _mediaWidth!),
          strokeWidth: 5,
          thumbSize: _mediaWidth! / 6,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getGreenFab(
          Icons.check, false, false, "", 0, () => Get.back(result: _color)),
    );
  }
}
