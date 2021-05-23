import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:charts_common/common.dart' as common;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:expandable/expandable.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:wakelock/wakelock.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/gadgets/fitness_equipment.dart';
import '../devices/gadgets/heart_rate_monitor.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/workout_summary.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../strava/error_codes.dart';
import '../strava/strava_service.dart';
import '../track/calculator.dart';
import '../track/constants.dart';
import '../track/track_painter.dart';
import '../track/tracks.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';
import '../utils/sound.dart';
import '../utils/target_heart_rate.dart';
import '../utils/theme_manager.dart';
import 'models/display_record.dart';
import 'models/row_configuration.dart';
import 'parts/battery_status.dart';
import 'parts/heart_rate_monitor_pairing.dart';
import 'parts/spin_down.dart';
import 'activities.dart';

typedef DataFn = List<charts.Series<DisplayRecord, DateTime>> Function();

enum TargetHrState {
  Off,
  Under,
  InRange,
  Over,
}

class RecordingScreen extends StatefulWidget {
  final BluetoothDevice device;
  final DeviceDescriptor descriptor;
  final BluetoothDeviceState initialState;
  final Size size;
  final String sport;

  RecordingScreen({
    Key key,
    @required this.device,
    @required this.descriptor,
    @required this.initialState,
    @required this.size,
    @required this.sport,
  })  : assert(device != null),
        assert(descriptor != null),
        assert(initialState != null),
        assert(size != null),
        assert(sport != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RecordingState(
      device: device,
      descriptor: descriptor,
      initialState: initialState,
      size: size,
      sport: sport,
    );
  }
}

class RecordingState extends State<RecordingScreen> {
  RecordingState({
    @required this.device,
    @required this.descriptor,
    @required this.initialState,
    @required this.size,
    @required this.sport,
  })  : assert(device != null),
        assert(descriptor != null),
        assert(initialState != null),
        assert(size != null),
        assert(sport != null);

  Size size;
  final BluetoothDevice device;
  final DeviceDescriptor descriptor;
  final BluetoothDeviceState initialState;
  final String sport;
  FitnessEquipment _fitnessEquipment;
  HeartRateMonitor _heartRateMonitor;
  TrackCalculator _trackCalculator;
  bool _measuring;
  int _pointCount;
  ListQueue<DisplayRecord> _graphData;
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _measurementStyle;
  TextStyle _unitStyle;
  charts.TextStyleSpec _chartTextStyle;
  ExpandableThemeData _expandableThemeData;
  List<bool> _expandedState;
  List<ExpandableController> _rowControllers;
  List<int> _expandedHeights;
  List<PreferencesSpec> _preferencesSpecs;

  Activity _activity;
  AppDatabase _database;
  bool _si;
  bool _simplerUi;
  bool _instantUpload;
  bool _uxDebug;

  Timer _dataGapWatchdog;
  int _dataGapWatchdogTime = DATA_STREAM_GAP_WATCHDOG_DEFAULT_INT;
  bool _dataGapAutoStop;
  String _dataGapSoundEffect;
  Timer _dataGapBeeperTimer;

  List<DisplayRecord> get graphData => _graphData.toList();
  Map<String, DataFn> _metricToDataFn = {};
  List<RowConfiguration> _rowConfig;
  List<String> _values;
  double _distance;
  int _elapsed;

  String _targetHrMode;
  Tuple2<double, double> _targetHrBounds;
  int _heartRate;
  Timer _hrBeepPeriodTimer;
  int _hrBeepPeriod = TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT_INT;
  bool _targetHrAudio;
  bool _targetHrAlerting;
  bool _leaderboardFeature;
  bool _rankingForDevice;
  List<WorkoutSummary> _deviceLeaderboard;
  int _deviceRank;
  bool _rankingForSport;
  List<WorkoutSummary> _sportLeaderboard;
  int _sportRank;
  bool _rankRibbonVisualization;
  bool _rankTrackVisualization;
  Color _darkRed;
  Color _darkGreen;
  Color _darkBlue;
  Color _lightRed;
  Color _lightGreen;
  Color _lightBlue;
  ThemeManager _themeManager;
  bool _isLight;

  Future<void> _connectOnDemand(BluetoothDeviceState deviceState) async {
    bool success = await _fitnessEquipment.connectOnDemand(deviceState);
    if (success) {
      if (PrefService.getBool(INSTANT_MEASUREMENT_START_TAG)) {
        await _startMeasurement();
      }
    } else {
      Get.defaultDialog(
        middleText: 'Problem co-operating with ${descriptor.fullName}. Aborting...',
        confirm: TextButton(
          child: Text("Ok"),
          onPressed: () => Get.close(1),
        ),
      );
    }
  }

