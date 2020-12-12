import 'dart:io';

import 'package:charts_flutter/flutter.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

Color getTranslucent(Color c) {
  return Color(
      r: c.r, g: c.g, b: c.b, a: 120, darker: c.darker, lighter: c.lighter);
}

final sevenBgPalette = [
  getTranslucent(MaterialPalette.blue.shadeDefault.lighter),
  getTranslucent(MaterialPalette.teal.shadeDefault.lighter),
  getTranslucent(MaterialPalette.cyan.shadeDefault.lighter),
  getTranslucent(MaterialPalette.lime.shadeDefault.lighter),
  getTranslucent(MaterialPalette.yellow.shadeDefault.lighter),
  getTranslucent(MaterialPalette.red.shadeDefault.lighter),
  getTranslucent(MaterialPalette.pink.shadeDefault.lighter),
];

final sevenFgPalette = [
  MaterialPalette.indigo.shadeDefault.darker,
  MaterialPalette.teal.shadeDefault.darker,
  MaterialPalette.cyan.shadeDefault.darker,
  MaterialPalette.green.shadeDefault.darker,
  MaterialPalette.deepOrange.shadeDefault.darker,
  MaterialPalette.red.shadeDefault.darker,
  MaterialPalette.purple.shadeDefault.darker,
];

final fiveBgPalette = [
  getTranslucent(MaterialPalette.blue.shadeDefault.lighter),
  getTranslucent(MaterialPalette.cyan.shadeDefault.lighter),
  getTranslucent(MaterialPalette.lime.shadeDefault.lighter),
  getTranslucent(MaterialPalette.yellow.shadeDefault.lighter),
  getTranslucent(MaterialPalette.red.shadeDefault.lighter),
];

final fiveFgPalette = [
  MaterialPalette.indigo.shadeDefault.darker,
  MaterialPalette.teal.shadeDefault.darker,
  MaterialPalette.green.shadeDefault.darker,
  MaterialPalette.deepOrange.shadeDefault.darker,
  MaterialPalette.red.shadeDefault.darker,
];

// https://stackoverflow.com/questions/57481767/dart-rounding-errors
double decimalRound(double value, {int precision = 100}) {
  return (value * precision).round() / precision;
}

class PreferencesSpec {
  final String metric;
  final String title;
  String unit;
  final String thresholdTag;
  final String thresholdDefault;
  final String zonesTag;
  final String zonesDefault;
  double threshold;
  List<int> zonePercents;
  List<double> zoneBounds;
  List<double> zoneLower;
  List<double> zoneUpper;
  final IconData icon;

  PreferencesSpec({
    this.metric,
    this.title,
    this.unit,
    this.thresholdTag,
    this.thresholdDefault,
    this.zonesTag,
    this.zonesDefault,
    this.icon,
  });

  String get fullTitle => '$title ($unit)';
  String get histogramTitle => '$title zones (%)';

  calculateZones() {
    final thresholdString = PrefService.getString(thresholdTag);
    threshold = double.tryParse(thresholdString);
    final zonesSpecStr = PrefService.getString(zonesTag);
    zonePercents = zonesSpecStr
        .split(',')
        .map((zs) => int.tryParse(zs))
        .toList(growable: false);
    zoneBounds =
        zonePercents.map((z) => decimalRound(z / 100.0 * threshold)).toList();
  }

  calculateBounds(double minVal, double maxVal) {
    zoneLower = [...zoneBounds];
    if (minVal < 0 || minVal > 0 && minVal > zoneLower[0]) {
      minVal = zoneLower[0] * 0.75;
    }
    zoneLower.insert(0, decimalRound(minVal));

    zoneUpper = [...zoneBounds];
    if (maxVal < 0 || maxVal > 0 && maxVal < zoneLower.last) {
      maxVal = zoneLower.last * 1.15;
    }
    zoneUpper.add(decimalRound(maxVal));
  }

  int get binCount => zonePercents.length + 1;

