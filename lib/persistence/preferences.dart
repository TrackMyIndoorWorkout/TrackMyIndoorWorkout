import 'dart:io';
import 'dart:math';

import 'package:charts_common/common.dart' as common;
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
  static const THRESHOLD_CAPITAL = ' Threshold ';
  static const ZONES_CAPITAL = ' Zones (list of % of threshold)';
  static const PADDLE_SPORT = "Paddle";
  static const SPORT_PREFIXES = [
    ActivityType.Ride,
    ActivityType.Run,
    PADDLE_SPORT,
    ActivityType.Swim
  ];
  static const THRESHOLD_PREFIX = 'threshold_';
  static const ZONES_POSTFIX = '_zones';
  static const METRICS = ['power', 'speed', 'cadence', 'hr'];

  static final slowSpeeds = {
    ActivityType.Ride: 5.0,
    ActivityType.Run: 3.0,
    PADDLE_SPORT: 2.0,
    ActivityType.Swim: 1.0,
  };

  static final _preferencesSpecsTemplate = [
    PreferencesSpec(
      metric: METRICS[0],
      title: 'Power',
      unit: 'W',
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
    ),
    PreferencesSpec(
      metric: METRICS[1],
      title: 'Speed',
      unit: 'mph',
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
    ),
    PreferencesSpec(
      metric: METRICS[2],
      title: 'Cadence',
      unit: 'rpm',
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
    ),
    PreferencesSpec(
      metric: METRICS[3],
      title: 'Heart Rate',
      unit: 'bpm',
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
    ),
  ].toList(growable: false);

  final String metric;
  String title;
  String unit;
  String multiLineUnit;
  final String thresholdTagPostfix;
  final Map<String, int> thresholdDefaultInts;
  final String zonesTagPostfix;
  final Map<String, List<int>> zonesDefaultInts;
  double threshold;
  List<int> zonePercents;
  List<double> zoneBounds;
  List<double> zoneLower;
  List<double> zoneUpper;
  IconData icon;
  bool si;
  String sport;
  bool flipZones;

  List<common.AnnotationSegment> annotationSegments;

  PreferencesSpec({
    @required this.metric,
    @required this.title,
    @required this.unit,
    @required this.thresholdTagPostfix,
    @required this.thresholdDefaultInts,
    @required this.zonesTagPostfix,
    @required this.zonesDefaultInts,
    @required this.icon,
  })  : assert(metric != null),
        assert(title != null),
        assert(unit != null),
        assert(thresholdTagPostfix != null),
        assert(thresholdDefaultInts != null),
        assert(zonesTagPostfix != null),
        assert(zonesDefaultInts != null),
        assert(icon != null) {
    flipZones = false;
    updateMultiLineUnit();
    annotationSegments = [];
  }

  String get fullTitle => '$title ($unit)';
  String get kmhTitle => '$title (kmh)';
  String get histogramTitle => '$title zones (%)';

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
    return zonesDefaultInts[sport2Sport(sport)].map((z) => z.toString()).join(",");
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
    flipZones = sport != ActivityType.Ride && metric == "speed";
    final thresholdString = PrefService.getString(thresholdTag(sport));
    threshold = double.tryParse(thresholdString);
    if (metric == "speed") {
      threshold = speedOrPace(threshold, si, sport);
    }

    final zonesSpecStr = PrefService.getString(zonesTag(sport));
    zonePercents = zonesSpecStr.split(',').map((zs) => int.tryParse(zs)).toList(growable: false);
    zoneBounds =
        zonePercents.map((z) => decimalRound(z / 100.0 * threshold)).toList(growable: false);
    if (flipZones) {
      zoneBounds = zoneBounds.reversed.toList(growable: false);
    }
  }

  void calculateBounds(double minVal, double maxVal) {
    zoneLower = [...zoneBounds];
    zoneUpper = [...zoneBounds];

    final zoneMin = flipZones ? zoneUpper.last : zoneLower[0];
    if (minVal < 0 || minVal > 0 && minVal > zoneMin) {
      minVal = zoneMin * 0.7;
    }

    final zoneMax = flipZones ? zoneLower[0] : zoneUpper.last;
    if (maxVal < 0 || maxVal > 0 && maxVal < zoneMax) {
      maxVal = zoneMax * 1.2;
    }

    if (flipZones) {
      zoneLower.insert(0, decimalRound(maxVal));
      zoneUpper.add(decimalRound(minVal));
    } else {
      zoneLower.insert(0, decimalRound(minVal));
      zoneUpper.add(decimalRound(maxVal));
    }

    List<common.AnnotationSegment> segments = [];
    segments.addAll(List.generate(
      binCount,
      (i) => RangeAnnotationSegment(
        zoneLower[i],
        zoneUpper[i],
        RangeAnnotationAxisType.measure,
        color: bgColorByBin(i),
        startLabel: zoneLower[i].toString(),
        labelAnchor: AnnotationLabelAnchor.start,
      ),
    ));
    segments.addAll(List.generate(
      binCount,
      (i) => LineAnnotationSegment(
        zoneUpper[i],
        RangeAnnotationAxisType.measure,
        startLabel: zoneUpper[i].toString(),
        labelAnchor: AnnotationLabelAnchor.end,
        strokeWidthPx: 1.0,
        color: MaterialPalette.black,
      ),
    ));
    annotationSegments = segments.toList(growable: false);
  }

  int get binCount => zonePercents.length + 1;

  int transformedBinIndex(int bin) {
    bin = min(max(0, bin), zonePercents.length - 1);
    return flipZones ? zonePercents.length - 1 - bin : bin;
  }

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
      return fiveFgPalette[transformedBinIndex(bin)];
    }
    return sevenFgPalette[transformedBinIndex(bin)];
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
    prefSpecs.forEach((prefSpec) => prefSpec.calculateZones(si, sport));
    return prefSpecs;
  }
}

