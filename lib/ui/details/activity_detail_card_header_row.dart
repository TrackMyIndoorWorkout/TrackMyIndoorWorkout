import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/widgets.dart';

import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class ActivityDetailCardHeaderRow extends StatelessWidget {
  const ActivityDetailCardHeaderRow({
    Key? key,
    required this.themeManager,
    required this.icon,
    required this.iconSize,
    required this.statName,
    required this.text,
    required this.textStyle,
    required this.unitText,
    required this.unitStyle,
  }) : super(key: key);

  final ThemeManager themeManager;
  final IconData icon;
  final double iconSize;
  final String statName;
  final String text;
  final TextStyle textStyle;
  final String unitText;
  final TextStyle unitStyle;

  @override
  Widget build(BuildContext context) {
    return FitHorizontally(
      shrinkLimit: shrinkLimit,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          themeManager.getBlueIcon(icon, iconSize),
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