  int binIndex(num value) {
    int i = 0;
    for (; i < zoneBounds.length; i++) {
      if (value < zoneBounds[i]) {
        return i;
      }
    }
    return i;
  }

  Color bgColorByBin(int bin) {
    if (bin > 6) {
      return getTranslucent(MaterialPalette.blue.shadeDefault.lighter);
    }
    if (zonePercents.length <= 5) {
      return fiveBgPalette[bin];
    }
    return sevenBgPalette[bin];
  }

  Color fgColorByBin(int bin) {
    if (bin > 6) {
      return MaterialPalette.blue.shadeDefault.darker;
    }
    if (zonePercents.length <= 5) {
      return fiveFgPalette[bin];
    }
    return sevenFgPalette[bin];
  }

  Color fgColorByValue(num value) {
    final bin = binIndex(value);
    return fgColorByBin(bin);
  }
}

const THRESHOLD_CAPITAL = 'Threshold ';
const ZONES_CAPITAL = ' Zones (list of % of threshold)';
const THRESHOLD_PREFIX = 'threshold_';
const ZONES_POSTFIX = '_zones';
const METRICS = ['power', 'speed', 'cadence', 'hr'];

final preferencesSpecs = [
  PreferencesSpec(
    metric: METRICS[0],
    title: 'Power',
    unit: 'W',
    thresholdTag: THRESHOLD_PREFIX + METRICS[0],
    thresholdDefault: '360',
    zonesTag: METRICS[0] + ZONES_POSTFIX,
    zonesDefault: '55,75,90,105,120,150',
    icon: Icons.bolt,
  ),
  PreferencesSpec(
    metric: METRICS[1],
    title: 'Speed',
    unit: 'mph',
    thresholdTag: THRESHOLD_PREFIX + METRICS[1],
    thresholdDefault: '20',
    zonesTag: METRICS[1] + ZONES_POSTFIX,
    zonesDefault: '55,75,90,105,120,150',
    icon: Icons.speed,
  ),
  PreferencesSpec(
    metric: METRICS[2],
    title: 'Cadence',
    unit: 'rpm',
    thresholdTag: THRESHOLD_PREFIX + METRICS[2],
    thresholdDefault: '120',
    zonesTag: METRICS[2] + ZONES_POSTFIX,
    zonesDefault: '25,37,50,75,100,120',
    icon: Icons.directions_bike,
  ),
  PreferencesSpec(
    metric: METRICS[3],
    title: 'Heart Rate',
    unit: 'bpm',
    thresholdTag: THRESHOLD_PREFIX + METRICS[3],
    thresholdDefault: '180',
    zonesTag: METRICS[3] + ZONES_POSTFIX,
    zonesDefault: '50,60,70,80,90,100',
    icon: Icons.favorite,
  ),
];

const UX_PREFERENCES = "UX Preferences";

const UNIT_SYSTEM = "Unit System";
const UNIT_SYSTEM_TAG = "unit_system";
const UNIT_SYSTEM_DEFAULT = false;
const UNIT_SYSTEM_DESCRIPTION = "On: metric (km/h speed, meters distance), " +
    "Off: imperial (mp/h speed, miles distance).";

const INSTANT_SCAN = "Instant Scanning";
const INSTANT_SCAN_TAG = "instant_scan";
const INSTANT_SCAN_DEFAULT = true;
const INSTANT_SCAN_DESCRIPTION = "On: the app will automatically start "
    "scanning for equipment after application start.";

const SCAN_DURATION = "Scan Duration";
const SCAN_DURATION_TAG = "scan_duration";
const SCAN_DURATION_DEFAULT = 3;
const SCAN_DURATION_DESCRIPTION = "Duration in seconds the app will spend " +
    "looking Bluetooth Low Energy exercise equipment.";

const INSTANT_WORKOUT = "Instant Workout";
const INSTANT_WORKOUT_TAG = "instant_workout";
const INSTANT_WORKOUT_DEFAULT = false;
const INSTANT_WORKOUT_DESCRIPTION = "On: if there's only a single " +
    "equipment after scan, or one of the devices match the " +
    "last exercise machine the app will automatically move to the " +
    "measurement screen to start recording.";

