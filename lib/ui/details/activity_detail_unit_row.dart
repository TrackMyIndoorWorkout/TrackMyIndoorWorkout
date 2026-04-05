import 'package:flutter/widgets.dart';

import '../../utils/theme_manager.dart';

class ActivityDetailUnitRow extends StatelessWidget {
  const ActivityDetailUnitRow({
    super.key,
    required this.themeManager,
    required this.unitText,
    required this.unitStyle,
  });

  final ThemeManager themeManager;
  final String unitText;
  final TextStyle unitStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Spacer(),
        Text(unitText, style: unitStyle),
      ],
    );
  }
}
