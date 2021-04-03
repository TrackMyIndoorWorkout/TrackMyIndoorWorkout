import 'dart:io';
import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import '../tcx/activity_type.dart';
import '../utils/display.dart';

Color getTranslucent(Color c) {
  return Color(r: c.r, g: c.g, b: c.b, a: 120, darker: c.darker, lighter: c.lighter);
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
  static const THRESHOLD_CAPITAL = 'Threshold ';
  static const ZONES_CAPITAL = ' Zones (list of % of threshold)';
  static const THRESHOLD_PREFIX = 'threshold_';
  static const ZONES_POSTFIX = '_zones';
  static const METRICS = ['power', 'speed', 'cadence', 'hr'];

  static final _preferencesSpecsTemplate = [
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

  final String metric;
  String title;
  String unit;
  String multiLineUnit;
  final String thresholdTag;
  final String thresholdDefault;
  final String zonesTag;
  final String zonesDefault;
  double threshold;
  List<int> zonePercents;
  List<double> zoneBounds;
  List<double> zoneLower;
  List<double> zoneUpper;
  IconData icon;
  String sport;

  PreferencesSpec({
    @required this.metric,
    @required this.title,
    @required this.unit,
    @required this.thresholdTag,
    @required this.thresholdDefault,
    @required this.zonesTag,
    @required this.zonesDefault,
    @required this.icon,
  })  : assert(metric != null),
        assert(title != null),
        assert(unit != null),
        assert(thresholdTag != null),
        assert(thresholdDefault != null),
        assert(zonesTag != null),
        assert(zonesDefault != null),
        assert(icon != null) {
    updateMultiLineUnit();
  }

  String get fullTitle => '$title ($unit)';
  String get histogramTitle => '$title zones (%)';

  void updateMultiLineUnit() {
    multiLineUnit = unit.replaceAll(" ", "\n");
  }

  void updateUnit(String newUnit) {
    unit = newUnit;
    updateMultiLineUnit();
  }

  void calculateZones(String sport) {
    this.sport = sport;
    final thresholdString = PrefService.getString(thresholdTag);
    threshold = double.tryParse(thresholdString);
    final zonesSpecStr = PrefService.getString(zonesTag);
    zonePercents = zonesSpecStr.split(',').map((zs) => int.tryParse(zs)).toList(growable: false);
    zoneBounds = zonePercents.map((z) => decimalRound(z / 100.0 * threshold)).toList();
  }

  void calculateBounds(double minVal, double maxVal) {
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

  bool get flipZones => sport != ActivityType.Ride && metric == "speed";

  int transformedBinIndex(int bin) {
    bin = min(max(0, bin), zonePercents.length - 1);
    return flipZones ? zonePercents.length - 1 - bin : bin;
  }

  int binIndex(num value) {
    int i = 0;
    for (; i < zoneBounds.length; i++) {
      if (value < zoneBounds[i]) {
        return transformedBinIndex(i);
      }
    }
    return transformedBinIndex(i);
  }

  Color bgColorByBin(int bin) {
    if (bin > 6) {
      return getTranslucent(MaterialPalette.blue.shadeDefault.lighter);
    }
    if (zonePercents.length <= 5) {
      return fiveBgPalette[transformedBinIndex(bin)];
    }
    return sevenBgPalette[transformedBinIndex(bin)];
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

  static List<PreferencesSpec> get preferencesSpecs => _preferencesSpecsTemplate;

  static List<PreferencesSpec> getPreferencesSpecs(bool si, String sport) {
    var prefSpecs = [...preferencesSpecs];
    prefSpecs[1].updateUnit(getSpeedUnit(si, sport));
    prefSpecs[1].title = speedTitle(sport);
    prefSpecs[2].icon = getIcon(sport);
    prefSpecs[2].unit = getCadenceUnit(sport);
    prefSpecs.forEach((prefSpec) => prefSpec.calculateZones(sport));
    return prefSpecs;
  }
}

const UX_PREFERENCES = "UI / UX Preferences";

const UNIT_SYSTEM = "Unit System";
const UNIT_SYSTEM_TAG = "unit_system";
const UNIT_SYSTEM_DEFAULT = false;
const UNIT_SYSTEM_DESCRIPTION =
    "On: metric (km/h speed, meters distance), " + "Off: imperial (mp/h speed, miles distance).";

const INSTANT_SCAN = "Instant Scanning";
const INSTANT_SCAN_TAG = "instant_scan";
const INSTANT_SCAN_DEFAULT = true;
const INSTANT_SCAN_DESCRIPTION = "On: the app will automatically start "
    "scanning for equipment after application start.";

const SCAN_DURATION = "Scan Duration";
const SCAN_DURATION_TAG = "scan_duration";
const SCAN_DURATION_DEFAULT = 3;
const SCAN_DURATION_DESCRIPTION =
    "Duration in seconds the app will spend " + "looking Bluetooth Low Energy exercise equipment.";

const AUTO_CONNECT = "Auto Connect";
const AUTO_CONNECT_TAG = "auto_connect";
const AUTO_CONNECT_DEFAULT = false;
const AUTO_CONNECT_DESCRIPTION = "On: if there's only a single " +
    "equipment after scan, or one of the devices match the " +
    "last exercise machine the app will automatically move to the " +
    "measurement screen to start recording.";

const LAST_EQUIPMENT_ID = "Last Equipment ID";
const LAST_EQUIPMENT_ID_TAG = "last_equipment";
const LAST_EQUIPMENT_ID_DEFAULT = "";
const LAST_EQUIPMENT_ID_DESCRIPTION =
    "The last exercise equipment ID " + "the app recorded a workout for";

const INSTANT_MEASUREMENT_START = "Instant Measurement Start";
const INSTANT_MEASUREMENT_START_TAG = "instant_measurement_start";
const INSTANT_MEASUREMENT_START_DEFAULT = true;
const INSTANT_MEASUREMENT_START_DESCRIPTION = "On: when navigating to the measurement screen the " +
    "workout recording will start immediately. Off: the workout has to be started manually by " +
    "pressing the play button.";

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

const MULTI_SPORT_DEVICE_SUPPORT = "Multi-Sport Device Support";
const MULTI_SPORT_DEVICE_SUPPORT_TAG = "multi_sport_device_support";
const MULTI_SPORT_DEVICE_SUPPORT_DEFAULT = false;
const MULTI_SPORT_DEVICE_SUPPORT_DESCRIPTION =
    "Turn this on only if you use a device (like Genesis Port) with multiple equipment of " +
        "different sport (like Kayaking, Canoeing, Rowing, and Swimming). In that case you'll " +
        "be prompted to select a sport before every workout.";

const TUNING_PREFERENCES = "Tuning";

const MEASUREMENT_PANELS_EXPANDED_TAG = "measurement_panels_expanded";
const MEASUREMENT_PANELS_EXPANDED_DEFAULT = "00001";

const MEASUREMENT_DETAIL_SIZE_TAG = "measurement_detail_size";
const MEASUREMENT_DETAIL_SIZE_DEFAULT = "00000";

const APP_DEBUG_MODE = "Application Debug Mode";
const APP_DEBUG_MODE_TAG = "app_debug_mode";
const APP_DEBUG_MODE_DEFAULT = false;
const APP_DEBUG_MODE_DESCRIPTION =
    "On: The Recording UI runs on simulated data, no equipment required. " +
        "Off: The recording works as it should in release.";

const THROTTLE_POWER = "Throttle Power";
const THROTTLE_POWER_TAG = "throttle_power";
const THROTTLE_POWER_DEFAULT = "0";
const THROTTLE_POWER_DESCRIPTION = "Throttle in percent. Example: 11 means that the app " +
    "will take only 89% of the reported power reading. " +
    "Possibly could throttle calories with certain bikes.";

const THROTTLE_OTHER = "Throttle Other";
const THROTTLE_OTHER_TAG = "throttle_other";
const THROTTLE_OTHER_DEFAULT = false;
const THROTTLE_OTHER_DESCRIPTION =
    "Apply the power throttle to other measurements as well " + "(speed, distance, calories)";

const COMPRESS_DOWNLOAD = "File download compression";
const COMPRESS_DOWNLOAD_TAG = "compress_download";
const COMPRESS_DOWNLOAD_DEFAULT = true;
const COMPRESS_DOWNLOAD_DESCRIPTION = "On: the downloaded file is gzip compressed (TCX.gz). " +
    "Off: the downloaded file is TCX (no compression)";

const STROKE_RATE_SMOOTHING = "Stroke Rate Smoothing";
const STROKE_RATE_SMOOTHING_TAG = "stroke_rate_smoothing";
const STROKE_RATE_SMOOTHING_DEFAULT = "10";
const STROKE_RATE_SMOOTHING_DEFAULT_INT = 10;
const STROKE_RATE_SMOOTHING_DESCRIPTION = "Ergometers may provide too jittery data. Averaging " +
    "these over time soothes the data. This setting tells the window size by how many samples " +
    "could be in the smoothing queue. 1 means no smoothing.";

const EQUIPMENT_DISCONNECTION_WATCHDOG = "Equipment Disconnection Watchdog Timer";
const EQUIPMENT_DISCONNECTION_WATCHDOG_TAG = "equipment_disconnection_watchdog_timer";
const EQUIPMENT_DISCONNECTION_WATCHDOG_DEFAULT = "5";
const EQUIPMENT_DISCONNECTION_WATCHDOG_DEFAULT_INT = 5;
const EQUIPMENT_DISCONNECTION_WATCHDOG_DESCRIPTION = "How many seconds of data gap considered " +
    "as a disconnection. A watchdog would finish the workout, reconnect to the equipment, and " +
    "start a new workout. 0 means the watchdog will be turned off. Disabling the watchdog " +
    "if your fitness equipment stops sending data when the workout is paused to avoid unwanted " +
    "restarts.";

const CALORIE_CARRYOVER_WORKAROUND = "Calorie Carryover Workaround";
const CALORIE_CARRYOVER_WORKAROUND_TAG = "calorie_carryover_workaround";
const CALORIE_CARRYOVER_WORKAROUND_DEFAULT = false;
const CALORIE_CARRYOVER_WORKAROUND_DESCRIPTION = "On: Calorie count could be preserved if the " +
    "workout is restarted accidentally or automatically. " +
    "(Note that data points will be still missing.) " +
    "Off: Calorie count will start from zero after workout restart.";

const ZONE_PREFERENCES = "Zone Preferences";

const FONT_FAMILY = "RobotoMono";

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
