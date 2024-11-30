import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;

import '../preferences/sport_spec.dart';
import '../ui/models/row_configuration.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import 'palette_spec.dart';

// https://stackoverflow.com/questions/57481767/dart-rounding-errors
double decimalRound(double value, {int precision = 100}) {
  return (value * precision).round() / precision;
}

const targetHrShortTitle = "Target HR";

class MetricSpec {
  static const thresholdCapital = " Threshold ";
  static const zonesCapital = " Zones (list of % of threshold)";
  static const thresholdPrefix = "threshold_";
  static const zonesPostfix = "_zones";
  static const metrics = ["power", "speed", "cadence", "hr"];
  static const zoneIndexDisplayTagPostfix = "zone_index_display";
  static const zoneIndexDisplayText = "Zone Index Display";
  static const zoneIndexDisplayDescriptionPart1 = "Display the Zone Index Next to the ";
  static const zoneIndexDisplayDescriptionPart2 = " Measurement Value";
  static const coloringByZoneTagPostfix = "coloring_by_zone";
  static const coloringByZoneTitle = "Coloring by Zone";
  static const coloringByZoneDescriptionPart1 = "Color the ";
  static const coloringByZoneDescriptionPart2 = " Measurement based on the Zone";
  static const zoneIndexDisplayExtraNote = "These settings are for non cumulative metrics. "
      "For extra HR zone display feature check out '$targetHrShortTitle' configuration. "
      "For extra speed feedback check out leaderboard rank settings.";
  static const zoneIndexDisplayDefault = false;
  static const veryOldZoneBoundaries = "55,75,90,105,120,150";

  static final _preferencesSpecsTemplate = [
    MetricSpec(
      metric: metrics[0],
      title: "Power",
      unit: "W",
      thresholdTagPostfix: thresholdPrefix + metrics[0],
      oldThresholdDefaultInts: {
        SportSpec.sportPrefixes[0]: 300,
        SportSpec.sportPrefixes[1]: 180,
        SportSpec.sportPrefixes[2]: 100,
        SportSpec.sportPrefixes[3]: 100,
        SportSpec.sportPrefixes[4]: 180,
      },
      thresholdDefaultInts: {
        SportSpec.sportPrefixes[0]: 320,
        SportSpec.sportPrefixes[1]: 180,
        SportSpec.sportPrefixes[2]: 100,
        SportSpec.sportPrefixes[3]: 100,
        SportSpec.sportPrefixes[4]: 180,
      },
      zonesTagPostfix: metrics[0] + zonesPostfix,
      oldZoneDefaultInts: [55, 75, 90, 105, 120, 150],
      zonesDefaultInts: {
        SportSpec.sportPrefixes[0]: [55, 75, 90, 105, 120, 150],
        SportSpec.sportPrefixes[1]: [55, 75, 90, 105, 120, 150],
        SportSpec.sportPrefixes[2]: [55, 75, 90, 105, 120, 150],
        SportSpec.sportPrefixes[3]: [55, 75, 90, 105, 120, 150],
        SportSpec.sportPrefixes[4]: [55, 75, 90, 105, 120, 150],
      },
      icon: Icons.bolt,
      indexDisplayDefault: false,
      coloringByZoneDefault: false,
    ),
    MetricSpec(
      metric: metrics[1],
      title: "Speed",
      unit: "mph",
      thresholdTagPostfix: thresholdPrefix + metrics[1],
      oldThresholdDefaultInts: {
        SportSpec.sportPrefixes[0]: 32,
        SportSpec.sportPrefixes[1]: 16,
        SportSpec.sportPrefixes[2]: 7,
        SportSpec.sportPrefixes[3]: 1,
        SportSpec.sportPrefixes[4]: 7,
      },
      thresholdDefaultInts: {
        SportSpec.sportPrefixes[0]: 42,
        SportSpec.sportPrefixes[1]: 14,
        SportSpec.sportPrefixes[2]: 7,
        SportSpec.sportPrefixes[3]: 1,
        SportSpec.sportPrefixes[4]: 7,
      },
      zonesTagPostfix: metrics[1] + zonesPostfix,
      oldZoneDefaultInts: [55, 75, 90, 105, 120, 150],
      zonesDefaultInts: {
        SportSpec.sportPrefixes[0]: [77, 87, 94, 100, 104, 112],
        SportSpec.sportPrefixes[1]: [77, 87, 94, 100, 104, 112],
        SportSpec.sportPrefixes[2]: [77, 87, 94, 100, 104, 112],
        SportSpec.sportPrefixes[3]: [77, 87, 94, 100, 104, 112],
        SportSpec.sportPrefixes[4]: [77, 87, 94, 100, 104, 112],
      },
      icon: Icons.speed,
      indexDisplayDefault: false,
      coloringByZoneDefault: false,
    ),
    MetricSpec(
      metric: metrics[2],
      title: "Cadence",
      unit: "rpm",
      thresholdTagPostfix: thresholdPrefix + metrics[2],
      oldThresholdDefaultInts: {
        SportSpec.sportPrefixes[0]: 100,
        SportSpec.sportPrefixes[1]: 180,
        SportSpec.sportPrefixes[2]: 90,
        SportSpec.sportPrefixes[3]: 90,
        SportSpec.sportPrefixes[4]: 90,
      },
      thresholdDefaultInts: {
        SportSpec.sportPrefixes[0]: 100,
        SportSpec.sportPrefixes[1]: 170,
        SportSpec.sportPrefixes[2]: 85,
        SportSpec.sportPrefixes[3]: 80,
        SportSpec.sportPrefixes[4]: 150,
      },
      zonesTagPostfix: metrics[2] + zonesPostfix,
      oldZoneDefaultInts: [25, 37, 50, 75, 100, 120],
      zonesDefaultInts: {
        SportSpec.sportPrefixes[0]: [25, 37, 50, 75, 100, 120],
        SportSpec.sportPrefixes[1]: [77, 87, 94, 100, 104, 112],
        SportSpec.sportPrefixes[2]: [77, 87, 94, 100, 104, 112],
        SportSpec.sportPrefixes[3]: [77, 87, 94, 100, 104, 112],
        SportSpec.sportPrefixes[4]: [77, 87, 94, 100, 104, 112],
      },
      icon: Icons.directions_bike,
      indexDisplayDefault: false,
      coloringByZoneDefault: false,
    ),
    MetricSpec(
      metric: metrics[3],
      title: "Heart Rate",
      unit: "bpm",
      thresholdTagPostfix: thresholdPrefix + metrics[3],
      oldThresholdDefaultInts: {
        SportSpec.sportPrefixes[0]: 180,
        SportSpec.sportPrefixes[1]: 180,
        SportSpec.sportPrefixes[2]: 180,
        SportSpec.sportPrefixes[3]: 180,
        SportSpec.sportPrefixes[4]: 180,
      },
      thresholdDefaultInts: {
        SportSpec.sportPrefixes[0]: 153,
        SportSpec.sportPrefixes[1]: 153,
        SportSpec.sportPrefixes[2]: 153,
        SportSpec.sportPrefixes[3]: 153,
        SportSpec.sportPrefixes[4]: 153,
      },
      zonesTagPostfix: metrics[3] + zonesPostfix,
      // This was based on Max HR not, Threshold HR
      oldZoneDefaultInts: [50, 60, 70, 80, 90, 100],
      // 7 zones based on Lactate Threshold Heart Rate (according to Gemini):
      // 1, <85%, Very easy, Recovery
      // 2, 85-89%, Easy Aerobic
      // 3, 90-94%, Moderate
      // 4, 95-99%, Somewhat hard
      // 5a, 100-102%, Hard
      // 5b, 103-106%, Very hard
      // 5c, >106%, Maximal
      zonesDefaultInts: {
        SportSpec.sportPrefixes[0]: [85, 90, 95, 100, 103, 106],
        SportSpec.sportPrefixes[1]: [85, 90, 95, 100, 103, 106],
        SportSpec.sportPrefixes[2]: [85, 90, 95, 100, 103, 106],
        SportSpec.sportPrefixes[3]: [85, 90, 95, 100, 103, 106],
        SportSpec.sportPrefixes[4]: [85, 90, 95, 100, 103, 106],
      },
      icon: Icons.favorite,
      indexDisplayDefault: false,
      coloringByZoneDefault: false,
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
  final bool coloringByZoneDefault;
  IconData icon;
  bool indexDisplay = false;
  bool coloringByZone = false;
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
    required this.coloringByZoneDefault,
    required this.icon,
  }) {
    updateMultiLineUnit();
    plotBands = [];
    indexDisplay = indexDisplayDefault;
    coloringByZone = coloringByZoneDefault;
  }

