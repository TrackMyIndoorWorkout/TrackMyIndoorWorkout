import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/widgets.dart';

import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class ActivityDetailHeaderRowBase extends StatelessWidget {
  const ActivityDetailHeaderRowBase({
    super.key,
    required this.themeManager,
    required this.icon,
    required this.iconSize,
    required this.widget,
  });

  final ThemeManager themeManager;
  final IconData icon;
  final double iconSize;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return FitHorizontally(
      shrinkLimit: shrinkLimit,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [themeManager.getBlueIcon(icon, iconSize), widget],
      ),
    );
  }
}
