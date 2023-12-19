mixin PreferencesScreenMixin {
  static String shortTitle = "";
  static String title = shortTitle;

  bool isNumber(String str, double lowerLimit, double upperLimit) {
    double? number = double.tryParse(str);
    return number != null &&
        (lowerLimit < 0.0 || number >= lowerLimit) &&
        (upperLimit < 0.0 || number <= upperLimit);
  }
}
