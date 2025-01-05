import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_mode.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';

class ActivityDetailHeaderRowBase extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return FitHorizontally(
      shrinkLimit: shrinkLimit,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          themeManager.getBlueIcon(icon, iconSize, themeMode),
          widget,
        ],
      ),
    );
  }
}
