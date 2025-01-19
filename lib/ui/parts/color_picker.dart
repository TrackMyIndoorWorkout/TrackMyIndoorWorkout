import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';

import '../../utils/color_ex.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import 'legend_dialog.dart';

class ColorPickerBottomSheet extends StatefulWidget {
  final Color color;
  final ValueChanged<Color>? onChanged;
  const ColorPickerBottomSheet({super.key, required this.color, this.onChanged});

  @override
  ColorPickerBottomSheetState createState() => ColorPickerBottomSheetState();
}

class ColorPickerBottomSheetState extends State<ColorPickerBottomSheet> {
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  late final CircleColorPickerController _controller;
  Color _color = Colors.white;
  Color _initialColor = Colors.white;
  TextStyle _textStyle = const TextStyle();
  double? _mediaWidth;

  @override
  void initState() {
    super.initState();
    _controller = CircleColorPickerController(initialColor: widget.color);
    _color = Color(widget.color.toARGB32);
    _initialColor = Color(widget.color.toARGB32);
    _textStyle = Get.textTheme.headlineSmall!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
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
            widget.onChanged?.call(_color);
            setState(() {
              _color = color;
            });
          },
          size: Size(_mediaWidth!, _mediaWidth!),
          strokeWidth: 5,
          thumbSize: _mediaWidth! / 5,
          textStyle: _textStyle,
        ),
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
            _themeManager.getBlueFab(Icons.info_rounded, () {
              legendDialog([
                const Tuple2<IconData, String>(Icons.arrow_back, "Navigate back"),
                const Tuple2<IconData, String>(Icons.info_rounded, "Help Legend"),
                const Tuple2<IconData, String>(Icons.u_turn_left, "Reset to initial"),
                // const Tuple2<IconData, String>(Icons.format_color_reset, "Reset to default"),
                const Tuple2<IconData, String>(Icons.check, "Apply selected color"),
              ]);
            }),
            const SizedBox(width: 30, height: 10),
            _themeManager.getBlueFab(Icons.u_turn_left, () => _controller.color = _initialColor),
            const SizedBox(width: 10, height: 10),
            // _themeManager.getBlueFab(
            //     Icons.format_color_reset, () => _controller.color = _initialColor), // TODO
            const SizedBox(width: 10, height: 10),
            _themeManager.getGreenFab(Icons.check, () => Get.back(result: _color)),
          ],
        ),
      ),
    );
  }
}
