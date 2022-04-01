import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import '../ui/models/row_configuration.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import 'palettes.dart';

// https://stackoverflow.com/questions/57481767/dart-rounding-errors
double decimalRound(double value, {int precision = 100}) {
  return (value * precision).round() / precision;
}

const targetHrShortTitle = "Target HR";
const slowSpeedPostfix = " Speed (kmh) Considered Too Slow to Display";
const slowSpeedTagPrefix = "slow_speed_";

class MetricSpec {
  static const thresholdCapital = " Threshold ";
  static const zonesCapital = " Zones (list of % of threshold)";
  static const paddleSport = "Paddle";
  static const sportPrefixes = [
    ActivityType.ride,
    ActivityType.run,
    paddleSport,
    ActivityType.swim,
    ActivityType.elliptical,
  ];
  static const thresholdPrefix = "threshold_";
  static const zonesPostfix = "_zones";
  static const metrics = ["power", "speed", "cadence", "hr"];
  static const zoneIndexDisplayTagPostfix = "zone_index_display";
  static const zoneIndexDisplayText = "Zone Index Display";
  static const zoneIndexDisplayDescriptionPart1 = "Display the Zone Index Next to the ";
  static const zoneIndexDisplayDescriptionPart2 = " Measurement Value";
  static const zoneIndexDisplayExtraNote =
      "These Zone settings apply for the fixed panel sections. "
      "For extra HR zone display feature check out '$targetHrShortTitle' configuration "
      "in the upstream settings selection. For extra speed feedback check out leaderboard rank settings.";
  static const zoneIndexDisplayDefault = false;
  static const veryOldZoneBoundaries = "55,75,90,105,120,150";

  static final slowSpeeds = {
    ActivityType.ride: 4.0,
    ActivityType.run: 2.0,
    paddleSport: 1.0,
    ActivityType.swim: 0.5,
    ActivityType.elliptical: 1.0,
  };

