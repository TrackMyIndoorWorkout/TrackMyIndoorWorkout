import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import '../utils/constants.dart';
import '../utils/display.dart';
import 'palettes.dart';

// https://stackoverflow.com/questions/57481767/dart-rounding-errors
double decimalRound(double value, {int precision = 100}) {
  return (value * precision).round() / precision;
}

const TARGET_HR_SHORT_TITLE = "Target HR";
const SLOW_SPEED_POSTFIX = " Speed (kmh) Considered Too Slow to Display";
const SLOW_SPEED_TAG_PREFIX = "slow_speed_";

class PreferencesSpec {
  static const THRESHOLD_CAPITAL = " Threshold ";
  static const ZONES_CAPITAL = " Zones (list of % of threshold)";
  static const PADDLE_SPORT = "Paddle";
  static const SPORT_PREFIXES = [
    ActivityType.Ride,
    ActivityType.Run,
    PADDLE_SPORT,
    ActivityType.Swim
  ];
  static const THRESHOLD_PREFIX = "threshold_";
  static const ZONES_POSTFIX = "_zones";
  static const METRICS = ["power", "speed", "cadence", "hr"];
  static const ZONE_INDEX_DISPLAY_TAG_POSTFIX = "zone_index_display";
  static const ZONE_INDEX_DISPLAY_TEXT = "Zone Index Display";
  static const ZONE_INDEX_DISPLAY_DESCRIPTION_PART1 = "Display the Zone Index Next to the ";
  static const ZONE_INDEX_DISPLAY_DESCRIPTION_PART2 = " Measurement Value";
  static const ZONE_INDEX_DISPLAY_EXTRA_NOTE =
      "These Zone settings apply for the fixed panel sections. " +
          "For extra HR zone display feature check out '$TARGET_HR_SHORT_TITLE' configuration " +
          "in the upstream settings selection. For extra speed feedback check out leaderboard rank settings.";
  static const ZONE_INDEX_DISPLAY_DEFAULT = false;

  static final slowSpeeds = {
    ActivityType.Ride: 5.0,
    ActivityType.Run: 3.0,
    PADDLE_SPORT: 2.0,
    ActivityType.Swim: 1.0,
  };

  static final _preferencesSpecsTemplate = [
    PreferencesSpec(
      metric: METRICS[0],
      title: "Power",
      unit: "W",
      thresholdTagPostfix: THRESHOLD_PREFIX + METRICS[0],
      thresholdDefaultInts: {
        SPORT_PREFIXES[0]: 360,
        SPORT_PREFIXES[1]: 360,
        SPORT_PREFIXES[2]: 120,
        SPORT_PREFIXES[3]: 120,
      },
      zonesTagPostfix: METRICS[0] + ZONES_POSTFIX,
      zonesDefaultInts: {
        SPORT_PREFIXES[0]: [55, 75, 90, 105, 120, 150],
        SPORT_PREFIXES[1]: [55, 75, 90, 105, 120, 150],
        SPORT_PREFIXES[2]: [55, 75, 90, 105, 120, 150],
        SPORT_PREFIXES[3]: [55, 75, 90, 105, 120, 150],
      },
      icon: Icons.bolt,
      indexDisplayDefault: false,
    ),
    PreferencesSpec(
      metric: METRICS[1],
      title: "Speed",
      unit: "mph",
      thresholdTagPostfix: THRESHOLD_PREFIX + METRICS[1],
      thresholdDefaultInts: {
        SPORT_PREFIXES[0]: 32,
        SPORT_PREFIXES[1]: 16,
        SPORT_PREFIXES[2]: 7,
        SPORT_PREFIXES[3]: 1,
      },
      zonesTagPostfix: METRICS[1] + ZONES_POSTFIX,
      zonesDefaultInts: {
        SPORT_PREFIXES[0]: [55, 75, 90, 105, 120, 150],
        SPORT_PREFIXES[1]: [55, 75, 90, 105, 120, 150],
        SPORT_PREFIXES[2]: [55, 75, 90, 105, 120, 150],
        SPORT_PREFIXES[3]: [55, 75, 90, 105, 120, 150],
      },
      icon: Icons.speed,
      indexDisplayDefault: false,
    ),
    PreferencesSpec(
      metric: METRICS[2],
      title: "Cadence",
      unit: "rpm",
      thresholdTagPostfix: THRESHOLD_PREFIX + METRICS[2],
      thresholdDefaultInts: {
        SPORT_PREFIXES[0]: 120,
        SPORT_PREFIXES[1]: 180,
        SPORT_PREFIXES[2]: 90,
        SPORT_PREFIXES[3]: 90,
      },
      zonesTagPostfix: METRICS[2] + ZONES_POSTFIX,
      zonesDefaultInts: {
        SPORT_PREFIXES[0]: [25, 37, 50, 75, 100, 120],
        SPORT_PREFIXES[1]: [25, 37, 50, 75, 100, 120],
        SPORT_PREFIXES[2]: [25, 37, 50, 75, 100, 120],
        SPORT_PREFIXES[3]: [25, 37, 50, 75, 100, 120],
      },
      icon: Icons.directions_bike,
      indexDisplayDefault: false,
    ),
    PreferencesSpec(
      metric: METRICS[3],
      title: "Heart Rate",
      unit: "bpm",
      thresholdTagPostfix: THRESHOLD_PREFIX + METRICS[3],
      thresholdDefaultInts: {
        SPORT_PREFIXES[0]: 180,
        SPORT_PREFIXES[1]: 180,
        SPORT_PREFIXES[2]: 180,
        SPORT_PREFIXES[3]: 180,
      },
      zonesTagPostfix: METRICS[3] + ZONES_POSTFIX,
      zonesDefaultInts: {
        SPORT_PREFIXES[0]: [50, 60, 70, 80, 90, 100],
        SPORT_PREFIXES[1]: [50, 60, 70, 80, 90, 100],
        SPORT_PREFIXES[2]: [50, 60, 70, 80, 90, 100],
        SPORT_PREFIXES[3]: [50, 60, 70, 80, 90, 100],
      },
      icon: Icons.favorite,
      indexDisplayDefault: false,
    ),
  ].toList(growable: false);

