import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class ActivityDetailCardHeaderRow extends ConsumerWidget {
  const ActivityDetailCardHeaderRow({
    super.key,
    required this.themeManager,
    required this.icon,
    required this.iconSize,
    required this.statName,
    required this.text,
    required this.textStyle,
    required this.unitText,
    required this.unitStyle,
  });

  final ThemeManager themeManager;
  final IconData icon;
  final double iconSize;
  final String statName;
  final String text;
  final TextStyle textStyle;
  final String unitText;
  final TextStyle unitStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return FitHorizontally(
      shrinkLimit: shrinkLimit,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          themeManager.getBlueIcon(icon, iconSize, themeMode),
          Text(statName, style: unitStyle),
          const Spacer(),
          TextOneLine(
            text,
            style: textStyle,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            unitText,
            textAlign: TextAlign.left,
            maxLines: 2,
            style: unitStyle,
          ),
        ],
      ),
    );
  }
}
