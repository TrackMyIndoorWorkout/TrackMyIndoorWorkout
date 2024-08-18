import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../preferences/stage_mode.dart';
import '../preferences/theme_selection.dart';
import '../ui/about.dart';
import '../utils/constants.dart';

class ThemeManager {
  ThemeMode getThemeMode() {
    final prefService = Get.find<BasePrefService>();
    final themeSelection = prefService.get<String>(themeSelectionTag) ?? themeSelectionDefault;
    if (themeSelection == themeSelectionLight) {
      return ThemeMode.light;
    } else if (themeSelection == themeSelectionDark) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  bool isDark() {
    final prefService = Get.find<BasePrefService>();
    final themeSelection = prefService.get<String>(themeSelectionTag) ?? themeSelectionDefault;
    if (themeSelection == themeSelectionLight) {
      return false;
    } else if (themeSelection == themeSelectionDark) {
      return true;
    }

    return Get.isPlatformDarkMode;
  }

  Icon getDeleteIcon(double size) {
    return Icon(
      Icons.delete,
      color: isDark() ? Colors.amberAccent : Colors.redAccent,
      size: size,
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

  Color getGreenColorInverse() {
    return isDark() ? Colors.green : Colors.lightGreenAccent;
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
    VoidCallback? onPressed,
    GlobalKey? key,
  ) {
    return FloatingActionButton(
      key: key ?? GlobalKey(),
      heroTag: null,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      shape: const CircleBorder(),
      onPressed: onPressed,
      child: widget,
    );
  }

  Widget getIconFab(Color color, IconData icon, VoidCallback? onPressed) {
    return _getFabCore(
      getAntagonistColor(),
      color,
      Icon(icon),
      onPressed,
      null,
    );
  }

  Widget getIconFabWKey(
    Color color,
    IconData icon,
    VoidCallback? onPressed,
    GlobalKey? key,
  ) {
    return _getFabCore(
      getAntagonistColor(),
      color,
      Icon(icon),
      onPressed,
      key,
    );
  }

  Widget getBlueFab(IconData icon, VoidCallback? onPressed) {
    return getIconFab(getBlueColor(), icon, onPressed);
  }

  Widget getGreenFab(IconData icon, VoidCallback? onPressed) {
    return getIconFab(getGreenColor(), icon, onPressed);
  }

  Widget getBlueFabWKey(IconData icon, VoidCallback? onPressed, GlobalKey? key) {
    return getIconFabWKey(getBlueColor(), icon, onPressed, key);
  }

  Widget getGreenFabWKey(IconData icon, VoidCallback? onPressed, GlobalKey? key) {
    return getIconFabWKey(getGreenColor(), icon, onPressed, key);
  }

  Widget getGreyFab(IconData icon, VoidCallback? onPressed) {
    return getIconFab(getGreyColor(), icon, onPressed);
  }

  Widget getRankIcon(int rank) {
    final textStyle =
        Get.textTheme.headlineMedium!.apply(fontFamily: fontFamily, color: Colors.black);
    return _getFabCore(
      Colors.black,
      getYellowColor(),
      Text(rank.toString(), style: textStyle),
      () {},
      null,
    );
  }

  Widget getHelpFab(IconData icon, VoidCallback? onPressed) {
    return _getFabCore(Colors.white, Colors.lightBlue, Icon(icon), onPressed, null);
  }

  Widget getAboutFab() {
    return getHelpFab(
      Icons.help,
      () => Get.to(() => const AboutScreen()),
    );
  }

  Widget getTutorialFab(VoidCallback? onPressed) {
    return getHelpFab(Icons.info_rounded, onPressed);
  }

  TextStyle boldStyle(TextStyle style, {double fontSizeFactor = 1.0}) {
    return style.apply(
      fontSizeFactor: fontSizeFactor,
      fontWeightDelta: 3,
    );
  }

  Color getAverageChartColor() {
    final prefService = Get.find<BasePrefService>();
    final averageChartColorValue =
        prefService.get<int>(averageChartColorTag) ?? averageChartColorDefault;
    return Color(averageChartColorValue);
  }

  Color getMaximumChartColor() {
    final prefService = Get.find<BasePrefService>();
    final maximumChartColorValue =
        prefService.get<int>(averageChartColorTag) ?? averageChartColorDefault;
    return Color(maximumChartColorValue);
  }
}