  static final _preferencesSpecsTemplate = [
    MetricSpec(
      metric: metrics[0],
      title: "Power",
      unit: "W",
      thresholdTagPostfix: thresholdPrefix + metrics[0],
      oldThresholdDefaultInts: {
        sportPrefixes[0]: 300,
        sportPrefixes[1]: 180,
        sportPrefixes[2]: 100,
        sportPrefixes[3]: 100,
        sportPrefixes[4]: 180,
      },
      thresholdDefaultInts: {
        sportPrefixes[0]: 320,
        sportPrefixes[1]: 180,
        sportPrefixes[2]: 100,
        sportPrefixes[3]: 100,
        sportPrefixes[4]: 180,
      },
      zonesTagPostfix: metrics[0] + zonesPostfix,
      oldZoneDefaultInts: [55, 75, 90, 105, 120, 150],
      zonesDefaultInts: {
        sportPrefixes[0]: [55, 75, 90, 105, 120, 150],
        sportPrefixes[1]: [55, 75, 90, 105, 120, 150],
        sportPrefixes[2]: [55, 75, 90, 105, 120, 150],
        sportPrefixes[3]: [55, 75, 90, 105, 120, 150],
        sportPrefixes[4]: [55, 75, 90, 105, 120, 150],
      },
      icon: Icons.bolt,
      indexDisplayDefault: false,
    ),
    MetricSpec(
      metric: metrics[1],
      title: "Speed",
      unit: "mph",
      thresholdTagPostfix: thresholdPrefix + metrics[1],
      oldThresholdDefaultInts: {
        sportPrefixes[0]: 32,
        sportPrefixes[1]: 16,
        sportPrefixes[2]: 7,
        sportPrefixes[3]: 1,
        sportPrefixes[4]: 7,
      },
      thresholdDefaultInts: {
        sportPrefixes[0]: 42,
        sportPrefixes[1]: 14,
        sportPrefixes[2]: 7,
        sportPrefixes[3]: 1,
        sportPrefixes[4]: 7,
      },
      zonesTagPostfix: metrics[1] + zonesPostfix,
      oldZoneDefaultInts: [55, 75, 90, 105, 120, 150],
      zonesDefaultInts: {
        sportPrefixes[0]: [77, 87, 94, 100, 104, 112],
        sportPrefixes[1]: [77, 87, 94, 100, 104, 112],
        sportPrefixes[2]: [77, 87, 94, 100, 104, 112],
        sportPrefixes[3]: [77, 87, 94, 100, 104, 112],
        sportPrefixes[4]: [77, 87, 94, 100, 104, 112],
      },
      icon: Icons.speed,
      indexDisplayDefault: false,
    ),
    MetricSpec(
      metric: metrics[2],
      title: "Cadence",
      unit: "rpm",
      thresholdTagPostfix: thresholdPrefix + metrics[2],
      oldThresholdDefaultInts: {
        sportPrefixes[0]: 100,
        sportPrefixes[1]: 180,
        sportPrefixes[2]: 90,
        sportPrefixes[3]: 90,
        sportPrefixes[4]: 90,
      },
      thresholdDefaultInts: {
        sportPrefixes[0]: 100,
        sportPrefixes[1]: 170,
        sportPrefixes[2]: 85,
        sportPrefixes[3]: 80,
        sportPrefixes[4]: 150,
      },
      zonesTagPostfix: metrics[2] + zonesPostfix,
      oldZoneDefaultInts: [25, 37, 50, 75, 100, 120],
      zonesDefaultInts: {
        sportPrefixes[0]: [25, 37, 50, 75, 100, 120],
        sportPrefixes[1]: [77, 87, 94, 100, 104, 112],
        sportPrefixes[2]: [77, 87, 94, 100, 104, 112],
        sportPrefixes[3]: [77, 87, 94, 100, 104, 112],
        sportPrefixes[4]: [77, 87, 94, 100, 104, 112],
      },
      icon: Icons.directions_bike,
      indexDisplayDefault: false,
    ),
    MetricSpec(
      metric: metrics[3],
      title: "Heart Rate",
      unit: "bpm",
      thresholdTagPostfix: thresholdPrefix + metrics[3],
      oldThresholdDefaultInts: {
        sportPrefixes[0]: 180,
        sportPrefixes[1]: 180,
        sportPrefixes[2]: 180,
        sportPrefixes[3]: 180,
        sportPrefixes[4]: 180,
      },
      thresholdDefaultInts: {
        sportPrefixes[0]: 153,
        sportPrefixes[1]: 153,
        sportPrefixes[2]: 153,
        sportPrefixes[3]: 153,
        sportPrefixes[4]: 153,
      },
      zonesTagPostfix: metrics[3] + zonesPostfix,
      oldZoneDefaultInts: [50, 60, 70, 80, 90, 100],
      zonesDefaultInts: {
        sportPrefixes[0]: [80, 88, 92, 152, 156, 163],
        sportPrefixes[1]: [80, 88, 92, 152, 156, 163],
        sportPrefixes[2]: [80, 88, 92, 152, 156, 163],
        sportPrefixes[3]: [80, 88, 92, 152, 156, 163],
        sportPrefixes[4]: [80, 88, 92, 152, 156, 163],
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
  final Map<String, int> oldThresholdDefaultInts;
  final Map<String, int> thresholdDefaultInts;
  final String zonesTagPostfix;
  final List<int> oldZoneDefaultInts;
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
  String sport = ActivityType.ride;

  late List<charts.PlotBand> plotBands;

  MetricSpec({
    required this.metric,
    required this.title,
    required this.unit,
    required this.thresholdTagPostfix,
    required this.oldThresholdDefaultInts,
    required this.thresholdDefaultInts,
    required this.zonesTagPostfix,
    required this.oldZoneDefaultInts,
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

  String get zoneIndexText => "$title $zoneIndexDisplayText";
  String get zoneIndexTag => "${metric}_$zoneIndexDisplayTagPostfix";
  String get zoneIndexDescription =>
      "$zoneIndexDisplayDescriptionPart1 $title $zoneIndexDisplayDescriptionPart2";

  static String sport2Sport(String sport) {
    return sport == ActivityType.kayaking ||
            sport == ActivityType.canoeing ||
            sport == ActivityType.rowing
        ? paddleSport
        : sport;
  }

  String oldThresholdDefault(String sport) {
    return oldThresholdDefaultInts[sport2Sport(sport)].toString();
  }

  String thresholdDefault(String sport) {
    return thresholdDefaultInts[sport2Sport(sport)].toString();
  }

  String intArrayToString(List<int> intArray) {
    return intArray.map((z) => z.toString()).join(",");
  }

  String oldZoneDefault(String sport) {
    return intArrayToString(oldZoneDefaultInts);
  }

  String zonesDefault(String sport) {
    return intArrayToString(zonesDefaultInts[sport2Sport(sport)]!);
  }

  String thresholdTag(String sport) {
    return sport2Sport(sport) + "_" + thresholdTagPostfix;
  }

  String zonesTag(String sport) {
    return sport2Sport(sport) + "_" + zonesTagPostfix;
  }

  static String slowSpeedTag(String sport) {
    return slowSpeedTagPrefix + sport2Sport(sport);
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
    threshold = double.tryParse(thresholdString) ?? eps;
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

    final bandTextStyle = TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.bold,
      fontSize: 11,
      color: isLight ? Colors.grey.shade700 : Colors.grey.shade200,
    );

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
        textStyle: bandTextStyle,
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

  static int determinePalette(int boundLength) {
    return max(5, min(7, boundLength + 1));
  }

  Color bgColorByBin(int bin, bool isLight) {
    final paletteSize = determinePalette(zonePercents.length);
    final binMax = paletteSize - 1;
    bin = min(bin, binMax);
    return isLight
        ? lightBgPaletteDefaults[paletteSize]![bin]
        : darkBgPaletteDefaults[paletteSize]![bin];
  }

  Color fgColorByBin(int bin, bool isLight) {
    final paletteSize = determinePalette(zonePercents.length);
    final binMax = paletteSize - 1;
    bin = min(bin, binMax);
    return isLight
        ? lightFgPaletteDefaults[paletteSize]![bin]
        : darkFgPaletteDefaults[paletteSize]![bin];
  }

  List<Color> getPiePalette(bool isLight) {
    final paletteSize = determinePalette(zonePercents.length);
    return isLight ? darkFgPaletteDefaults[paletteSize]! : lightFgPaletteDefaults[paletteSize]!;
  }

  static List<MetricSpec> get preferencesSpecs => _preferencesSpecsTemplate;

  static List<MetricSpec> getPreferencesSpecs(bool si, String sport) {
    var prefSpecs = [...preferencesSpecs];
    prefSpecs[1].updateUnit(getSpeedUnit(si, sport));
    prefSpecs[1].title = speedTitle(sport);
    prefSpecs[2].icon = getIcon(sport);
    prefSpecs[2].unit = getCadenceUnit(sport);
    for (var prefSpec in prefSpecs) {
      prefSpec.calculateZones(si, sport);
    }

    return prefSpecs;
  }

  static List<RowConfiguration> getRowConfigurations([String sport = ActivityType.ride]) {
    var rowConfigs = preferencesSpecs
        .map((p) => RowConfiguration(
              title: p.title,
              icon: p.icon,
              unit: p.unit,
            ))
        .toList();
    rowConfigs.add(RowConfiguration(
      title: "Distance",
      icon: Icons.add_road,
      unit: "m",
    ));

    return rowConfigs;
  }
}
