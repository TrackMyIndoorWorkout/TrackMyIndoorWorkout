import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

const simplerUi = "Simplify Measurement UI";
const simplerUiTag = "simpler_ui";
const simplerUiFastDefault = false;
const simplerUiSlowDefault = true;
const simplerUiDescription = "On: the track visualization and the real-time"
    " graphs won't be featured at the bottom of the measurement "
    "screen. This can help old / slow phones.";

Future<bool> getSimplerUiDefault() async {
  var simplerUiDefault = simplerUiFastDefault;
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt < 26) {
      // Remove complexities for very old Android devices
      simplerUiDefault = simplerUiSlowDefault;
    }
  }

  return simplerUiDefault;
}
