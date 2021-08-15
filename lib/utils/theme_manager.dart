import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:overlay_tutorial/overlay_tutorial.dart';
import 'package:track_my_indoor_exercise/ui/about.dart';
import '../persistence/preferences.dart';
import '../ui/parts/flutter_brand_icons.dart';
import '../utils/constants.dart';

class ThemeManager {
  ThemeMode getThemeMode() {
    final prefService = Get.find<BasePrefService>();
    final themeSelection = prefService.get<String>(THEME_SELECTION_TAG) ?? THEME_SELECTION_DEFAULT;
    if (themeSelection == "light") {
      return ThemeMode.light;
    } else if (themeSelection == "dark") {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  bool isDark() {
    final prefService = Get.find<BasePrefService>();
    final themeSelection = prefService.get<String>(THEME_SELECTION_TAG) ?? THEME_SELECTION_DEFAULT;
    if (themeSelection == "light") {
      return false;
    } else if (themeSelection == "dark") {
      return true;
    }

    // ThemeMode.system;
    return Get.isPlatformDarkMode;
  }

  Icon getDeleteIcon(double size) {
    return Icon(
      Icons.delete,
      color: isDark() ? Colors.amberAccent : Colors.redAccent,
      size: size,
    );
  }

  OverlayTutorialHole _wrapInOverlayHole(
    bool enabled,
    String text,
    int annotationYOffset,
    Widget widget,
  ) {
    return OverlayTutorialHole(
      enabled: enabled,
      overlayTutorialEntry: OverlayTutorialRectEntry(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        radius: const Radius.circular(16.0),
        overlayTutorialHints: <OverlayTutorialWidgetHint>[
          OverlayTutorialWidgetHint(
            builder: (context, rect, rRect) {
              final annotation = Text(
                text,
                style: Get.textTheme.headline6?.copyWith(color: Colors.yellowAccent),
              );
              if (rRect.center.dx < Get.width / 2) {
                return Positioned(
                  top: rRect.top + 4.0 + annotationYOffset,
                  left: rRect.right + 4.0,
                  child: annotation,
                );
              } else {
                return Positioned(
                  top: rRect.top + 4.0 + annotationYOffset,
                  right: Get.width - rRect.left + 4.0,
                  child: annotation,
                );
              }
            },
          ),
        ],
      ),
      child: widget,
    );
  }

  Color getHeaderColor() {
    return isDark() ? Colors.indigo : Colors.lightBlue;
  }

  Color getBlueColor() {
    return isDark() ? Colors.cyanAccent : Colors.indigo;
  }

  Color getRedColor() {
    return isDark() ? Colors.orangeAccent : Colors.red.shade700;
  }

  Color getBlueColorInverse() {
    return isDark() ? Colors.indigo : Colors.cyanAccent;
  }

  Color getGreenColor() {
    return isDark() ? Colors.lightGreenAccent : Colors.green;
  }

  Color getYellowColor() {
    return isDark() ? Colors.yellowAccent : Colors.yellow;
  }

  Color getOrangeColor() {
    return isDark() ? Colors.orange : Colors.deepOrangeAccent;
  }

  Color getGreyColor() {
    return isDark() ? Colors.grey.shade200 : Colors.grey.shade700;
  }

  Color getAntagonistColor() {
    return isDark() ? Colors.black : Colors.white;
  }

  Color getProtagonistColor() {
    return isDark() ? Colors.white : Colors.black;
  }

  Icon getBlueIcon(IconData icon, double size) {
    return Icon(icon, color: getBlueColor(), size: size);
  }

  OverlayTutorialHole getBlueIconWithHole(
    IconData icon,
    double size,
    bool overlayEnabled,
    String overlayText,
    int annotationYOffset,
  ) {
    return _wrapInOverlayHole(
      overlayEnabled,
      overlayText,
      annotationYOffset,
      Icon(icon, color: getBlueColor(), size: size),
    );
  }

  Icon getActionIcon(IconData icon, double size) {
    return Icon(icon, color: getProtagonistColor(), size: size);
  }

  TextStyle getBlueTextStyle(double fontSize) {
    return TextStyle(fontFamily: FONT_FAMILY, fontSize: fontSize, color: getBlueColor());
  }

  Widget _getFabCore(
    Color foregroundColor,
    Color backgroundColor,
    Widget widget,
    bool wrapInHole,
    bool overlayEnabled,
    String overlayText,
    int annotationYOffset,
    VoidCallback? onPressed,
  ) {
    final fab = FloatingActionButton(
      heroTag: null,
      child: widget,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      onPressed: onPressed,
    );

    return wrapInHole
        ? _wrapInOverlayHole(
            overlayEnabled,
            overlayText,
            annotationYOffset,
            fab,
          )
        : fab;
  }

  Widget getIconFab(
    Color color,
    IconData icon,
    bool wrapInHole,
    bool overlayEnabled,
    String overlayText,
    int annotationYOffset,
    VoidCallback? onPressed,
  ) {
    return _getFabCore(
      getAntagonistColor(),
      color,
      Icon(icon),
      wrapInHole,
      overlayEnabled,
      overlayText,
      annotationYOffset,
      onPressed,
    );
  }

  Widget getBlueFab(
    IconData icon,
    bool wrapInHole,
    bool overlayEnabled,
    String overlayText,
    int annotationYOffset,
    VoidCallback? onPressed,
  ) {
    return getIconFab(
      getBlueColor(),
      icon,
      wrapInHole,
      overlayEnabled,
      overlayText,
      annotationYOffset,
      onPressed,
    );
  }

  Widget getGreenFab(
    IconData icon,
    bool wrapInHole,
    bool overlayEnabled,
    String overlayText,
    int annotationYOffset,
    VoidCallback? onPressed,
  ) {
    return getIconFab(
      getGreenColor(),
      icon,
      wrapInHole,
      overlayEnabled,
      overlayText,
      annotationYOffset,
      onPressed,
    );
  }

  Widget getGreenGenericFab(
    Widget widget,
    wrapInHole,
    overlayEnabled,
    overlayText,
    annotationYOffset,
    VoidCallback? onPressed,
  ) {
    return _getFabCore(
      getAntagonistColor(),
      getGreenColor(),
      widget,
      wrapInHole,
      overlayEnabled,
      overlayText,
      annotationYOffset,
      onPressed,
    );
  }

  Widget getStravaFab(bool overlayEnabled, VoidCallback? onPressed) {
    return _getFabCore(
      Colors.white,
      getOrangeColor(),
      Icon(BrandIcons.strava),
      true,
      overlayEnabled,
      "Strava Upload",
      8,
      onPressed,
    );
  }

  Widget getGreyFab(IconData icon, VoidCallback? onPressed) {
    return getIconFab(getGreyColor(), icon, false, false, "", 0, onPressed);
  }

  Widget getRankIcon(int rank) {
    final textStyle = Get.textTheme.headline4!.apply(fontFamily: FONT_FAMILY, color: Colors.black);
    return _getFabCore(
      Colors.black,
      getYellowColor(),
      Text(rank.toString(), style: textStyle),
      false,
      false,
      "",
      0,
      () {},
    );
  }

  Widget getHelpFab(
    IconData icon,
    bool overlayEnabled,
    String overlayText,
    int annotationYOffset,
    VoidCallback? onPressed,
  ) {
    return _getFabCore(
      Colors.white,
      Colors.lightBlue,
      Icon(icon),
      true,
      overlayEnabled,
      overlayText,
      annotationYOffset,
      onPressed,
    );
  }

  Widget getAboutFab(bool overlayEnabled) {
    return getHelpFab(
      Icons.help,
      overlayEnabled,
      "About & Help",
      0,
      () => Get.to(() => AboutScreen()),
    );
  }

  Widget getTutorialFab(bool overlayEnabled, VoidCallback? onPressed) {
    return getHelpFab(Icons.info_rounded, overlayEnabled, "Help Overlay", 0, onPressed);
  }

  TextStyle boldStyle(TextStyle style, {double fontSizeFactor = 1.0}) {
    return style.apply(
      fontSizeFactor: fontSizeFactor,
      fontWeightDelta: 3,
    );
  }
}
