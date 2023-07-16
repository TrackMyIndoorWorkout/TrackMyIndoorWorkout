import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/widgets.dart';
import '../../utils/theme_manager.dart';

class ActivityDetailHeaderRow extends StatelessWidget {
  const ActivityDetailHeaderRow({
    Key? key,
    required this.themeManager,
    required this.icon,
    required this.iconSize,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  final ThemeManager themeManager;
  final IconData icon;
  final double iconSize;
  final String text;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return FitHorizontally(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          themeManager.getBlueIcon(icon, iconSize),
          Text(text, style: textStyle),
        ],
      ),
    );
  }
}
