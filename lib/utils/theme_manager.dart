import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ui/about.dart';
import '../utils/constants.dart';

class ThemeManager {
  bool isDark(ThemeMode themeMode) {
    if (themeMode == ThemeMode.light) {
      return false;
    } else if (themeMode == ThemeMode.dark) {
      return true;
    }

    // ThemeMode.system;
    return Get.isPlatformDarkMode;
  }

  Icon getDeleteIcon(double size, ThemeMode themeMode) {
    return Icon(
      Icons.delete,
      color: isDark(themeMode) ? Colors.amberAccent : Colors.redAccent,
      size: size,
    );
  }

  Color getHeaderColor(ThemeMode themeMode) {
    return isDark(themeMode) ? Colors.indigo : Colors.lightBlue;
  }

  Color getBlueColor(ThemeMode themeMode) {
    return isDark(themeMode) ? Colors.cyanAccent : Colors.indigo;
  }

  Color getRedColor(ThemeMode themeMode) {
    return isDark(themeMode) ? Colors.orangeAccent : Colors.red.shade700;
  }

  Color getBlueColorInverse(ThemeMode themeMode) {
    return isDark(themeMode) ? Colors.indigo : Colors.cyanAccent;
  }

  Color getGreenColor(ThemeMode themeMode) {
    return isDark(themeMode) ? Colors.lightGreenAccent : Colors.green;
  }

  Color getYellowColor(ThemeMode themeMode) {
    return isDark(themeMode) ? Colors.yellowAccent : Colors.yellow;
  }

  Color getOrangeColor(ThemeMode themeMode) {
    return isDark(themeMode) ? Colors.orange : Colors.deepOrangeAccent;
  }

  Color getSuuntoRedColor(ThemeMode themeMode) {
    return isDark(themeMode) ? Colors.redAccent : Colors.red;
  }

  Color getGreyColor(ThemeMode themeMode) {
    return isDark(themeMode) ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  Color getAntagonistColor(ThemeMode themeMode) {
    return isDark(themeMode) ? Colors.black : Colors.white;
  }

  Color getProtagonistColor(ThemeMode themeMode) {
    return isDark(themeMode) ? Colors.white : Colors.black;
  }

  Icon getBlueIcon(IconData icon, double size, ThemeMode themeMode) {
    return Icon(icon, color: getBlueColor(themeMode), size: size);
  }

  Icon getRedIcon(IconData icon, double size, ThemeMode themeMode) {
    return Icon(icon, color: getRedColor(themeMode), size: size);
  }

  Icon getGreyIcon(IconData icon, double size, ThemeMode themeMode) {
    return Icon(icon, color: getGreyColor(themeMode), size: size);
  }

  Icon getActionIcon(IconData icon, double size, ThemeMode themeMode) {
    return Icon(icon, color: getProtagonistColor(themeMode), size: size);
  }

  TextStyle getBlueTextStyle(double fontSize, ThemeMode themeMode) {
    return TextStyle(fontFamily: fontFamily, fontSize: fontSize, color: getBlueColor(themeMode));
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
      onPressed: onPressed,
      child: widget,
    );
  }

  Widget getIconFab(Color color, IconData icon, ThemeMode themeMode, VoidCallback? onPressed) {
    return _getFabCore(
      getAntagonistColor(themeMode),
      color,
      Icon(icon),
      onPressed,
      null,
    );
  }

  Widget getIconFabWKey(
    Color color,
    IconData icon,
    ThemeMode themeMode,
    VoidCallback? onPressed,
    GlobalKey? key,
  ) {
    return _getFabCore(
      getAntagonistColor(themeMode),
      color,
      Icon(icon),
      onPressed,
      key,
    );
  }

  Widget getBlueFab(IconData icon, ThemeMode themeMode, VoidCallback? onPressed) {
    return getIconFab(getBlueColor(themeMode), icon, themeMode, onPressed);
  }

  Widget getGreenFab(IconData icon, ThemeMode themeMode, VoidCallback? onPressed) {
    return getIconFab(getGreenColor(themeMode), icon, themeMode, onPressed);
  }

  Widget getBlueFabWKey(
    IconData icon,
    ThemeMode themeMode,
    VoidCallback? onPressed,
    GlobalKey? key,
  ) {
    return getIconFabWKey(getBlueColor(themeMode), icon, themeMode, onPressed, key);
  }

  Widget getGreenFabWKey(
    IconData icon,
    ThemeMode themeMode,
    VoidCallback? onPressed,
    GlobalKey? key,
  ) {
    return getIconFabWKey(getGreenColor(themeMode), icon, themeMode, onPressed, key);
  }

  Widget getGreenGenericFab(Widget widget, ThemeMode themeMode, VoidCallback? onPressed) {
    return _getFabCore(
      getAntagonistColor(themeMode),
      getGreenColor(themeMode),
      widget,
      onPressed,
      null,
    );
  }

  Widget getGreyFab(IconData icon, ThemeMode themeMode, VoidCallback? onPressed) {
    return getIconFab(getGreyColor(themeMode), icon, themeMode, onPressed);
  }

  Widget getRankIcon(int rank, ThemeMode themeMode, BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline4!.apply(
          fontFamily: fontFamily,
          color: Colors.black,
        );
    return _getFabCore(
      Colors.black,
      getYellowColor(themeMode),
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
}
