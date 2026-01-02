import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flutter/material.dart';

import '../../utils/theme_manager.dart';

class ActivitiesFabMenu extends StatelessWidget {
  const ActivitiesFabMenu({
    super.key,
    required this.themeManager,
    required this.leaderboardFeature,
    required this.hasLeaderboardData,
    required this.onTutorial,
    required this.onImport,
    required this.onDeviceUsages,
    required this.onPowerTunes,
    required this.onCalorieTunes,
    required this.onLeaderboard,
  });

  final ThemeManager themeManager;
  final bool leaderboardFeature;
  final bool hasLeaderboardData;
  final VoidCallback onTutorial;
  final Future<void> Function() onImport;
  final Future<void> Function() onDeviceUsages;
  final Future<void> Function() onPowerTunes;
  final Future<void> Function() onCalorieTunes;
  final Future<void> Function() onLeaderboard;

  @override
  Widget build(BuildContext context) {
    List<Widget> floatingActionButtons = [
      themeManager.getTutorialFab(onTutorial),
      themeManager.getAboutFab(),
      themeManager.getBlueFab(Icons.file_upload, () async {
        await onImport();
      }),
      themeManager.getBlueFab(Icons.collections_bookmark, () async {
        await onDeviceUsages();
      }),
      themeManager.getBlueFab(Icons.bolt, () async {
        await onPowerTunes();
      }),
      themeManager.getBlueFab(Icons.whatshot, () async {
        await onCalorieTunes();
      }),
    ];

    if (leaderboardFeature && hasLeaderboardData) {
      floatingActionButtons.add(
        themeManager.getBlueFab(Icons.leaderboard, () async {
          await onLeaderboard();
        }),
      );
    }

    return FabCircularMenuPlus(
      fabOpenIcon: Icon(Icons.menu, color: themeManager.getAntagonistColor()),
      fabOpenColor: themeManager.getBlueColor(),
      fabCloseIcon: Icon(Icons.close, color: themeManager.getAntagonistColor()),
      fabCloseColor: themeManager.getBlueColor(),
      ringColor: themeManager.getBlueColorInverse(),
      children: floatingActionButtons,
    );
  }
}
