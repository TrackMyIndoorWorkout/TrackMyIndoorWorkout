import 'package:flutter/material.dart';
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import 'package:preferences/preference_service.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Icon getActionIcon(IconData icon, double size) {
    return Icon(icon, color: getProtagonistColor(), size: size);
  }

  TextStyle getBlueTextStyle(double fontSize) {
    return TextStyle(fontFamily: FONT_FAMILY, fontSize: fontSize, color: getBlueColor());
  }

  FloatingActionButton _getFabCore(
    Color foregroundColor,
    Color backgroundColor,
    Widget widget,
    Function onPressed,
  ) {
    return FloatingActionButton(
      heroTag: null,
      child: widget,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      onPressed: onPressed,
    );
  }

  FloatingActionButton getIconFab(Color color, IconData icon, Function onPressed) {
    return _getFabCore(getAntagonistColor(), color, Icon(icon), onPressed);
  }

  FloatingActionButton getBlueFab(IconData icon, Function onPressed) {
    return getIconFab(getBlueColor(), icon, onPressed);
  }

  FloatingActionButton getGreenFab(IconData icon, Function onPressed) {
    return getIconFab(getGreenColor(), icon, onPressed);
  }

  FloatingActionButton getGreenGenericFab(Widget widget, Function onPressed) {
    return _getFabCore(getAntagonistColor(), getGreenColor(), widget, onPressed);
  }

  FloatingActionButton getStravaFab(Function onPressed) {
    return _getFabCore(Colors.white, getOrangeColor(), Icon(BrandIcons.strava), onPressed);
  }

  FloatingActionButton getRankIcon(int rank) {
    final textStyle =
        Get.textTheme.headline4.apply(fontFamily: FONT_FAMILY, color: Colors.black);
    return _getFabCore(
        Colors.black, getYellowColor(), Text(rank.toString(), style: textStyle), () {});
  }

  FloatingActionButton getHelpFab() {
    return _getFabCore(Colors.white, Colors.lightBlue, Icon(Icons.help), () async {
      if (await canLaunch(HELP_URL)) {
        launch(HELP_URL);
      } else {
        Get.snackbar("Attention", "Cannot open URL");
      }
    });
  }

  TextStyle boldStyle(TextStyle style, {double fontSizeFactor = 1.0}) {
    return style.apply(
      fontSizeFactor: fontSizeFactor,
      fontWeightDelta: 3,
    );
  }
}