  String get fullTitle => "$title ($unit)";
  String get kmhTitle => "$title (kmh)";
  String get histogramTitle => "$title zones (%)";

  String get zoneIndexText => "$title $zoneIndexDisplayText";
  String get zoneIndexTag => "${metric}_$zoneIndexDisplayTagPostfix";
  String get zoneIndexDescription =>
      "$zoneIndexDisplayDescriptionPart1 $title $zoneIndexDisplayDescriptionPart2";

  String get coloringByZoneText => "$title $coloringByZoneTitle";
  String get coloringByZoneTag => "${metric}_$coloringByZoneTagPostfix";
  String get coloringByZoneDescription =>
      "$coloringByZoneDescriptionPart1 $title $coloringByZoneDescriptionPart2";

  String oldThresholdDefault(String sport) {
    return oldThresholdDefaultInts[SportSpec.sport2Sport(sport)].toString();
  }

  String thresholdDefault(String sport) {
    return thresholdDefaultInts[SportSpec.sport2Sport(sport)].toString();
  }

  String intArrayToString(List<int> intArray) {
    return intArray.map((z) => z.toString()).join(",");
  }

  String oldZoneDefault(String sport) {
    return intArrayToString(oldZoneDefaultInts);
  }

  String zonesDefault(String sport) {
    return intArrayToString(zonesDefaultInts[SportSpec.sport2Sport(sport)]!);
  }

  String thresholdTag(String sport) {
    return "${SportSpec.sport2Sport(sport)}_$thresholdTagPostfix";
  }

  String zonesTag(String sport) {
    return "${SportSpec.sport2Sport(sport)}_$zonesTagPostfix";
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
    coloringByZone = prefService.get<bool>(coloringByZoneTag) ?? coloringByZoneDefault;
  }

  void calculateBounds(double minVal, double maxVal, bool isLight, PaletteSpec paletteSpec) {
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
        color: paletteSpec.bgColorByBin(i, isLight, this),
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

  static List<MetricSpec> get preferencesSpecs => _preferencesSpecsTemplate;

  static List<MetricSpec> getPreferencesSpecs(bool si, String sport) {
    var prefSpecs = [...preferencesSpecs];
    prefSpecs[1].updateUnit(getSpeedUnit(si, sport));
    prefSpecs[1].title = speedTitle(sport);
    prefSpecs[2].icon = getSportIcon(sport);
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