  final String metric;
  String title;
  String unit;
  String multiLineUnit = "";
  final String thresholdTagPostfix;
  final Map<String, int> thresholdDefaultInts;
  final String zonesTagPostfix;
  final Map<String, List<int>> zonesDefaultInts;
  final bool indexDisplayDefault;
  IconData icon;
  bool indexDisplay = false;
  double threshold = 0.0;
  List<int> zonePercents = [];
  List<double> zoneBounds = [];
  List<double> zoneLower = [];
  List<double> zoneUpper = [];
  bool si = false;
  String sport = ActivityType.Ride;

  late List<charts.PlotBand> plotBands;
  TextStyle _bandTextStyle = const TextStyle(
    fontFamily: FONT_FAMILY,
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: Colors.grey,
  );

  PreferencesSpec({
    required this.metric,
    required this.title,
    required this.unit,
    required this.thresholdTagPostfix,
    required this.thresholdDefaultInts,
    required this.zonesTagPostfix,
    required this.zonesDefaultInts,
    required this.indexDisplayDefault,
    required this.icon,
  }) {
    updateMultiLineUnit();
    plotBands = [];
    indexDisplay = indexDisplayDefault;
  }

  String get fullTitle => "$title ($unit)";
  String get kmhTitle => "$title (kmh)";
  String get histogramTitle => "$title zones (%)";

  String get zoneIndexText => "$title $ZONE_INDEX_DISPLAY_TEXT";
  String get zoneIndexTag => "${metric}_$ZONE_INDEX_DISPLAY_TAG_POSTFIX";
  String get zoneIndexDescription =>
      "$ZONE_INDEX_DISPLAY_DESCRIPTION_PART1 $title $ZONE_INDEX_DISPLAY_DESCRIPTION_PART2";

  static String sport2Sport(String sport) {
    return sport == ActivityType.Kayaking ||
            sport == ActivityType.Canoeing ||
            sport == ActivityType.Rowing
        ? PADDLE_SPORT
        : sport;
  }

  String thresholdDefault(String sport) {
    return thresholdDefaultInts[sport2Sport(sport)].toString();
  }

  String zonesDefault(String sport) {
    return zonesDefaultInts[sport2Sport(sport)]!.map((z) => z.toString()).join(",");
  }

  String thresholdTag(String sport) {
    return sport2Sport(sport) + "_" + thresholdTagPostfix;
  }

  String zonesTag(String sport) {
    return sport2Sport(sport) + "_" + zonesTagPostfix;
  }

  static String slowSpeedTag(String sport) {
    return SLOW_SPEED_TAG_PREFIX + sport2Sport(sport);
  }

