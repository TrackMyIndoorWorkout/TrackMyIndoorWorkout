import 'dart:io';

import 'package:flutter/foundation.dart';

const unitSystem = "Unit System";
const unitSystemTag = "unit_system";
const unitSystemDefault = false;
const unitSystemDescription =
    "On: metric (km/h speed, meters distance), Off: imperial (mp/h speed, miles distance).";

const imperialCountries = ["US", "UK", "LR", "MM"];

bool getUnitSystemDefault() {
  final localeName = Platform.localeName;
  if (localeName.length < 5 || localeName[2] != "_") {
    return unitSystemDefault;
  }

  String deviceCountry = localeName.substring(3, 5);
  debugPrint("Country: $deviceCountry");
  return !imperialCountries.contains(deviceCountry);
}
