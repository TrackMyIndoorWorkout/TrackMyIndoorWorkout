import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:overlay_tutorial/overlay_tutorial.dart';
import '../ui/about.dart';
import '../preferences/theme_selection.dart';
import '../utils/constants.dart';

class ThemeManager {
  ThemeMode getThemeMode() {
    final prefService = Get.find<BasePrefService>();
    final themeSelection = prefService.get<String>(themeSelectionTag) ?? themeSelectionDefault;
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
    final themeSelection = prefService.get<String>(themeSelectionTag) ?? themeSelectionDefault;
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
            builder: (context, oRect) {
              final annotation = Text(
                text,
                style: Get.textTheme.headline6?.copyWith(color: Colors.yellowAccent),
              );
              if ((oRect.rRect?.center.dx ?? 0.0) < Get.width / 2) {
                return Positioned(
                  top: (oRect.rRect?.top ?? 0.0) + 4.0 + annotationYOffset,
                  left: (oRect.rRect?.right ?? 0.0) + 4.0,
                  child: annotation,
                );
              } else {
                return Positioned(
                  top: (oRect.rRect?.top ?? 0.0) + 4.0 + annotationYOffset,
                  right: Get.width - (oRect.rRect?.left ?? 4.0) + 4.0,
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

  Color getSuuntoRedColor() {
    return isDark() ? Colors.redAccent : Colors.red;
  }

  Color getGreyColor() {
    return isDark() ? Colors.grey.shade400 : Colors.grey.shade600;
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

  Icon getRedIcon(IconData icon, double size) {
    return Icon(icon, color: getRedColor(), size: size);
  }

  Icon getGreyIcon(IconData icon, double size) {
    return Icon(icon, color: getGreyColor(), size: size);
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
    return TextStyle(fontFamily: fontFamily, fontSize: fontSize, color: getBlueColor());
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
    GlobalKey? key,
  ) {
    key ??= GlobalKey();
    final fab = FloatingActionButton(
      key: key,
      heroTag: null,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      onPressed: onPressed,
      child: widget,
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
      null,
    );
  }

  Widget getIconFabWKey(
    Color color,
    IconData icon,
    bool wrapInHole,
    bool overlayEnabled,
    String overlayText,
    int annotationYOffset,
    VoidCallback? onPressed,
    GlobalKey? key,
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
      key,
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

  Widget getBlueFabWKey(
    IconData icon,
    bool wrapInHole,
    bool overlayEnabled,
    String overlayText,
    int annotationYOffset,
    VoidCallback? onPressed,
    GlobalKey? key,
  ) {
    return getIconFabWKey(
      getBlueColor(),
      icon,
      wrapInHole,
      overlayEnabled,
      overlayText,
      annotationYOffset,
      onPressed,
      key,
    );
  }

  Widget getGreenFabWKey(
    IconData icon,
    bool wrapInHole,
    bool overlayEnabled,
    String overlayText,
    int annotationYOffset,
    VoidCallback? onPressed,
    GlobalKey? key,
  ) {
    return getIconFabWKey(
      getGreenColor(),
      icon,
      wrapInHole,
      overlayEnabled,
      overlayText,
      annotationYOffset,
      onPressed,
      key,
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
      null,
    );
  }

  Widget getGreyFab(IconData icon, VoidCallback? onPressed) {
    return getIconFab(getGreyColor(), icon, false, false, "", 0, onPressed);
  }

  Widget getRankIcon(int rank) {
    final textStyle = Get.textTheme.headline4!.apply(fontFamily: fontFamily, color: Colors.black);
    return _getFabCore(
      Colors.black,
      getYellowColor(),
      Text(rank.toString(), style: textStyle),
      false,
      false,
      "",
      0,
      () {},
      null,
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
      null,
    );
  }

  Widget getAboutFab(bool overlayEnabled) {
    return getHelpFab(
      Icons.help,
      overlayEnabled,
      "About & Help",
      0,
      () => Get.to(() => const AboutScreen()),
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