  void updateMultiLineUnit() {
    multiLineUnit = unit.replaceAll(" ", "\n");
  }

  void updateUnit(String newUnit) {
    unit = newUnit;
    updateMultiLineUnit();
  }

  void calculateZones(bool si, String sport) {
    this.si = si;
    this.sport = sport;
    final prefService = Get.find<BasePrefService>();
    final thresholdString = prefService.get<String>(thresholdTag(sport))!;
    threshold = double.tryParse(thresholdString) ?? EPS;
    if (metric == "speed") {
      threshold = speedByUnitCore(threshold, si);
    }

    final zonesSpecStr = prefService.get<String>(zonesTag(sport))!;
    zonePercents =
        zonesSpecStr.split(',').map((zs) => int.tryParse(zs) ?? 0).toList(growable: false);
    zoneBounds =
        zonePercents.map((z) => decimalRound(z / 100.0 * threshold)).toList(growable: false);
    indexDisplay = prefService.get<bool>(zoneIndexTag) ?? indexDisplayDefault;
  }

  void calculateBounds(double minVal, double maxVal, bool isLight) {
    zoneLower = [...zoneBounds];
    zoneUpper = [...zoneBounds];

    final zoneMin = zoneLower[0];
    if (minVal < 0 || minVal > 0 && minVal > zoneMin) {
      minVal = zoneMin * 0.7;
    }

    final zoneMax = zoneUpper.last;
    if (maxVal < 0 || maxVal > 0 && maxVal < zoneMax) {
      maxVal = zoneMax * 1.2;
    }

    zoneLower.insert(0, decimalRound(minVal));
    zoneUpper.add(decimalRound(maxVal));
    plotBands.clear();
    plotBands.addAll(List.generate(
      binCount,
      (i) => charts.PlotBand(
        isVisible: true,
        start: zoneLower[i],
        end: zoneUpper[i],
        color: bgColorByBin(i, isLight),
        text: "${zoneLower[i]} - ${zoneUpper[i]}",
        textStyle: _bandTextStyle,
        horizontalTextAlignment: charts.TextAnchor.start,
        verticalTextAlignment: charts.TextAnchor.end,
      ),
    ));
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

  Color bgColorByBin(int bin, bool isLight) {
    if (zonePercents.length <= 5) {
      bin = min(bin, 4);
      return isLight ? fiveLightBgPalette[bin] : fiveDarkBgPalette[bin];
    }

    bin = min(bin, 6);
    return isLight ? sevenLightBgPalette[bin] : sevenDarkBgPalette[bin];
  }

  Color fgColorByBin(int bin, bool isLight) {
    if (zonePercents.length <= 5) {
      bin = min(bin, 4);
      return isLight ? fiveLightFgPalette[bin] : fiveDarkFgPalette[bin];
    }

    bin = min(bin, 6);
    return isLight ? sevenLightFgPalette[bin] : sevenDarkFgPalette[bin];
  }

  /*
  Color fgColorByValue(num value, bool isLight) {
    final bin = binIndex(value);
    return fgColorByBin(bin, isLight);
  }

  Color pieBgColorByBin(int bin, bool isLight) {
    if (zonePercents.length <= 5) {
      bin = min(bin, 4);
      return isLight ? fiveLightPiePalette[bin] : fiveDarkPiePalette[bin];
    }

    bin = min(bin, 6);
    return isLight ? sevenLightPiePalette[bin] : sevenDarkPiePalette[bin];
  }
  */

  List<Color> getPiePalette(bool isLight) {
    if (zonePercents.length <= 5) {
      return isLight ? fiveDarkFgPalette : fiveLightFgPalette;
    } else {
      return isLight ? sevenDarkFgPalette : sevenLightFgPalette;
    }
  }

  static List<PreferencesSpec> get preferencesSpecs => _preferencesSpecsTemplate;

  static List<PreferencesSpec> getPreferencesSpecs(bool si, String sport) {
    var prefSpecs = [...preferencesSpecs];
    prefSpecs[1].updateUnit(getSpeedUnit(si, sport));
    prefSpecs[1].title = speedTitle(sport);
    prefSpecs[2].icon = getIcon(sport);
    prefSpecs[2].unit = getCadenceUnit(sport);
    prefSpecs.forEach((prefSpec) => prefSpec.calculateZones(si, sport));
    return prefSpecs;
  }
}