const PREFERENCES_VERSION_TAG = "version";
const PREFERENCES_VERSION_DEFAULT = 1;
const PREFERENCES_VERSION_SPORT_THRESHOLDS = 1;
const PREFERENCES_VERSION_EQUIPMENT_REMEMBRANCE_PER_SPORT = 2;
const PREFERENCES_VERSION_NEXT = PREFERENCES_VERSION_DEFAULT + 1;

const UX_PREFERENCES = "UI / UX Preferences";

const UNIT_SYSTEM = "Unit System";
const UNIT_SYSTEM_TAG = "unit_system";
const UNIT_SYSTEM_DEFAULT = false;
const UNIT_SYSTEM_DESCRIPTION =
    "On: metric (km/h speed, meters distance), Off: imperial (mp/h speed, miles distance).";

const INSTANT_SCAN = "Instant Scanning";
const INSTANT_SCAN_TAG = "instant_scan";
const INSTANT_SCAN_DEFAULT = true;
const INSTANT_SCAN_DESCRIPTION = "On: the app will automatically start "
    "scanning for equipment after application start.";

const SCAN_DURATION = "Scan Duration";
const SCAN_DURATION_TAG = "scan_duration";
const SCAN_DURATION_DEFAULT = 3;
const SCAN_DURATION_DESCRIPTION =
    "Duration in seconds the app will spend looking Bluetooth Low Energy exercise equipment.";

const AUTO_CONNECT = "Auto Connect";
const AUTO_CONNECT_TAG = "auto_connect";
const AUTO_CONNECT_DEFAULT = false;
const AUTO_CONNECT_DESCRIPTION = "On: if there's only a single " +
    "equipment after scan, or one of the devices match the " +
    "last exercise machine the app will automatically move to the " +
    "measurement screen to start recording.";

const LAST_EQUIPMENT_ID_TAG = "last_equipment";
const LAST_EQUIPMENT_ID_TAG_PREFIX = LAST_EQUIPMENT_ID_TAG + "_";
const LAST_EQUIPMENT_ID_DEFAULT = "";

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
const WORKAROUND_PREFERENCES = "Workarounds";

const MEASUREMENT_PANELS_EXPANDED_TAG = "measurement_panels_expanded";
const MEASUREMENT_PANELS_EXPANDED_DEFAULT = "00001";

const MEASUREMENT_DETAIL_SIZE_TAG = "measurement_detail_size";
const MEASUREMENT_DETAIL_SIZE_DEFAULT = "00000";

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
    "Apply the power throttle to other measurements as well (speed, distance, calories)";

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

const CADENCE_GAP_WORKAROUND = "Cadence Data Gap Workaround";
const CADENCE_GAP_WORKAROUND_TAG = "cadence_data_gap_workaround";
const CADENCE_GAP_WORKAROUND_DEFAULT = true;
const CADENCE_GAP_WORKAROUND_DESCRIPTION = "On: When speed / pace is non zero but the " +
    "cadence / stroke rate is zero the application will substitute the zero with the last " +
    "positive cadence reading. " +
    "Off: Zero cadence will be recorded without modification.";

const EXPERT_PREFERENCES = "Expert Preferences";

const APP_DEBUG_MODE = "Application Debug Mode";
const APP_DEBUG_MODE_TAG = "app_debug_mode";
const APP_DEBUG_MODE_DEFAULT = false;
const APP_DEBUG_MODE_DESCRIPTION =
    "On: The Recording UI runs on simulated data, no equipment required. " +
        "Off: The recording works as it should in release.";

const DATA_CONNECTION_ADDRESSES = "Data Connection Addresses";
const DATA_CONNECTION_ADDRESSES_TAG = "data_connection_addresses";
const DATA_CONNECTION_ADDRESSES_DEFAULT =
    "52.44.84.95,54.160.234.139,52.87.57.116,3.93.102.29," + "54.157.131.119,3.226.9.14";

const DATA_CONNECTION_ADDRESSES_DESCRIPTION =
    "Following is a comma separated list of IP addresses with optional comma separated port " +
        "numbers. Lack of a port number will mean 443 (HTTPS). " +
        "The application will reach out to these endpoints to determine if there " +
        "is really a data connection.";

const ZONE_PREFERENCES = " Zone Preferences";

const SLOW_SPEED_POSTFIX = " Speed (kmh) Considered Too Slow to Display";
const SLOW_SPEED_TAG_PREFIX = "slow_speed_";

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