const LAST_EQUIPMENT_ID = "Last Equipment ID";
const LAST_EQUIPMENT_ID_TAG = "last_equipment";
const LAST_EQUIPMENT_ID_DEFAULT = "";
const LAST_EQUIPMENT_ID_DESCRIPTION =
    "The last exercise equipment ID " + "the app recorded a workout for";

const INSTANT_UPLOAD = "Instant Upload";
const INSTANT_UPLOAD_TAG = "instant_upload";
const INSTANT_UPLOAD_DEFAULT = false;
const INSTANT_UPLOAD_DESCRIPTION = "On: when Strava is authenticated and " +
    "the device is connected then activity upload is automatically " +
    "attempted at the end of workout";

const SIMPLER_UI = "Simplify Measurement UI";
const SIMPLER_UI_TAG = "simpler_ui";
const SIMPLER_UI_FAST_DEFAULT = false;
const SIMPLER_UI_SLOW_DEFAULT = true;
const SIMPLER_UI_DESCRIPTION = "On: the track visualization and the real-time" +
    " graphs won't be featured at the bottom of the measurement " +
    "screen. This can help old / slow phones.";

const DEVICE_FILTERING = "Device Filtering";
const DEVICE_FILTERING_TAG = "device_filtering";
const DEVICE_FILTERING_DEFAULT = true;
const DEVICE_FILTERING_DESCRIPTION =
    "Off: the app won't filter the list of Bluetooth device while scanning. " +
        "Useful if your equipment has an unexpected Bluetooth name.";

const FONT_SELECTION = "Font Selection";
const FONT_SELECTION_TAG = "font_selection";
const FONT_SELECTION_REGULAR = "Regular";
const FONT_SELECTION_14SEGMENT = "14-segment";
const FONT_SELECTION_DEFAULT = FONT_SELECTION_REGULAR;
const FONT_SELECTION_VALUES = [
  FONT_SELECTION_REGULAR,
  FONT_SELECTION_14SEGMENT,
];
const FONT_SELECTION_DESCRIPTION =
    "What font the app will use to display measurements: " +
        FONT_SELECTION_REGULAR +
        ", " +
        FONT_SELECTION_14SEGMENT;

const VIRTUAL_WORKOUT = "Virtual Workout";
const VIRTUAL_WORKOUT_TAG = "virtual_workout";
const VIRTUAL_WORKOUT_DEFAULT = true;
const VIRTUAL_WORKOUT_DESCRIPTION =
    "On: Strava upload will yield a Virtual Ride. " +
        "Off: Strava upload will yield a Ride (non virtual).";

class FontFamilyProperties {
  final String primary;
  final String secondary;

  FontFamilyProperties({
    this.primary,
    this.secondary,
  });
}

Map<String, FontFamilyProperties> fontSelectionToFamilyProperties = {
  FONT_SELECTION_REGULAR: FontFamilyProperties(
    primary: "RobotoMono",
    secondary: "RobotoMono",
  ),
  FONT_SELECTION_14SEGMENT: FontFamilyProperties(
    primary: "DSEG7",
    secondary: "DSEG14",
  ),
};

FontFamilyProperties getFontFamilyProperties() {
  final fontSelection = PrefService.getString(FONT_SELECTION_TAG);
  return fontSelectionToFamilyProperties[fontSelection];
}

const ZONE_PREFERENCES = "Zone Preferences";

Future<bool> getSimplerUiDefault() async {
  var simplerUiDefault = SIMPLER_UI_FAST_DEFAULT;
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt < 26) {
      // Remove complexities for very old Android devices
      simplerUiDefault = SIMPLER_UI_SLOW_DEFAULT;
    }
  }
  return simplerUiDefault;
}

const KM2MI = 0.621371;
const MI2KM = 1 / KM2MI;
const M2MILE = KM2MI / 1000.0;

extension DurationDisplay on Duration {
  String toDisplay() {
    return this.toString().split('.').first.padLeft(8, "0");
  }
}
