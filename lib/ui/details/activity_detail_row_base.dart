import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/widgets.dart';

import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class ActivityDetailRowBase extends StatelessWidget {
  const ActivityDetailRowBase({
    super.key,
    required this.themeManager,
    required this.icon,
    required this.iconSize,
    required this.text,
    required this.textStyle,
    required this.unitText,
    required this.unitStyle,
    required this.spacer,
    required this.forceOneLine,
    required this.fitHorizontally,
  });

  final ThemeManager themeManager;
  final IconData icon;
  final double iconSize;
  final String text;
  final TextStyle textStyle;
  final String unitText;
  final TextStyle? unitStyle;
  final bool spacer;
  final bool forceOneLine;
  final bool fitHorizontally;

  @override
  Widget build(BuildContext context) {
    List<Widget> row = [
      themeManager.getBlueIcon(icon, iconSize),
    ];

    if (spacer) {
      row.add(const Spacer());
    }

    if (forceOneLine) {
      row.add(
        Expanded(
          child: TextOneLine(
            text,
            style: textStyle,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else if (fitHorizontally) {
      row.add(
        FitHorizontally(
          shrinkLimit: shrinkLimit,
          child: Text(text, style: textStyle),
        ),
      );
    } else {
      row.add(Text(text, style: textStyle));
    }

    if (unitStyle != null && unitText.isNotEmpty) {
      row.add(
        SizedBox(
          width: iconSize,
          child: Text(unitText, style: unitStyle),
        ),
      );
    }

    return FitHorizontally(
      shrinkLimit: shrinkLimit,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: row,
      ),
    );
  }
}
