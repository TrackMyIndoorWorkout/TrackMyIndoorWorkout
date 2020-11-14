import 'dart:io';

import 'package:charts_flutter/flutter.dart';
import 'package:device_info/device_info.dart';
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

  PreferencesSpec({
    this.metric,
    this.title,
    this.unit,
    this.thresholdTag,
    this.thresholdDefault,
    this.zonesTag,
    this.zonesDefault,
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
    zoneBounds = zonePercents.map((z) => z / 100.0 * threshold).toList();
  }

  calculateBounds(double minVal, double maxVal) {
    zoneLower = [...zoneBounds];
    zoneLower.insert(0, minVal);
    zoneUpper = [...zoneBounds];
    zoneUpper.add(maxVal);
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

  Color binBgColor(int bin) {
    if (bin > 6) {
      return getTranslucent(MaterialPalette.blue.shadeDefault.lighter);
    }
    if (zonePercents.length <= 5) {
      return fiveBgPalette[bin];
    }
    return sevenBgPalette[bin];
  }

  Color binFgColor(num value) {
    final bin = binIndex(value);
    if (bin > 6) {
      return MaterialPalette.blue.shadeDefault.darker;
    }
    if (zonePercents.length <= 5) {
      return fiveFgPalette[bin];
    }
    return sevenFgPalette[bin];
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
  ),
  PreferencesSpec(
    metric: METRICS[1],
    title: 'Speed',
    unit: 'mph',
    thresholdTag: THRESHOLD_PREFIX + METRICS[1],
    thresholdDefault: '20',
    zonesTag: METRICS[1] + ZONES_POSTFIX,
    zonesDefault: '55,75,90,105,120,150',
  ),
  PreferencesSpec(
    metric: METRICS[2],
    title: 'Cadence',
    unit: 'rpm',
    thresholdTag: THRESHOLD_PREFIX + METRICS[2],
    thresholdDefault: '120',
    zonesTag: METRICS[2] + ZONES_POSTFIX,
    zonesDefault: '25,37,50,75,100,120',
  ),
  PreferencesSpec(
    metric: METRICS[3],
    title: 'Heart Rate',
    unit: 'bpm',
    thresholdTag: THRESHOLD_PREFIX + METRICS[3],
    thresholdDefault: '180',
    zonesTag: METRICS[3] + ZONES_POSTFIX,
    zonesDefault: '50,60,70,80,90,100',
  ),
];

const DEVICE_FILTERING = "Device Filtering";
const DEVICE_FILTERING_TAG = "device_filtering";
const DEVICE_FILTERING_DEFAULT = true;
const DEVICE_FILTERING_DESCRIPTION =
    "Off: the app won't filter the list of Bluetooth device while scanning. " +
        "Useful if your equipment has an unexpected Bluetooth name.";

const UNIT_SYSTEM = "Unit System";
const UNIT_SYSTEM_TAG = "unit_system";
const UNIT_SYSTEM_DEFAULT = false; // false: Imperial, true: Metric
const UNIT_SYSTEM_DESCRIPTION = "On: metric (km/h speed, meters distance), " +
    "Off: imperial (mp/h speed, miles distance).";

const SIMPLER_UI = "Simplify Measurement UI";
const SIMPLER_UI_TAG = "simpler_ui";
const SIMPLER_UI_FAST_DEFAULT = false;
const SIMPLER_UI_SLOW_DEFAULT = true;
const SIMPLER_UI_DESCRIPTION = "On: the track visualization and the real-time" +
    " graphs won't be featured at the bottom of the measurement " +
    "screen. This can help old / slow phones.";

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

const KMH2MPH = 0.621371;
const M2MILE = KMH2MPH / 1000.0;

extension DurationDisplay on Duration {
  String toDisplay() {
    return this.toString().split('.').first.padLeft(8, "0");
  }
}
