import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/theme_manager.dart';

abstract class PreferencesScreenBase extends StatelessWidget {
  static String shortTitle = "";
  static String title = shortTitle;
  TextStyle descriptionStyle;

  PreferencesScreenBase() {
    descriptionStyle = Get.find<ThemeManager>().getSettingsDescriptionStyle();
  }

  bool isNumber(String str, double lowerLimit, double upperLimit) {
    double number = double.tryParse(str);
    return number != null &&
        (lowerLimit < 0.0 || number >= lowerLimit) &&
        (upperLimit < 0.0 || number <= upperLimit);
  }

  bool isInteger(String str, lowerLimit, upperLimit) {
    int integer = int.tryParse(str);
    return integer != null &&
        (lowerLimit < 0 || integer >= lowerLimit) &&
        (upperLimit < 0 || integer <= upperLimit);
  }
}
