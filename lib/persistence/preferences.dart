import 'package:charts_flutter/flutter.dart';
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
    this.thresholdTag,
    this.thresholdDefault,
    this.zonesTag,
    this.zonesDefault,
  });

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
const ZONES_CAPITAL = ' Zones';
const THRESHOLD_PREFIX = 'threshold_';
const ZONES_POSTFIX = '_zones';
const METRICS = ['power', 'speed', 'cadence', 'hr'];

final preferencesSpecs = [
  PreferencesSpec(
    metric: METRICS[0],
    title: 'Power',
    thresholdTag: THRESHOLD_PREFIX + METRICS[0],
    thresholdDefault: '360',
    zonesTag: METRICS[0] + ZONES_POSTFIX,
    zonesDefault: '55,75,90,105,120,150',
  ),
  PreferencesSpec(
    metric: METRICS[1],
    title: 'Speed',
    thresholdTag: THRESHOLD_PREFIX + METRICS[1],
    thresholdDefault: '30',
    zonesTag: METRICS[1] + ZONES_POSTFIX,
    zonesDefault: '55,75,90,105,120,150',
  ),
  PreferencesSpec(
    metric: METRICS[2],
    title: 'Cadence',
    thresholdTag: THRESHOLD_PREFIX + METRICS[2],
    thresholdDefault: '120',
    zonesTag: METRICS[2] + ZONES_POSTFIX,
    zonesDefault: '25,37,50,75,100,120',
  ),
  PreferencesSpec(
    metric: METRICS[3],
    title: 'Heart Rate',
    thresholdTag: THRESHOLD_PREFIX + METRICS[3],
    thresholdDefault: '180',
    zonesTag: METRICS[3] + ZONES_POSTFIX,
    zonesDefault: '50,60,70,80,90,100',
  ),
];
