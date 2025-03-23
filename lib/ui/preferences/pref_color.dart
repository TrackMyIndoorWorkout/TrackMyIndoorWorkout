import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../parts/color_picker.dart';

class PrefColor extends StatelessWidget {
  PrefColor({
    super.key,
    this.title,
    required this.pref,
    this.subtitle,
    this.onChange,
    this.disabled,
    required this.defaultValue,
  }) {
    final prefService = Get.find<BasePrefService>();
    initialValue = prefService.get<int>(pref) ?? defaultValue;
  }

  final Widget? title;
  final Widget? subtitle;
  final String pref;
  final bool? disabled;
  final ValueChanged<Color>? onChange;
  late final int initialValue;
  final int defaultValue;

  @override
  Widget build(BuildContext context) {
    return PrefCustom<int>(
      pref: pref,
      title: title,
      subtitle: subtitle,
      onChange: (colorValue) => onChange?.call(Color(colorValue ?? initialValue)),
      disabled: disabled,
      onTap: _onTap,
      builder:
          (context, colorValue) =>
              Container(color: Color(colorValue ?? initialValue), width: 40, height: 30),
    );
  }

  Future<int?> _onTap(BuildContext context, int? colorValue) async {
    final starterValue = colorValue ?? initialValue;
    final Color? pickedColor = await Get.bottomSheet(
      SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(child: ColorPickerBottomSheet(color: Color(starterValue)))),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
      enableDrag: false,
    );

    return pickedColor?.toARGB32() ?? starterValue;
  }
}
