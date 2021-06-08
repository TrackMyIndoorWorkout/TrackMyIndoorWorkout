import "package:flutter/widgets.dart";

class BrandIconData extends IconData {
  const BrandIconData(int codePoint)
      : super(
          codePoint,
          fontFamily: "brands",
        );
}

class BrandIcons {
  static const IconData fitbit = const BrandIconData(0xe9c7);
  static const IconData flutter = const BrandIconData(0xe9cc);
  static const IconData garmin = const BrandIconData(0xe9d4);
  static const IconData strava = const BrandIconData(0xeb20);
}
