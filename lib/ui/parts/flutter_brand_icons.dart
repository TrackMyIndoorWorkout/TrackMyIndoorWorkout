import "package:flutter/widgets.dart";

class BrandIconData extends IconData {
  const BrandIconData(int codePoint)
      : super(
          codePoint,
          fontFamily: "brands",
        );
}

class BrandIcons {
  static const IconData fitbit = BrandIconData(0xe9c7);
  static const IconData flutter = BrandIconData(0xe9cc);
  static const IconData garmin = BrandIconData(0xe9d4);
  static const IconData strava = BrandIconData(0xeb20);
}
