extension StringEx on String {
  static RegExp nonAlphaNumFilterRegex = RegExp(r'[\W]+');

  String uuidString() {
    return length > 4 ? substring(4, 8).toLowerCase() : this;
  }

  String rgbString() {
    String colorString = toUpperCase();
    if (colorString.startsWith("0X")) {
      colorString = colorString.substring(2);
    }

    if (colorString.length > 6) {
      colorString = colorString.substring(colorString.length - 6);
    } else if (colorString.length < 6) {
      colorString = colorString.padLeft(6, "0");
    }

    return colorString;
  }

  String shortAddressString() {
    return replaceAll(nonAlphaNumFilterRegex, "");
  }
}
