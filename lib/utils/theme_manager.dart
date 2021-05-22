import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:preferences/preference_service.dart';
import '../persistence/preferences.dart';
import '../utils/constants.dart';

class ThemeManager {
  ThemeMode getThemeMode() {
    final themeSelection = PrefService.getString(THEME_SELECTION_TAG) ?? THEME_SELECTION_DEFAULT;
    if (themeSelection == "light") {
      return ThemeMode.light;
    } else if (themeSelection == "dark") {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  bool isDark() {
    final themeSelection = PrefService.getString(THEME_SELECTION_TAG) ?? THEME_SELECTION_DEFAULT;
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

  Color getHeaderColor() {
    return isDark() ? Colors.indigo : Colors.lightBlue;
  }

  Color getBlueColor() {
    return isDark() ? Colors.cyanAccent : Colors.indigo;
  }

  Color getBlueColorInverse() {
    return isDark() ? Colors.indigo : Colors.cyanAccent;
  }

  Color getGreenColor() {
    return isDark() ? Colors.lightGreenAccent : Colors.green;
  }

  Color getAntagonistColor() {
    return isDark() ? Colors.black : Colors.white;
  }

  Color getYellowColor() {
    return isDark() ? Colors.yellowAccent : Colors.yellow;
  }

  Icon getBlueIcon(IconData icon, double size) {
    return Icon(icon, color: getBlueColor(), size: size);
  }

  TextStyle getBlueTextStyle(double fontSize) {
    return TextStyle(fontFamily: FONT_FAMILY, fontSize: fontSize, color: getBlueColor());
  }

  FloatingActionButton _getFabCore(
      Color bgColor, Color fgColor, Widget widget, Function onPressed) {
    return FloatingActionButton(
      heroTag: null,
      child: widget,
      foregroundColor: fgColor,
      backgroundColor: bgColor,
      onPressed: onPressed,
    );
  }

  FloatingActionButton _getIconFab(Color color, IconData icon, Function onPressed) {
    return _getFabCore(getAntagonistColor(), color, Icon(icon), onPressed);
  }

  FloatingActionButton getBlueFab(IconData icon, Function onPressed) {
    return _getIconFab(getBlueColor(), icon, onPressed);
  }

  FloatingActionButton getGreenFab(IconData icon, Function onPressed) {
    return _getIconFab(getGreenColor(), icon, onPressed);
  }

  FloatingActionButton getRankIcon(Text rankText) {
    return _getFabCore(getYellowColor(), Colors.black87, rankText, () {});
  }
}
