import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:preferences/preference_service.dart';
import '../persistence/preferences.dart';

class ThemeManager with ChangeNotifier {
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

  bool isLight() {
    final themeSelection = PrefService.getString(THEME_SELECTION_TAG) ?? THEME_SELECTION_DEFAULT;
    if (themeSelection == "light") {
      debugPrint("light");
      return true;
    } else if (themeSelection == "dark") {
      debugPrint("dark");
      return false;
    }

    // ThemeMode.system;
    debugPrint(Get.isPlatformDarkMode ? "dark" : "light");
    return Get.isPlatformDarkMode ? false : true;
  }

  TextStyle getSettingsDescriptionStyle() {
    return TextStyle(color: isLight() ? Colors.grey.shade800 : Colors.grey.shade200, fontStyle: FontStyle.italic,);
  }

  ButtonStyle getHubButtonStyle() {
    return ElevatedButton.styleFrom(primary: isLight() ? Colors.grey.shade200 : Colors.grey.shade800);
  }

  ThemeManager() {
    notifyListeners();
  }

  void triggerChanged() async {
    notifyListeners();
  }
}