  Future<void> _startMeasurement() async {
    final now = DateTime.now();
    final powerFactor = await _database.powerFactor(device.id.id) ?? 1.0;
    final calorieFactor = await _database.calorieFactor(device.id.id, descriptor) ?? 1.0;
    _activity = Activity(
      fourCC: descriptor.fourCC,
      deviceName: device.name,
      deviceId: device.id.id,
      start: now.millisecondsSinceEpoch,
      startDateTime: now,
      sport: descriptor.defaultSport,
      powerFactor: powerFactor,
      calorieFactor: calorieFactor,
    );
    if (!_uxDebug) {
      final id = await _database?.activityDao?.insertActivity(_activity);
      _activity.id = id;
    }

    if (_rankingForDevice) {
      _deviceLeaderboard = await _database.workoutSummaryDao
          .findWorkoutSummaryByDevice(device.id.id, LEADERBOARD_LIMIT, 0);
    }
    if (_rankingForSport) {
      _sportLeaderboard = await _database.workoutSummaryDao
          .findWorkoutSummaryBySport(descriptor.defaultSport, LEADERBOARD_LIMIT, 0);
    }

    _fitnessEquipment.setActivity(_activity);

    await _fitnessEquipment.attach();
    setState(() {
      _elapsed = 0;
      _distance = 0.0;
      _measuring = true;
    });
    _fitnessEquipment.measuring = true;
    _fitnessEquipment.startWorkout();

    _fitnessEquipment.pumpData((record) async {
      _dataGapWatchdog?.cancel();
      _dataGapBeeperTimer?.cancel();
      if (_dataGapWatchdogTime > 0) {
        _dataGapWatchdog = Timer(
          Duration(seconds: _dataGapWatchdogTime),
          _dataGapTimeoutHandler,
        );
      }

      if (_measuring) {
        if (!_uxDebug) {
          await _database?.recordDao?.insertRecord(record);
        }

        _fitnessEquipment.lastRecord = record;

        setState(() {
          if (!_simplerUi) {
            _graphData.add(record.display());
            if (_pointCount > 0 && _graphData.length > _pointCount) {
              _graphData.removeFirst();
            }
          }

          _distance = record.distance;
          _elapsed = record.elapsed;
          if (record.heartRate != null &&
              (record.heartRate > 0 || _heartRate == null || _heartRate == 0)) {
            _heartRate = record.heartRate;
          }

          _deviceRank = _getDeviceRank();
          _sportRank = _getSportRank();

          _values = [
            record.calories.toString(),
            record.power.toString(),
            record.speedStringByUnit(_si, descriptor.defaultSport),
            record.cadence.toString(),
            record.heartRate.toString(),
            record.distanceStringByUnit(_si),
          ];
          if (_preferencesSpecs[0].indexDisplay) {
            int zoneIndex = _preferencesSpecs[0].binIndex(record.power);
            _values[1] += " Z$zoneIndex";
          }
          if (_preferencesSpecs[2].indexDisplay) {
            int zoneIndex = _preferencesSpecs[2].binIndex(record.cadence);
            _values[3] += " Z$zoneIndex";
          }
          if (_preferencesSpecs[3].indexDisplay) {
            int zoneIndex = _preferencesSpecs[3].binIndex(record.heartRate);
            _values[4] += " Z$zoneIndex";
          }
        });
      }
    });
  }

  void _onToggleDetails(int index) {
    setState(() {
      _expandedState[index] = _rowControllers[index].expanded;
      final expandedStateStr =
          List<String>.generate(_expandedState.length, (index) => _expandedState[index] ? "1" : "0")
              .join("");
      PrefService.setString(MEASUREMENT_PANELS_EXPANDED_TAG, expandedStateStr);
    });
  }

  void _onTogglePower() {
    _onToggleDetails(0);
  }

  void _onToggleSpeed() {
    _onToggleDetails(1);
  }

  void _onToggleRpm() {
    _onToggleDetails(2);
  }

  void _onToggleHr() {
    _onToggleDetails(3);
  }

  void _onToggleDistance() {
    _onToggleDetails(4);
  }

  void _onLongPress(int index) {
    setState(() {
      _expandedHeights[index] = (_expandedHeights[index] + 1) % 3;
      final expandedHeightStr = List<String>.generate(
          _expandedHeights.length, (index) => _expandedHeights[index].toString()).join("");
      PrefService.setString(MEASUREMENT_DETAIL_SIZE_TAG, expandedHeightStr);
    });
  }

