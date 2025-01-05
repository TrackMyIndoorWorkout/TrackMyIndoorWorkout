import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:number_selector/number_selector.dart';
import 'package:pref/pref.dart';

import '../../providers/theme_mode.dart';
import '../../utils/theme_manager.dart';

class PrefInteger extends ConsumerStatefulWidget {
  const PrefInteger({
    super.key,
    this.title,
    required this.pref,
    this.subtitle,
    this.onChange,
    this.disabled,
    required this.min,
    required this.max,
  });

  final Widget? title;
  final Widget? subtitle;
  final String pref;
  final bool? disabled;
  final ValueChanged<int?>? onChange;
  final int min;
  final int max;

  @override
  PrefIntegerState createState() => PrefIntegerState();
}

class PrefIntegerState extends ConsumerState<PrefInteger> {
  final ThemeManager _themeManager = Get.find<ThemeManager>();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final borderColor = _themeManager.getGreyColor(themeMode);
    final backgroundColor =
        _themeManager.isDark(themeMode) ? Colors.grey.shade800 : Colors.grey.shade200;
    final iconColor = _themeManager.getProtagonistColor(themeMode);

    return PrefCustom<int>.widget(
      pref: widget.pref,
      title: widget.title,
      subtitle: widget.subtitle,
      onChange: widget.onChange,
      disabled: widget.disabled,
      builder: (context, value, onChange) => NumberSelector(
        current: value ?? 0,
        min: widget.min,
        max: widget.max,
        showMinMax: true,
        showSuffix: false,
        hasBorder: true,
        borderColor: borderColor,
        hasDividers: true,
        dividerColor: borderColor,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        onUpdate: onChange,
      ),
    );
  }
}