  Future<void> _initializeHeartRateMonitor() async {
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    final discovered = (await _heartRateMonitor?.discover()) ?? false;
    if (discovered) {
      if (_heartRateMonitor.device.id.id !=
          (_fitnessEquipment.heartRateMonitor?.device?.id?.id ?? NOT_AVAILABLE)) {
        _fitnessEquipment.setHeartRateMonitor(_heartRateMonitor);
      }
      _heartRateMonitor.attach().then((_) async {
        if (_heartRateMonitor.subscription != null) {
          await _heartRateMonitor.cancelSubscription();
        }
        _heartRateMonitor.pumpMetric((heartRate) async {
          setState(() {
            if (heartRate != null && (heartRate > 0 || _heartRate == null || _heartRate == 0)) {
              _heartRate = heartRate;
            }
            _values[4] = heartRate?.toString() ?? "--";
          });
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Wakelock.enable();
    SystemChrome.setEnabledSystemUIOverlays([]);

    _themeManager = Get.find<ThemeManager>();
    _isLight = !_themeManager.isDark();
    _pointCount = min(60, size.width ~/ 2);
    _unitStyle = TextStyle(
      fontFamily: FONT_FAMILY,
      color: _themeManager.getBlueColor(),
    );
    PrefService.setString(
      LAST_EQUIPMENT_ID_TAG_PREFIX + PreferencesSpec.sport2Sport(sport),
      device.id.id,
    );
    descriptor.refreshTuning(device.id.id);
    if (Get.isRegistered<FitnessEquipment>()) {
      _fitnessEquipment = Get.find<FitnessEquipment>();
      _fitnessEquipment.descriptor = descriptor;
    } else {
      _fitnessEquipment =
          Get.put<FitnessEquipment>(FitnessEquipment(descriptor: descriptor, device: device));
    }

    _trackCalculator = TrackCalculator(
      track: TrackDescriptor(
        radiusBoost: TRACK_PAINTING_RADIUS_BOOST,
        lengthFactor: descriptor.lengthFactor,
      ),
    );
    _si = PrefService.getBool(UNIT_SYSTEM_TAG);
    _simplerUi = PrefService.getBool(SIMPLER_UI_TAG);
    _instantUpload = PrefService.getBool(INSTANT_UPLOAD_TAG);
    if (!_simplerUi) {
      _graphData = ListQueue<DisplayRecord>(_pointCount);
    }

    if (sport != ActivityType.Ride) {
      final slowPace = PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(sport)];
      descriptor.slowPace = slowPace;
      _fitnessEquipment.slowPace = slowPace;
    }

    _preferencesSpecs = PreferencesSpec.getPreferencesSpecs(_si, descriptor.defaultSport);
    _preferencesSpecs.forEach((prefSpec) => prefSpec.calculateBounds(
          0,
          decimalRound(prefSpec.threshold * (prefSpec.zonePercents.last + 15) / 100.0),
          _isLight,
        ));

    _dataGapWatchdogTime = getStringIntegerPreference(
      DATA_STREAM_GAP_WATCHDOG_TAG,
      DATA_STREAM_GAP_WATCHDOG_DEFAULT,
      DATA_STREAM_GAP_WATCHDOG_DEFAULT_INT,
    );
    _dataGapAutoStop = PrefService.getBool(DATA_STREAM_GAP_ACTIVITY_AUTO_STOP_TAG) ??
        DATA_STREAM_GAP_ACTIVITY_AUTO_STOP_DEFAULT;
    _dataGapSoundEffect = PrefService.getString(DATA_STREAM_GAP_SOUND_EFFECT_TAG) ??
        DATA_STREAM_GAP_SOUND_EFFECT_DEFAULT;

    _targetHrMode =
        PrefService.getString(TARGET_HEART_RATE_MODE_TAG) ?? TARGET_HEART_RATE_MODE_DEFAULT;
    _targetHrBounds = getTargetHeartRateBounds(_targetHrMode, _preferencesSpecs[3]);
    _targetHrAlerting = false;
    _targetHrAudio =
        PrefService.getBool(TARGET_HEART_RATE_AUDIO_TAG) ?? TARGET_HEART_RATE_AUDIO_DEFAULT;
    if (_targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio) {
      _hrBeepPeriod = getStringIntegerPreference(
        TARGET_HEART_RATE_AUDIO_PERIOD_TAG,
        TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT,
        TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT_INT,
      );
    }

    if (_targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio ||
        _dataGapSoundEffect != SOUND_EFFECT_NONE) {
      if (!Get.isRegistered<SoundService>()) {
        Get.put<SoundService>(SoundService());
      }
    }

    _metricToDataFn = {
      "power": _powerChartData,
      "speed": _speedChartData,
      "cadence": _cadenceChartData,
      "hr": _hRChartData,
    };

    _chartTextStyle = charts.TextStyleSpec(
      color: _isLight ? charts.MaterialPalette.black : charts.MaterialPalette.white,
    );
    _expandableThemeData = ExpandableThemeData(
      hasIcon: !_simplerUi,
      iconColor: _themeManager.getProtagonistColor(),
    );
    _rowConfig = [
      RowConfiguration(
        icon: Icons.whatshot,
        unit: 'cal',
        expandable: false,
      ),
      RowConfiguration(
        icon: _preferencesSpecs[0].icon,
        unit: _preferencesSpecs[0].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        icon: _preferencesSpecs[1].icon,
        unit: _preferencesSpecs[1].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        icon: _preferencesSpecs[2].icon,
        unit: _preferencesSpecs[2].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        icon: _preferencesSpecs[3].icon,
        unit: _preferencesSpecs[3].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        icon: Icons.add_road,
        unit: _si ? 'm' : 'mi',
        expandable: !_simplerUi,
      ),
    ];
    _rowControllers = [];
    _expandedHeights = [];
    final expandedStateStr = PrefService.getString(MEASUREMENT_PANELS_EXPANDED_TAG);
    final expandedHeightStr = PrefService.getString(MEASUREMENT_DETAIL_SIZE_TAG);
    _expandedState = List<bool>.generate(expandedStateStr.length, (int index) {
      final expanded = expandedStateStr[index] == "1";
      ExpandableController rowController = ExpandableController(initialExpanded: expanded);
      _rowControllers.add(rowController);
      switch (index) {
        case 0:
          rowController.addListener(_onTogglePower);
          break;
        case 1:
          rowController.addListener(_onToggleSpeed);
          break;
        case 2:
          rowController.addListener(_onToggleRpm);
          break;
        case 3:
          rowController.addListener(_onToggleHr);
          break;
        case 4:
        default:
          rowController.addListener(_onToggleDistance);
          break;
      }

      final expandedHeight = int.tryParse(expandedHeightStr[index]);
      _expandedHeights.add(expandedHeight);
      return expanded;
    });

    _uxDebug = PrefService.getBool(APP_DEBUG_MODE_TAG) ?? APP_DEBUG_MODE_DEFAULT;
    _measuring = false;
    _fitnessEquipment.measuring = false;
    _values = ["--", "--", "--", "--", "--", "--"];
    _distance = 0.0;
    _elapsed = 0;

    _leaderboardFeature =
        PrefService.getBool(LEADERBOARD_FEATURE_TAG) ?? LEADERBOARD_FEATURE_DEFAULT;
    _rankRibbonVisualization =
        PrefService.getBool(RANK_RIBBON_VISUALIZATION_TAG) ?? RANK_RIBBON_VISUALIZATION_DEFAULT;
    _rankingForDevice = PrefService.getBool(RANKING_FOR_DEVICE_TAG) ?? RANKING_FOR_DEVICE_DEFAULT;
    _deviceRank = MAX_UINT8;
    _deviceLeaderboard = [];
    _rankingForSport = PrefService.getBool(RANKING_FOR_SPORT_TAG) ?? RANKING_FOR_SPORT_DEFAULT;
    _sportLeaderboard = [];
    _sportRank = MAX_UINT8;
    _rankTrackVisualization =
        PrefService.getBool(RANK_TRACK_VISUALIZATION_TAG) ?? RANK_TRACK_VISUALIZATION_DEFAULT;

    final isLight = !_themeManager.isDark();
    _darkRed = paletteToPaintColor(isLight
        ? common.MaterialPalette.red.shadeDefault.darker
        : common.MaterialPalette.red.shadeDefault.lighter);
    _darkGreen = paletteToPaintColor(isLight
        ? common.MaterialPalette.green.shadeDefault.darker
        : common.MaterialPalette.lime.shadeDefault.lighter);
    _darkBlue = paletteToPaintColor(isLight
        ? common.MaterialPalette.indigo.shadeDefault.darker
        : common.MaterialPalette.blue.shadeDefault.lighter);
    _lightRed = paletteToPaintColor(isLight
        ? common.MaterialPalette.red.shadeDefault.lighter
        : common.MaterialPalette.red.shadeDefault.darker);
    _lightGreen = paletteToPaintColor(isLight
        ? common.MaterialPalette.lime.shadeDefault.lighter
        : common.MaterialPalette.green.shadeDefault.darker);
    _lightBlue = paletteToPaintColor(isLight
        ? common.MaterialPalette.blue.shadeDefault.lighter
        : common.MaterialPalette.indigo.shadeDefault.darker);

    _initializeHeartRateMonitor();
    _connectOnDemand(initialState);
    _database = Get.find<AppDatabase>();
  }

  _preDispose() async {
    _hrBeepPeriodTimer?.cancel();
    _dataGapWatchdog?.cancel();
    _dataGapBeeperTimer?.cancel();
    if (_targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio ||
        _dataGapSoundEffect != SOUND_EFFECT_NONE) {
      await Get.find<SoundService>().stopAllSoundEffects();
    }

    try {
      await _heartRateMonitor?.cancelSubscription();
    } on PlatformException catch (e, stack) {
      debugPrint("HRM device got turned off?");
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }

    try {
      await _fitnessEquipment?.detach();
    } on PlatformException catch (e, stack) {
      debugPrint("Equipment got turned off?");
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }
  }

  @override
  void dispose() {
    Wakelock.disable();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> _dataGapTimeoutHandler() async {
    Get.snackbar("Warning", "Equipment might be disconnected!");

    _hrBeepPeriodTimer?.cancel();
    if (_targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio) {
      Get.find<SoundService>().stopAllSoundEffects();
    }

    if (_dataGapSoundEffect != SOUND_EFFECT_NONE) {
      Get.find<SoundService>().playDataTimeoutSoundEffect();
      if (_dataGapWatchdogTime >= 2) {
        _dataGapBeeperTimer = Timer(Duration(seconds: _dataGapWatchdogTime), _dataTimeoutBeeper);
      }
    }

    if (_dataGapAutoStop) {
      setState(() {
        _measuring = false;
      });
      _fitnessEquipment.measuring = false;
      try {
        await _fitnessEquipment?.detach();
        await _fitnessEquipment?.disconnect();
      } on PlatformException catch (e, stack) {
        debugPrint("Equipment got turned off?");
        debugPrint("$e");
        debugPrintStack(stackTrace: stack, label: "trace:");
      }
    }
  }

  Future<void> _dataTimeoutBeeper() async {
    Get.find<SoundService>().playDataTimeoutSoundEffect();
    if (_measuring && _dataGapSoundEffect != SOUND_EFFECT_NONE && _dataGapWatchdogTime >= 2) {
      _dataGapBeeperTimer = Timer(Duration(seconds: _dataGapWatchdogTime), _dataTimeoutBeeper);
    }
  }

  Future<void> _hrBeeper() async {
    Get.find<SoundService>().playTargetHrSoundEffect();
    if (_measuring &&
        _targetHrMode != TARGET_HEART_RATE_MODE_NONE &&
        _targetHrAudio &&
        _heartRate != null &&
        _heartRate > 0) {
      if (_heartRate < _targetHrBounds.item1 || _heartRate > _targetHrBounds.item2) {
        _hrBeepPeriodTimer = Timer(Duration(seconds: _hrBeepPeriod), _hrBeeper);
      }
    }
  }

  _stravaUpload(bool onlyWhenAuthenticated) async {
    StravaService stravaService;
    if (!Get.isRegistered<StravaService>()) {
      stravaService = Get.put<StravaService>(StravaService());
    } else {
      stravaService = Get.find<StravaService>();
    }

    if (onlyWhenAuthenticated && !await stravaService.hasValidToken()) {
      return;
    }

    if (!await DataConnectionChecker().hasConnection) {
      Get.snackbar("Warning", "No data connection detected");
      return;
    }

    final success = await stravaService.login();
    if (!success) {
      Get.snackbar("Warning", "Strava login unsuccessful");
      return;
    }

    final records = await _database.recordDao.findAllActivityRecords(_activity.id);
    final statusCode = await stravaService.upload(_activity, records);
    Get.snackbar(
        "Upload",
        statusCode == statusOk || statusCode >= 200 && statusCode < 300
            ? "Activity ${_activity.id} submitted successfully"
            : "Activity ${_activity.id} upload failure");
  }

  _stopMeasurement(bool quick) async {
    _fitnessEquipment.measuring = false;
    if (!_measuring) return;

    _hrBeepPeriodTimer?.cancel();
    _dataGapWatchdog?.cancel();
    _dataGapBeeperTimer?.cancel();
    if (_targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio ||
        _dataGapSoundEffect != SOUND_EFFECT_NONE) {
      Get.find<SoundService>().stopAllSoundEffects();
    }

    setState(() {
      _measuring = false;
    });

    _fitnessEquipment.detach();

    _activity.finish(
      _fitnessEquipment.lastRecord?.distance,
      _fitnessEquipment.lastRecord?.elapsed,
      _fitnessEquipment.lastRecord?.calories,
    );
    _fitnessEquipment.stopWorkout();

    if (!_uxDebug) {
      if (_leaderboardFeature) {
        await _database?.workoutSummaryDao
            ?.insertWorkoutSummary(_activity.getWorkoutSummary(_fitnessEquipment.manufacturerName));
      }

      final retVal = await _database?.activityDao?.updateActivity(_activity);
      if (retVal <= 0 && !quick) {
        Get.snackbar("Warning", "Could not save activity");
        return;
      }

      if (_instantUpload && !quick) {
        await _stravaUpload(true);
      }
    }
  }

  List<charts.Series<DisplayRecord, DateTime>> _powerChartData() {
    return <charts.Series<DisplayRecord, DateTime>>[
      charts.Series<DisplayRecord, DateTime>(
        id: 'power',
        colorFn: (DisplayRecord record, __) => _preferencesSpecs[0].fgColorByValue(
          record.power,
          _isLight,
        ),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.power,
        data: graphData,
        insideLabelStyleAccessorFn: (DisplayRecord record, _) => _chartTextStyle,
        outsideLabelStyleAccessorFn: (DisplayRecord record, _) => _chartTextStyle,
      ),
    ];
  }

  List<charts.Series<DisplayRecord, DateTime>> _speedChartData() {
    return <charts.Series<DisplayRecord, DateTime>>[
      charts.Series<DisplayRecord, DateTime>(
        id: 'speed',
        colorFn: (DisplayRecord record, __) => _preferencesSpecs[1].fgColorByValue(
          record.speedByUnit(_si, descriptor.defaultSport),
          _isLight,
        ),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.speedByUnit(_si, descriptor.defaultSport),
        data: graphData,
        insideLabelStyleAccessorFn: (DisplayRecord record, _) => _chartTextStyle,
        outsideLabelStyleAccessorFn: (DisplayRecord record, _) => _chartTextStyle,
      ),
    ];
  }

  List<charts.Series<DisplayRecord, DateTime>> _cadenceChartData() {
    return <charts.Series<DisplayRecord, DateTime>>[
      charts.Series<DisplayRecord, DateTime>(
        id: 'cadence',
        colorFn: (DisplayRecord record, __) => _preferencesSpecs[2].fgColorByValue(
          record.cadence,
          _isLight,
        ),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.cadence,
        data: graphData,
        insideLabelStyleAccessorFn: (DisplayRecord record, _) => _chartTextStyle,
        outsideLabelStyleAccessorFn: (DisplayRecord record, _) => _chartTextStyle,
      ),
    ];
  }

  List<charts.Series<DisplayRecord, DateTime>> _hRChartData() {
    return <charts.Series<DisplayRecord, DateTime>>[
      charts.Series<DisplayRecord, DateTime>(
        id: 'hr',
        colorFn: (DisplayRecord record, __) => _preferencesSpecs[3].fgColorByValue(
          record.heartRate,
          _isLight,
        ),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.heartRate,
        data: graphData,
        insideLabelStyleAccessorFn: (DisplayRecord record, _) => _chartTextStyle,
        outsideLabelStyleAccessorFn: (DisplayRecord record, _) => _chartTextStyle,
      ),
    ];
  }

  Future<bool> _onWillPop() async {
    if (!_measuring) {
      _preDispose();
      return true;
    }

    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('About to navigate away'),
            content: Text("The workout in progress will be finished. Are you sure?"),
            actions: [
              TextButton(
                onPressed: () => Get.close(1),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  await _stopMeasurement(true);
                  await _preDispose();
                  Navigator.of(context).pop(true);
                },
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  int _getRank(List<WorkoutSummary> leaderboard) {
    if (leaderboard.length <= 0) {
      return 1;
    }

    if (_elapsed == null || _elapsed == 0) {
      return MAX_UINT8;
    }

    final averageSpeed = _elapsed > 0 ? _distance / _elapsed * DeviceDescriptor.MS2KMH : 0.0;
    var rank = 1;
    for (final entry in leaderboard) {
      if (averageSpeed > entry.speed) {
        return rank;
      }

      rank += 1;
    }

    return rank;
  }

  String _getRankString(int rank, List<WorkoutSummary> leaderboard) {
    if (rank == null || rank > leaderboard.length) {
      return "${leaderboard.length}+";
    }

    return "$rank";
  }

  int _getDeviceRank() {
    if (!_rankingForDevice) return MAX_UINT8;

    return _getRank(_deviceLeaderboard);
  }

  String _getDeviceRankString() {
    return "#${_getRankString(_deviceRank, _deviceLeaderboard)} (Device)";
  }

  int _getSportRank() {
    if (!_rankingForSport) return MAX_UINT8;

    return _getRank(_sportLeaderboard);
  }

  String _getSportRankString() {
    return "#${_getRankString(_sportRank, _sportLeaderboard)} (${descriptor.defaultSport})";
  }

  Color getWaveLightColor(int deviceRank, int sportRank, {@required bool background}) {
    if (!_rankingForDevice && !_rankingForSport) {
      return background ? Colors.transparent : _themeManager.getBlueColor();
    }

    if (deviceRank != null && deviceRank <= 1 || sportRank != null && sportRank <= 1) {
      return background ? _lightGreen : _darkGreen;
    }
    return background ? _lightBlue : _darkBlue;
  }

  TextStyle getWaveLightTextStyle(int deviceRank, int sportRank) {
    if (!_rankingForDevice && !_rankingForSport) {
      return _measurementStyle;
    }

    return _measurementStyle.apply(
        color: getWaveLightColor(deviceRank, sportRank, background: false));
  }

  TargetHrState getTargetHrState() {
    if (_heartRate == null || _heartRate == 0 || _targetHrMode == TARGET_HEART_RATE_MODE_NONE) {
      return TargetHrState.Off;
    }

    if (_heartRate < _targetHrBounds.item1) {
      return TargetHrState.Under;
    } else if (_heartRate > _targetHrBounds.item2) {
      return TargetHrState.Over;
    } else {
      return TargetHrState.InRange;
    }
  }

  Color getTargetHrColor(TargetHrState hrState, {bool background}) {
    if (hrState == TargetHrState.Off) {
      return Colors.transparent;
    }

    if (hrState == TargetHrState.Under) {
      return background ? _lightBlue : _darkBlue;
    } else if (hrState == TargetHrState.Over) {
      return background ? _lightRed : _darkRed;
    } else {
      return background ? _lightGreen : _darkGreen;
    }
  }

  TextStyle getTargetHrTextStyle(TargetHrState hrState) {
    if (hrState == TargetHrState.Off) {
      return _measurementStyle;
    }

    return _measurementStyle.apply(color: getTargetHrColor(hrState, background: false));
  }

  String getTargetHrText(TargetHrState hrState) {
    if (hrState == TargetHrState.Off) {
      return "--";
    }

    if (hrState == TargetHrState.Under) {
      return "UNDER!";
    } else if (hrState == TargetHrState.Over) {
      return "OVER!";
    } else {
      return "IN RANGE";
    }
  }

  Widget getTrackMarker(Offset markerPosition, int markerColor, String text) {
    return Positioned(
      left: markerPosition.dx - THICK,
      top: markerPosition.dy - THICK,
      child: Container(
        decoration: BoxDecoration(
          color: Color(markerColor),
          borderRadius: BorderRadius.circular(THICK),
        ),
        width: THICK * 2,
        height: THICK * 2,
        child: Center(child: Text(text)),
      ),
    );
  }

  List<Widget> markersForLeaderboard(List<WorkoutSummary> leaderboard, int rank) {
    List<Widget> markers = [];
    if (leaderboard == null || leaderboard.length <= 0 || rank == null) {
      return markers;
    }

    final length = leaderboard.length;
    if (rank > 1 && rank - 2 < length) {
      final distance = leaderboard[rank - 2].distanceAtTime(_elapsed);
      final position = _trackCalculator.trackMarker(distance);
      markers.add(getTrackMarker(position, 0x8800FF00, "${rank - 1}"));
    }

    if (rank - 1 < length) {
      final distance = leaderboard[rank - 1].distanceAtTime(_elapsed);
      final position = _trackCalculator.trackMarker(distance);
      markers.add(getTrackMarker(position, 0x880000FF, "${rank + 1}"));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final separatorHeight = 1.0;

    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = mediaWidth / 8;
      _measurementStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault,
      );
      _unitStyle = _themeManager.getBlueTextStyle(_sizeDefault / 2);
    }

    if (_measuring &&
        _targetHrMode != TARGET_HEART_RATE_MODE_NONE &&
        _targetHrAudio &&
        _heartRate != null &&
        _heartRate > 0) {
      if (_heartRate < _targetHrBounds.item1 || _heartRate > _targetHrBounds.item2) {
        if (!_targetHrAlerting) {
          Get.find<SoundService>().playTargetHrSoundEffect();
          if (_hrBeepPeriod >= 2) {
            _hrBeepPeriodTimer = Timer(Duration(seconds: _hrBeepPeriod), _hrBeeper);
          }
        }
        _targetHrAlerting = true;
      } else {
        if (_targetHrAlerting) {
          _hrBeepPeriodTimer?.cancel();
          Get.find<SoundService>().stopAllSoundEffects();
        }
        _targetHrAlerting = false;
      }
    }

    final _timeDisplay = Duration(seconds: _elapsed).toDisplay();

    List<Widget> rows = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _themeManager.getBlueIcon(Icons.timer, _sizeDefault),
          Text(_timeDisplay, style: _measurementStyle),
          SizedBox(width: _sizeDefault / 4),
        ],
      ),
    ];

    final targetHrState = getTargetHrState();
    final targetHrTextStyle = getTargetHrTextStyle(targetHrState);

    _rowConfig.asMap().entries.forEach((entry) {
      var measurementStyle = _measurementStyle;

      if (entry.key == 2 && (_rankingForDevice || _rankingForSport)) {
        measurementStyle = getWaveLightTextStyle(_deviceRank, _sportRank);
      }

      if (entry.key == 4 && _targetHrMode != TARGET_HEART_RATE_MODE_NONE) {
        measurementStyle = targetHrTextStyle;
      }

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _themeManager.getBlueIcon(_rowConfig[entry.key].icon, _sizeDefault),
          Spacer(),
          Text(_values[entry.key], style: measurementStyle),
          SizedBox(
            width: _sizeDefault * (entry.value.expandable ? 1.3 : 2),
            child: Center(
              child: Text(
                _rowConfig[entry.key].unit,
                maxLines: 2,
                style: _unitStyle,
              ),
            ),
          ),
        ],
      ));
    });

    var extras = [];
    if (!_simplerUi) {
      _preferencesSpecs.asMap().entries.forEach((entry) {
        var height = 0.0;
        switch (_expandedHeights[entry.key]) {
          case 0:
            height = size.height / 4;
            break;
          case 1:
            height = size.height / 3;
            break;
          case 2:
            height = size.height / 2;
            break;
        }
        Widget extra = GestureDetector(
          onLongPress: () => _onLongPress(entry.key),
          child: SizedBox(
            width: size.width,
            height: height,
            child: charts.TimeSeriesChart(
              _metricToDataFn[entry.value.metric](),
              animate: false,
              flipVerticalAxis: entry.value.flipZones,
              primaryMeasureAxis: charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
              behaviors: [
                charts.RangeAnnotation(
                  entry.value.annotationSegments,
                  defaultLabelStyleSpec: _chartTextStyle,
                ),
              ],
            ),
          ),
        );
        if (entry.value.metric == "hr" && _targetHrMode != TARGET_HEART_RATE_MODE_NONE) {
          int zoneIndex = targetHrState == TargetHrState.Off ? 0 : entry.value.binIndex(_heartRate);
          String targetText = getTargetHrText(targetHrState);
          targetText = "Z$zoneIndex $targetText";
          extra = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text(targetText, style: targetHrTextStyle), extra],
          );
        } else if (entry.value.metric == "speed" &&
            _rankRibbonVisualization &&
            (_rankingForDevice || _rankingForSport)) {
          List<Widget> extraExtras = [];
          if (_rankingForDevice) {
            final deviceWaveLightColor = getWaveLightTextStyle(_deviceRank, null);
            extraExtras.add(Text(_getDeviceRankString(), style: deviceWaveLightColor));
          }
          if (_rankingForSport) {
            final deviceWaveLightColor = getWaveLightTextStyle(null, _sportRank);
            extraExtras.add(Text(_getSportRankString(), style: deviceWaveLightColor));
          }
          extraExtras.add(extra);
          extra = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: extraExtras,
          );
        }
        extras.add(extra);
      });

      List<Widget> markers = [];
      final markerPosition = _trackCalculator.trackMarker(_distance);
      if (markerPosition != null) {
        markers.add(getTrackMarker(markerPosition, 0x88FF0000, ""));
        if (_rankTrackVisualization) {
          if (_rankingForDevice) {
            markers.addAll(markersForLeaderboard(_deviceLeaderboard, _deviceRank));
          }
          if (_rankingForSport) {
            markers.addAll(markersForLeaderboard(_sportLeaderboard, _sportRank));
          }
        }
      }
      extras.add(
        CustomPaint(
          painter: TrackPainter(calculator: _trackCalculator),
          child: SizedBox(
            width: size.width,
            height: size.width / 1.9,
            child: Stack(children: markers),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: TextOneLine(
            device.name,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: initialState,
              builder: (c, snapshot) {
                VoidCallback onPressed;
                IconData icon;
                switch (snapshot.data) {
                  case BluetoothDeviceState.connected:
                    onPressed = () async {
                      await _fitnessEquipment.disconnect();
                    };
                    icon = Icons.bluetooth_connected;
                    break;
                  case BluetoothDeviceState.disconnected:
                    onPressed = () async {
                      await _fitnessEquipment.connect();
                    };
                    icon = Icons.bluetooth_disabled;
                    break;
                  default:
                    onPressed = null;
                    icon = Icons.bluetooth_searching;
                    break;
                }
                return IconButton(
                  icon: Icon(icon),
                  onPressed: onPressed,
                );
              },
            ),
            IconButton(
                icon: Icon(_measuring ? Icons.stop : Icons.play_arrow),
                onPressed: () async {
                  if (_measuring) {
                    await _stopMeasurement(false);
                  } else {
                    await _startMeasurement();
                  }
                }),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              rows[0],
              Divider(height: separatorHeight),
              rows[1],
              Divider(height: separatorHeight),
              ExpandablePanel(
                theme: _expandableThemeData,
                header: rows[2],
                expanded: _simplerUi ? null : extras[0],
                controller: _rowControllers[0],
              ),
              Divider(height: separatorHeight),
              ColoredBox(
                color: getWaveLightColor(_deviceRank, _sportRank, background: true),
                child: ExpandablePanel(
                  theme: _expandableThemeData,
                  header: rows[3],
                  expanded: _simplerUi ? null : extras[1],
                  controller: _rowControllers[1],
                ),
              ),
              Divider(height: separatorHeight),
              ExpandablePanel(
                theme: _expandableThemeData,
                header: rows[4],
                expanded: _simplerUi ? null : extras[2],
                controller: _rowControllers[2],
              ),
              Divider(height: separatorHeight),
              ColoredBox(
                color: getTargetHrColor(targetHrState, background: true),
                child: ExpandablePanel(
                  theme: _expandableThemeData,
                  header: rows[5],
                  expanded: _simplerUi ? null : extras[3],
                  controller: _rowControllers[3],
                ),
              ),
              Divider(height: separatorHeight),
              ExpandablePanel(
                theme: _expandableThemeData,
                header: rows[6],
                expanded: _simplerUi ? null : extras[4],
                controller: _rowControllers[4],
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FabCircularMenu(
          fabOpenIcon: Icon(Icons.menu, color: _themeManager.getAntagonistColor()),
          fabOpenColor: _themeManager.getBlueColor(),
          fabCloseIcon: Icon(Icons.close, color: _themeManager.getAntagonistColor()),
          fabCloseColor: _themeManager.getBlueColor(),
          ringColor: _themeManager.getBlueColorInverse(),
          children: [
            _themeManager.getStravaFab(() async {
              if (_measuring) {
                Get.snackbar("Warning", "Cannot upload while measurement is under progress");
                return;
              }

              await _stravaUpload(false);
            }),
            _themeManager.getBlueFab(Icons.list_alt, () async {
              if (_measuring) {
                Get.snackbar("Warning", "Cannot navigate while measurement is under progress");
              } else {
                final hasLeaderboardData = await _database.hasLeaderboardData();
                await Get.to(ActivitiesScreen(hasLeaderboardData: hasLeaderboardData));
              }
            }),
            _themeManager.getBlueFab(Icons.battery_unknown, () async {
              await Get.bottomSheet(
                BatteryStatusBottomSheet(),
                enableDrag: false,
              );
            }),
            _themeManager.getBlueFab(Icons.build, () async {
              if (_measuring) {
                Get.snackbar("Warning", "Cannot calibrate while measurement is under progress");
              } else if (!_fitnessEquipment.descriptor.isFitnessMachine) {
                Get.snackbar("Error", "Not compatible with the calibration method");
              } else {
                await Get.bottomSheet(
                  SpinDownBottomSheet(),
                  isDismissible: false,
                  enableDrag: false,
                );
              }
            }),
            _themeManager.getBlueFab(Icons.favorite, () async {
              await Get.bottomSheet(
                HeartRateMonitorPairingBottomSheet(),
                isDismissible: false,
                enableDrag: false,
              );
              await _initializeHeartRateMonitor();
            }),
          ],
        ),
      ),
    );
  }
}
