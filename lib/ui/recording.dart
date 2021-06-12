import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:tuple/tuple.dart';
import 'package:wakelock/wakelock.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/gadgets/fitness_equipment.dart';
import '../devices/gadgets/heart_rate_monitor.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/workout_summary.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../strava/strava_status_code.dart';
import '../strava/strava_service.dart';
import '../track/calculator.dart';
import '../track/constants.dart';
import '../track/track_painter.dart';
import '../track/tracks.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import '../utils/preferences.dart';
import '../utils/sound.dart';
import '../utils/target_heart_rate.dart';
import '../utils/theme_manager.dart';
import 'models/display_record.dart';
import 'models/row_configuration.dart';
import 'parts/circular_menu.dart';
import 'parts/battery_status.dart';
import 'parts/heart_rate_monitor_pairing.dart';
import 'parts/spin_down.dart';
import 'activities.dart';

typedef DataFn = List<charts.LineSeries<DisplayRecord, DateTime>> Function();

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
    Key? key,
    required this.device,
    required this.descriptor,
    required this.initialState,
    required this.size,
    required this.sport,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => RecordingState();
}

class RecordingState extends State<RecordingScreen> {
  RecordingState() {
    size = widget.size;
  }

  late Size size;
  FitnessEquipment? _fitnessEquipment;
  HeartRateMonitor? _heartRateMonitor;
  TrackCalculator? _trackCalculator;
  bool _measuring = false;
  int _pointCount = 0;
  ListQueue<DisplayRecord> _graphData = ListQueue<DisplayRecord>();
  double? _mediaWidth;
  double _sizeDefault = 10.0;
  TextStyle _measurementStyle = TextStyle();
  TextStyle _unitStyle = TextStyle();
  Color _chartTextColor = Colors.black;
  TextStyle _markerStyle = TextStyle();
  ExpandableThemeData _expandableThemeData = ExpandableThemeData(
    hasIcon: !SIMPLER_UI_SLOW_DEFAULT,
    iconColor: Colors.black,
  );
  List<bool> _expandedState = [];
  List<ExpandableController> _rowControllers = [];
  List<int> _expandedHeights = [];
  List<PreferencesSpec> _preferencesSpecs = [];

  Activity? _activity;
  AppDatabase _database = Get.find<AppDatabase>();
  bool _si = UNIT_SYSTEM_DEFAULT;
  bool _simplerUi = SIMPLER_UI_SLOW_DEFAULT;
  bool _instantUpload = INSTANT_UPLOAD_DEFAULT;
  bool _uxDebug = APP_DEBUG_MODE_DEFAULT;

  Timer? _dataGapWatchdog;
  int _dataGapWatchdogTime = DATA_STREAM_GAP_WATCHDOG_DEFAULT_INT;
  String _dataGapSoundEffect = DATA_STREAM_GAP_SOUND_EFFECT_DEFAULT;
  Timer? _dataGapBeeperTimer;

  List<DisplayRecord> get graphData => _graphData.toList();
  Map<String, DataFn> _metricToDataFn = {};
  List<RowConfiguration> _rowConfig = [];
  List<String> _values = [];
  List<int?> _zoneIndexes = [];
  double _distance = 0.0;
  int _elapsed = 0;

  String _targetHrMode = TARGET_HEART_RATE_MODE_DEFAULT;
  Tuple2<double, double> _targetHrBounds = Tuple2(0, 0);
  int? _heartRate;
  Timer? _hrBeepPeriodTimer;
  int _hrBeepPeriod = TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT_INT;
  bool _targetHrAudio = TARGET_HEART_RATE_AUDIO_DEFAULT;
  bool _targetHrAlerting = false;
  bool _leaderboardFeature = LEADERBOARD_FEATURE_DEFAULT;
  bool _rankingForDevice = RANKING_FOR_DEVICE_DEFAULT;
  List<WorkoutSummary> _deviceLeaderboard = [];
  int? _deviceRank;
  String _deviceRankString = "";
  bool _rankingForSport = RANKING_FOR_SPORT_DEFAULT;
  List<WorkoutSummary> _sportLeaderboard = [];
  int? _sportRank;
  String _sportRankString = "";
  bool _rankRibbonVisualization = RANK_RIBBON_VISUALIZATION_DEFAULT;
  bool _rankTrackVisualization = RANK_TRACK_VISUALIZATION_DEFAULT;
  bool _rankInfoOnTrack = RANK_INFO_ON_TRACK_DEFAULT;
  Color _darkRed = Colors.red;
  Color _darkGreen = Colors.green;
  Color _darkBlue = Colors.blue;
  Color _lightRed = Colors.redAccent;
  Color _lightGreen = Colors.lightGreenAccent;
  Color _lightBlue = Colors.lightBlueAccent;
  ThemeManager _themeManager = Get.find<ThemeManager>();
  bool _isLight = true;
  bool _zoneIndexColoring = false;

  charts.TrackballBehavior _trackballBehavior = charts.TrackballBehavior(
    enable: true,
    activationMode: charts.ActivationMode.singleTap,
    tooltipDisplayMode: charts.TrackballDisplayMode.nearestPoint,
  );

  Future<void> _connectOnDemand(BluetoothDeviceState deviceState) async {
    bool success = await _fitnessEquipment?.connectOnDemand(deviceState) ?? false;
    if (success) {
      final prefService = Get.find<BasePrefService>();
      if (prefService.get<bool>(INSTANT_MEASUREMENT_START_TAG) ??
          INSTANT_MEASUREMENT_START_DEFAULT) {
        await _startMeasurement();
      }
    } else {
      Get.defaultDialog(
        middleText: 'Problem co-operating with ${widget.descriptor.fullName}. Aborting...',
        confirm: TextButton(
          child: Text("Ok"),
          onPressed: () => Get.close(1),
        ),
      );
    }
  }

  void amendZoneToValue(int valueIndex, int value) {
    if (_preferencesSpecs[valueIndex].indexDisplay) {
      int zoneIndex = _preferencesSpecs[valueIndex].binIndex(value);
      _values[valueIndex + 1] += " Z$zoneIndex";
      if (_zoneIndexColoring) {
        _zoneIndexes[valueIndex] = zoneIndex;
      }
    }
  }

  Future<void> _startMeasurement() async {
    final now = DateTime.now();
    final powerFactor = await _database.powerFactor(widget.device.id.id);
    final calorieFactor = await _database.calorieFactor(widget.device.id.id, widget.descriptor);
    _activity = Activity(
      fourCC: widget.descriptor.fourCC,
      deviceName: widget.device.name,
      deviceId: widget.device.id.id,
      start: now.millisecondsSinceEpoch,
      startDateTime: now,
      sport: widget.descriptor.defaultSport,
      powerFactor: powerFactor,
      calorieFactor: calorieFactor,
    );
    if (!_uxDebug) {
      final id = await _database.activityDao.insertActivity(_activity!);
      _activity!.id = id;
    }

    if (_rankingForDevice) {
      _deviceRank = null;
      _deviceRankString = "";
      _deviceLeaderboard =
          await _database.workoutSummaryDao.findAllWorkoutSummariesByDevice(widget.device.id.id);
    }
    if (_rankingForSport) {
      _sportRank = null;
      _sportRankString = "";
      _sportLeaderboard = await _database.workoutSummaryDao
          .findAllWorkoutSummariesBySport(widget.descriptor.defaultSport);
    }

    _fitnessEquipment?.setActivity(_activity!);

    await _fitnessEquipment?.attach();
    setState(() {
      _elapsed = 0;
      _distance = 0.0;
      _measuring = true;
      _zoneIndexes = [null, null, null, null];
    });
    _fitnessEquipment?.measuring = true;
    _fitnessEquipment?.startWorkout();

    _fitnessEquipment?.pumpData((record) async {
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
          await _database.recordDao.insertRecord(record);
        }

        _fitnessEquipment?.lastRecord = record;

        setState(() {
          if (!_simplerUi) {
            _graphData.add(record.display());
            if (_pointCount > 0 && _graphData.length > _pointCount) {
              _graphData.removeFirst();
            }
          }

          _distance = record.distance ?? 0.0;
          _elapsed = record.elapsed ?? 0;
          if (record.heartRate != null &&
              (record.heartRate! > 0 || _heartRate == null || _heartRate == 0)) {
            _heartRate = record.heartRate;
          }

          if (_rankingForDevice) {
            _deviceRank = _getDeviceRank();
            _deviceRankString = _getDeviceRankString();
          }
          if (_rankingForSport) {
            _sportRank = _getSportRank();
            _sportRankString = _getSportRankString();
          }

          _values = [
            record.calories.toString(),
            record.power.toString(),
            record.speedOrPaceStringByUnit(_si, widget.descriptor.defaultSport),
            record.cadence.toString(),
            record.heartRate.toString(),
            record.distanceStringByUnit(_si),
          ];
          amendZoneToValue(0, record.power ?? 0);
          amendZoneToValue(2, record.cadence ?? 0);
          amendZoneToValue(3, record.heartRate ?? 0);
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
      final prefService = Get.find<BasePrefService>();
      prefService.set<String>(MEASUREMENT_PANELS_EXPANDED_TAG, expandedStateStr);
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
      final prefService = Get.find<BasePrefService>();
      prefService.set<String>(MEASUREMENT_DETAIL_SIZE_TAG, expandedHeightStr);
    });
  }

  Future<void> _initializeHeartRateMonitor() async {
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    final discovered = (await _heartRateMonitor?.discover()) ?? false;
    if (discovered) {
      if (_heartRateMonitor?.device?.id.id !=
          (_fitnessEquipment?.heartRateMonitor?.device?.id.id ?? NOT_AVAILABLE)) {
        _fitnessEquipment?.setHeartRateMonitor(_heartRateMonitor!);
      }
      _heartRateMonitor?.attach().then((_) async {
        if (_heartRateMonitor?.subscription != null) {
          await _heartRateMonitor?.cancelSubscription();
        }
        _heartRateMonitor?.pumpMetric((heartRate) async {
          setState(() {
            if (heartRate > 0 || _heartRate == null || _heartRate == 0) {
              _heartRate = heartRate;
            }
            _values[4] = heartRate.toString();
            amendZoneToValue(3, heartRate);
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
    _markerStyle = _themeManager.boldStyle(Get.textTheme.bodyText1!, fontSizeFactor: 1.4);
    final prefService = Get.find<BasePrefService>();
    prefService.set<String>(
      LAST_EQUIPMENT_ID_TAG_PREFIX + PreferencesSpec.sport2Sport(widget.sport),
      widget.device.id.id,
    );
    widget.descriptor.refreshTuning(widget.device.id.id);
    if (Get.isRegistered<FitnessEquipment>()) {
      _fitnessEquipment = Get.find<FitnessEquipment>();
      _fitnessEquipment?.descriptor = widget.descriptor;
    } else {
      _fitnessEquipment = Get.put<FitnessEquipment>(
          FitnessEquipment(descriptor: widget.descriptor, device: widget.device));
    }

    _trackCalculator = TrackCalculator(
      track: TrackDescriptor(
        radiusBoost: TRACK_PAINTING_RADIUS_BOOST,
        lengthFactor: widget.descriptor.lengthFactor,
      ),
    );
    _si = prefService.get<bool>(UNIT_SYSTEM_TAG) ?? UNIT_SYSTEM_DEFAULT;
    _simplerUi = prefService.get<bool>(SIMPLER_UI_TAG) ?? SIMPLER_UI_SLOW_DEFAULT;
    _instantUpload = prefService.get<bool>(INSTANT_UPLOAD_TAG) ?? INSTANT_UPLOAD_DEFAULT;
    _graphData = ListQueue<DisplayRecord>(_simplerUi ? 0 : _pointCount);

    if (widget.sport != ActivityType.Ride) {
      final slowPace = PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(widget.sport)]!;
      widget.descriptor.slowPace = slowPace;
      _fitnessEquipment?.slowPace = slowPace;
    }

    _preferencesSpecs = PreferencesSpec.getPreferencesSpecs(_si, widget.descriptor.defaultSport);
    _preferencesSpecs.forEach((prefSpec) => prefSpec.calculateBounds(
          0,
          decimalRound(prefSpec.threshold * (prefSpec.zonePercents.last + 15) / 100.0),
          _isLight,
        ));

    _dataGapWatchdogTime = getStringIntegerPreference(
      DATA_STREAM_GAP_WATCHDOG_TAG,
      DATA_STREAM_GAP_WATCHDOG_DEFAULT,
      DATA_STREAM_GAP_WATCHDOG_DEFAULT_INT,
      prefService,
    );
    _dataGapSoundEffect = prefService.get<String>(DATA_STREAM_GAP_SOUND_EFFECT_TAG) ??
        DATA_STREAM_GAP_SOUND_EFFECT_DEFAULT;

    _targetHrMode =
        prefService.get<String>(TARGET_HEART_RATE_MODE_TAG) ?? TARGET_HEART_RATE_MODE_DEFAULT;
    _targetHrBounds = getTargetHeartRateBounds(_targetHrMode, _preferencesSpecs[3], prefService);
    _targetHrAlerting = false;
    _targetHrAudio =
        prefService.get<bool>(TARGET_HEART_RATE_AUDIO_TAG) ?? TARGET_HEART_RATE_AUDIO_DEFAULT;
    if (_targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio) {
      _hrBeepPeriod = getStringIntegerPreference(
        TARGET_HEART_RATE_AUDIO_PERIOD_TAG,
        TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT,
        TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT_INT,
        prefService,
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

    _chartTextColor = _themeManager.getProtagonistColor();
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
    final expandedStateStr = prefService.get<String>(MEASUREMENT_PANELS_EXPANDED_TAG) ??
        MEASUREMENT_PANELS_EXPANDED_DEFAULT;
    final expandedHeightStr =
        prefService.get<String>(MEASUREMENT_DETAIL_SIZE_TAG) ?? MEASUREMENT_DETAIL_SIZE_DEFAULT;
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

      final expandedHeight = int.tryParse(expandedHeightStr[index]) ?? 0;
      _expandedHeights.add(expandedHeight);
      return expanded;
    });

    _uxDebug = prefService.get<bool>(APP_DEBUG_MODE_TAG) ?? APP_DEBUG_MODE_DEFAULT;
    _fitnessEquipment?.measuring = false;
    _values = ["--", "--", "--", "--", "--", "--"];
    _zoneIndexes = [null, null, null, null];

    _leaderboardFeature =
        prefService.get<bool>(LEADERBOARD_FEATURE_TAG) ?? LEADERBOARD_FEATURE_DEFAULT;
    _rankRibbonVisualization =
        prefService.get<bool>(RANK_RIBBON_VISUALIZATION_TAG) ?? RANK_RIBBON_VISUALIZATION_DEFAULT;
    _rankingForDevice = prefService.get<bool>(RANKING_FOR_DEVICE_TAG) ?? RANKING_FOR_DEVICE_DEFAULT;
    _deviceLeaderboard = [];
    _deviceRankString = "";
    _rankingForSport = prefService.get<bool>(RANKING_FOR_SPORT_TAG) ?? RANKING_FOR_SPORT_DEFAULT;
    _sportLeaderboard = [];
    _sportRankString = "";
    _rankTrackVisualization =
        prefService.get<bool>(RANK_TRACK_VISUALIZATION_TAG) ?? RANK_TRACK_VISUALIZATION_DEFAULT;
    _rankInfoOnTrack = prefService.get<bool>(RANK_INFO_ON_TRACK_TAG) ?? RANK_INFO_ON_TRACK_DEFAULT;

    final isLight = !_themeManager.isDark();
    _darkRed = isLight ? Colors.red.shade900 : Colors.redAccent.shade100;
    _darkGreen = isLight ? Colors.green.shade900 : Colors.lightGreenAccent.shade100;
    _darkBlue = isLight ? Colors.indigo.shade900 : Colors.lightBlueAccent.shade100;
    _lightRed = isLight ? Colors.redAccent.shade100 : Colors.red.shade900;
    _lightGreen = isLight ? Colors.lightGreenAccent.shade100 : Colors.green.shade900;
    _lightBlue = isLight ? Colors.lightBlueAccent.shade100 : Colors.indigo.shade900;

    _zoneIndexColoring = prefService.get<bool>(ZONE_INDEX_DISPLAY_COLORING_TAG) ??
        ZONE_INDEX_DISPLAY_COLORING_DEFAULT;

    _initializeHeartRateMonitor();
    _connectOnDemand(widget.initialState);
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

    setState(() {
      _measuring = false;
    });
    _fitnessEquipment?.measuring = false;
    try {
      await _fitnessEquipment?.detach();
      await _fitnessEquipment?.disconnect();
    } on PlatformException catch (e, stack) {
      debugPrint("Equipment got turned off?");
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
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
        _heartRate! > 0) {
      if (_heartRate! < _targetHrBounds.item1 || _heartRate! > _targetHrBounds.item2) {
        _hrBeepPeriodTimer = Timer(Duration(seconds: _hrBeepPeriod), _hrBeeper);
      }
    }
  }

  _stravaUpload(bool onlyWhenAuthenticated) async {
    if (_activity == null) return;

    StravaService stravaService;
    if (!Get.isRegistered<StravaService>()) {
      stravaService = Get.put<StravaService>(StravaService());
    } else {
      stravaService = Get.find<StravaService>();
    }

    if (onlyWhenAuthenticated && !await stravaService.hasValidToken()) {
      return;
    }

    if (!await InternetConnectionChecker().hasConnection) {
      Get.snackbar("Warning", "No data connection detected");
      return;
    }

    final success = await stravaService.login();
    if (!success) {
      Get.snackbar("Warning", "Strava login unsuccessful");
      return;
    }

    final records = await _database.recordDao.findAllActivityRecords(_activity?.id ?? 0);
    final statusCode = await stravaService.upload(_activity!, records);
    Get.snackbar(
        "Upload",
        statusCode == StravaStatusCode.statusOk || statusCode >= 200 && statusCode < 300
            ? "Activity ${_activity!.id} submitted successfully"
            : "Activity ${_activity!.id} upload failure");
  }

  _stopMeasurement(bool quick) async {
    _fitnessEquipment?.measuring = false;
    if (!_measuring || _activity == null) return;

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

    _fitnessEquipment?.detach();

    _activity!.finish(
      _fitnessEquipment?.lastRecord.distance,
      _fitnessEquipment?.lastRecord.elapsed,
      _fitnessEquipment?.lastRecord.calories,
    );
    _fitnessEquipment?.stopWorkout();

    if (!_uxDebug) {
      if (_leaderboardFeature) {
        await _database.workoutSummaryDao.insertWorkoutSummary(
            _activity!.getWorkoutSummary(_fitnessEquipment?.manufacturerName ?? "Unknown"));
      }

      final retVal = await _database.activityDao.updateActivity(_activity!);
      if (retVal <= 0 && !quick) {
        Get.snackbar("Warning", "Could not save activity");
        return;
      }

      if (_instantUpload && !quick) {
        await _stravaUpload(true);
      }
    }
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _powerChartData() {
    return <charts.LineSeries<DisplayRecord, DateTime>>[
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: graphData,
        xValueMapper: (DisplayRecord record, _) => record.dt,
        yValueMapper: (DisplayRecord record, _) => record.power,
        color: _chartTextColor,
      ),
    ];
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _speedChartData() {
    return <charts.LineSeries<DisplayRecord, DateTime>>[
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: graphData,
        xValueMapper: (DisplayRecord record, _) => record.dt,
        yValueMapper: (DisplayRecord record, _) => record.speedByUnit(_si),
        color: _chartTextColor,
      ),
    ];
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _cadenceChartData() {
    return <charts.LineSeries<DisplayRecord, DateTime>>[
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: graphData,
        xValueMapper: (DisplayRecord record, _) => record.dt,
        yValueMapper: (DisplayRecord record, _) => record.cadence,
        color: _chartTextColor,
      ),
    ];
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _hRChartData() {
    return <charts.LineSeries<DisplayRecord, DateTime>>[
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: graphData,
        xValueMapper: (DisplayRecord record, _) => record.dt,
        yValueMapper: (DisplayRecord record, _) => record.heartRate,
        color: _chartTextColor,
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

  Color _getZoneColor({required metricIndex, required bool background}) {
    if (_zoneIndexes[metricIndex] == null) {
      return background ? Colors.transparent : _themeManager.getProtagonistColor();
    }

    return background
        ? _preferencesSpecs[metricIndex].bgColorByBin(_zoneIndexes[metricIndex]!, _isLight)
        : _preferencesSpecs[metricIndex].fgColorByBin(_zoneIndexes[metricIndex]!, _isLight);
  }

  int? _getRank(List<WorkoutSummary> leaderboard) {
    if (leaderboard.length <= 0) {
      return 1;
    }

    if (_elapsed == 0) {
      return null;
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

  String _getRankString(int? rank, List<WorkoutSummary> leaderboard) {
    return rank == null ? "--" : rank.toString();
  }

  int? _getDeviceRank() {
    if (!_rankingForDevice) return null;

    return _getRank(_deviceLeaderboard);
  }

  String _getDeviceRankString() {
    return "#${_getRankString(_deviceRank, _deviceLeaderboard)} (Device)";
  }

  int? _getSportRank() {
    if (!_rankingForSport) return null;

    return _getRank(_sportLeaderboard);
  }

  String _getSportRankString() {
    return "#${_getRankString(_sportRank, _sportLeaderboard)} (${widget.descriptor.defaultSport})";
  }

  Color _getPaceLightColor(int? deviceRank, int? sportRank, {required bool background}) {
    if (!_rankingForDevice && !_rankingForSport || deviceRank == null && sportRank == null) {
      return background ? Colors.transparent : _themeManager.getBlueColor();
    }

    if (deviceRank != null && deviceRank <= 1 || sportRank != null && sportRank <= 1) {
      return background ? _lightGreen : _darkGreen;
    }
    return background ? _lightBlue : _darkBlue;
  }

  TextStyle _getPaceLightTextStyle(int? deviceRank, int? sportRank) {
    if (!_rankingForDevice && !_rankingForSport) {
      return _measurementStyle;
    }

    return _measurementStyle.apply(
        color: _getPaceLightColor(deviceRank, sportRank, background: false));
  }

  TargetHrState _getTargetHrState() {
    if (_heartRate == null || _heartRate == 0 || _targetHrMode == TARGET_HEART_RATE_MODE_NONE) {
      return TargetHrState.Off;
    }

    if (_heartRate! < _targetHrBounds.item1) {
      return TargetHrState.Under;
    } else if (_heartRate! > _targetHrBounds.item2) {
      return TargetHrState.Over;
    } else {
      return TargetHrState.InRange;
    }
  }

  Color _getTargetHrColor(TargetHrState hrState, bool background) {
    if (hrState == TargetHrState.Off) {
      return _getZoneColor(metricIndex: 3, background: background);
    }

    if (hrState == TargetHrState.Under) {
      return background ? _lightBlue : _darkBlue;
    } else if (hrState == TargetHrState.Over) {
      return background ? _lightRed : _darkRed;
    } else {
      return background ? _lightGreen : _darkGreen;
    }
  }

  TextStyle _getTargetHrTextStyle(TargetHrState hrState) {
    if (hrState == TargetHrState.Off) {
      if (_zoneIndexes[3] == null) {
        return _measurementStyle;
      } else {
        return _measurementStyle.apply(color: _getZoneColor(metricIndex: 3, background: false));
      }
    }

    return _measurementStyle.apply(color: _getTargetHrColor(hrState, false));
  }

  String _getTargetHrText(TargetHrState hrState) {
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

  Widget _getTrackMarker(Offset markerPosition, int markerColor, String text, bool self) {
    double radius = THICK;
    if (self) {
      radius -= 1;
    }

    return Positioned(
      left: markerPosition.dx - radius,
      top: markerPosition.dy - radius,
      child: Container(
        decoration: BoxDecoration(
          color: Color(markerColor),
          borderRadius: BorderRadius.circular(radius),
        ),
        width: radius * 2,
        height: radius * 2,
        child: Center(child: Text(text, style: _markerStyle)),
      ),
    );
  }

  List<Widget> _markersForLeaderboard(List<WorkoutSummary> leaderboard, int? rank) {
    List<Widget> markers = [];
    if (leaderboard.length <= 0 || rank == null || _trackCalculator == null) {
      return markers;
    }

    final length = leaderboard.length;
    // Preceding dot ahead of the preceding (if any)
    if (rank > 2 && rank - 3 < length) {
      final distance = leaderboard[rank - 3].distanceAtTime(_elapsed);
      final position = _trackCalculator?.trackMarker(distance);
      if (position != null) {
        markers.add(_getTrackMarker(position, 0x8800FF00, "${rank - 2}", false));
      }
    }

    // Preceding dot (chasing directly) if any
    if (rank > 1 && rank - 2 < length) {
      final distance = leaderboard[rank - 2].distanceAtTime(_elapsed);
      final position = _trackCalculator?.trackMarker(distance);
      if (position != null) {
        markers.add(_getTrackMarker(position, 0x8800FF00, "${rank - 1}", false));
      }
    }

    // Following dot (following directly) if any
    if (rank - 1 < length) {
      final distance = leaderboard[rank - 1].distanceAtTime(_elapsed);
      final position = _trackCalculator?.trackMarker(distance);
      if (position != null) {
        markers.add(_getTrackMarker(position, 0x880000FF, "${rank + 1}", false));
      }
    }

    // Following dot after the follower (if any)
    if (rank < length) {
      final distance = leaderboard[rank].distanceAtTime(_elapsed);
      final position = _trackCalculator?.trackMarker(distance);
      if (position != null) {
        markers.add(_getTrackMarker(position, 0x880000FF, "${rank + 2}", false));
      }
    }

    return markers;
  }

  Widget _getLeaderboardInfoTextCore(String text, bool lead) {
    final bgColor = lead ? _lightGreen : _lightBlue;
    return ColoredBox(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
        child: Text(text, style: _markerStyle),
      ),
    );
  }

  Widget _getLeaderboardInfoText(int rank, double distance, bool lead) {
    return _getLeaderboardInfoTextCore("#$rank ${distanceByUnit(distance - _distance, _si)}", lead);
  }

  Widget _infoForLeaderboard(List<WorkoutSummary> leaderboard, int? rank, String rankString) {
    if (leaderboard.length <= 0 || rank == null) {
      return Text(rankString, style: _markerStyle);
    }

    List<Widget> rows = [];
    final length = leaderboard.length;
    // Preceding dot ahead of the preceding (if any)
    if (rank > 2 && rank - 3 < length) {
      final distance = leaderboard[rank - 3].distanceAtTime(_elapsed);
      rows.add(_getLeaderboardInfoText(rank - 2, distance, true));
      rows.add(Divider(height: 1));
    }

    // Preceding dot (chasing directly) if any
    if (rank > 1 && rank - 2 < length) {
      final distance = leaderboard[rank - 2].distanceAtTime(_elapsed);
      rows.add(_getLeaderboardInfoText(rank - 1, distance, true));
      rows.add(Divider(height: 1));
    }

    rows.add(_getLeaderboardInfoTextCore(rankString, rank <= 1));

    // Following dot (following directly) if any
    if (rank - 1 < length) {
      rows.add(Divider(height: 1));
      final distance = leaderboard[rank - 1].distanceAtTime(_elapsed);
      rows.add(_getLeaderboardInfoText(rank + 1, distance, false));
    }

    // Following dot after the follower (if any)
    if (rank < length) {
      rows.add(Divider(height: 1));
      final distance = leaderboard[rank].distanceAtTime(_elapsed);
      rows.add(_getLeaderboardInfoText(rank + 2, distance, false));
    }

    return IntrinsicWidth(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final separatorHeight = 1.0;

    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth! - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = mediaWidth / 8;
      _measurementStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault,
      );
      _unitStyle = _themeManager.getBlueTextStyle(_sizeDefault / 3);
    }

    if (_measuring &&
        _targetHrMode != TARGET_HEART_RATE_MODE_NONE &&
        _targetHrAudio &&
        _heartRate != null &&
        _heartRate! > 0) {
      if (_heartRate! < _targetHrBounds.item1 || _heartRate! > _targetHrBounds.item2) {
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

    final targetHrState = _getTargetHrState();
    final targetHrTextStyle = _getTargetHrTextStyle(targetHrState);

    _rowConfig.asMap().entries.forEach((entry) {
      var measurementStyle = _measurementStyle;

      if (entry.key == 2 && (_rankingForDevice || _rankingForSport)) {
        measurementStyle = _getPaceLightTextStyle(_deviceRank, _sportRank);
      }

      if (entry.key == 4 && _targetHrMode != TARGET_HEART_RATE_MODE_NONE ||
          _zoneIndexes[3] != null) {
        measurementStyle = targetHrTextStyle;
      }

      if ((entry.key == 1 || entry.key == 3) && _zoneIndexes[entry.key - 1] != null) {
        measurementStyle = _measurementStyle.apply(
            color: _getZoneColor(metricIndex: entry.key - 1, background: false));
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
            child: charts.SfCartesianChart(
              primaryXAxis: charts.DateTimeAxis(),
              primaryYAxis: charts.NumericAxis(
                plotBands: entry.value.plotBands,
              ),
              margin: EdgeInsets.all(0),
              series: _metricToDataFn[entry.value.metric]!(),
              trackballBehavior: _trackballBehavior,
            ),
          ),
        );
        if (entry.value.metric == "hr" && _targetHrMode != TARGET_HEART_RATE_MODE_NONE) {
          int zoneIndex =
              targetHrState == TargetHrState.Off ? 0 : entry.value.binIndex(_heartRate ?? 0);
          String targetText = _getTargetHrText(targetHrState);
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
            final devicePaceLightColor = _getPaceLightTextStyle(_deviceRank, null);
            extraExtras.add(Text(_deviceRankString, style: devicePaceLightColor));
          }

          if (_rankingForSport) {
            final devicePaceLightColor = _getPaceLightTextStyle(null, _sportRank);
            extraExtras.add(Text(_sportRankString, style: devicePaceLightColor));
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
      final markerPosition = _trackCalculator?.trackMarker(_distance);
      if (markerPosition != null) {
        var selfMarkerText = "";
        var selfMarkerColor = 0xFFFF0000;
        if (_rankTrackVisualization && (_rankingForDevice || _rankingForSport)) {
          Widget? rankInfo;
          Widget? deviceRankInfo;
          if (_rankingForDevice) {
            markers.addAll(_markersForLeaderboard(_deviceLeaderboard, _deviceRank));
            if (_deviceRank != null) {
              selfMarkerText = _deviceRank.toString();
            }

            if (_rankInfoOnTrack) {
              deviceRankInfo =
                  _infoForLeaderboard(_deviceLeaderboard, _deviceRank, _deviceRankString);
              if (!_rankingForSport) {
                rankInfo = Center(child: deviceRankInfo);
              }
            }
          }

          Widget? sportRankInfo;
          if (_rankingForSport) {
            markers.addAll(_markersForLeaderboard(_sportLeaderboard, _sportRank));
            if (_sportRank != null && _deviceRank == null) {
              selfMarkerText = _sportRank.toString();
            }

            if (_rankInfoOnTrack) {
              sportRankInfo = _infoForLeaderboard(_sportLeaderboard, _sportRank, _sportRankString);
              if (!_rankingForDevice) {
                rankInfo = Center(child: sportRankInfo);
              }
            }
          }

          if (_rankInfoOnTrack) {
            if (_rankingForDevice &&
                deviceRankInfo != null &&
                _rankingForDevice &&
                sportRankInfo != null) {
              rankInfo = Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [deviceRankInfo, Container(width: 2), sportRankInfo],
                ),
              );
            }

            if (rankInfo != null) {
              markers.add(rankInfo);
            }
          }

          // Add red circle around the athlete marker to distinguish
          markers.add(_getTrackMarker(markerPosition, selfMarkerColor, "", false));
          selfMarkerColor = _getPaceLightColor(_deviceRank, _sportRank, background: true).value;
        }

        markers.add(_getTrackMarker(
            markerPosition, selfMarkerColor, selfMarkerText, _rankTrackVisualization));
      }

      if (_trackCalculator != null) {
        extras.add(
          CustomPaint(
            painter: TrackPainter(calculator: _trackCalculator!),
            child: SizedBox(
              width: size.width,
              height: size.width / 1.9,
              child: Stack(children: markers),
            ),
          ),
        );
      }
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: TextOneLine(
            widget.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            StreamBuilder<BluetoothDeviceState>(
              stream: widget.device.state,
              initialData: widget.initialState,
              builder: (c, snapshot) {
                VoidCallback? onPressed;
                IconData icon;
                switch (snapshot.data) {
                  case BluetoothDeviceState.connected:
                    onPressed = () async {
                      await _fitnessEquipment?.disconnect();
                    };
                    icon = Icons.bluetooth_connected;
                    break;
                  case BluetoothDeviceState.disconnected:
                    onPressed = () async {
                      await _fitnessEquipment?.connect();
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
              ColoredBox(
                color: _getZoneColor(metricIndex: 0, background: true),
                child: ExpandablePanel(
                  theme: _expandableThemeData,
                  header: rows[2],
                  collapsed: Container(),
                  expanded: _simplerUi ? null : extras[0],
                  controller: _rowControllers[0],
                ),
              ),
              Divider(height: separatorHeight),
              ColoredBox(
                color: _getPaceLightColor(_deviceRank, _sportRank, background: true),
                child: ExpandablePanel(
                  theme: _expandableThemeData,
                  header: rows[3],
                  collapsed: Container(),
                  expanded: _simplerUi ? null : extras[1],
                  controller: _rowControllers[1],
                ),
              ),
              Divider(height: separatorHeight),
              ColoredBox(
                color: _getZoneColor(metricIndex: 2, background: true),
                child: ExpandablePanel(
                  theme: _expandableThemeData,
                  header: rows[4],
                  collapsed: Container(),
                  expanded: _simplerUi ? null : extras[2],
                  controller: _rowControllers[2],
                ),
              ),
              Divider(height: separatorHeight),
              ColoredBox(
                color: _getTargetHrColor(targetHrState, true),
                child: ExpandablePanel(
                  theme: _expandableThemeData,
                  header: rows[5],
                  collapsed: Container(),
                  expanded: _simplerUi ? null : extras[3],
                  controller: _rowControllers[3],
                ),
              ),
              Divider(height: separatorHeight),
              ExpandablePanel(
                theme: _expandableThemeData,
                header: rows[6],
                collapsed: Container(),
                expanded: _simplerUi ? null : extras[4],
                controller: _rowControllers[4],
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: CircularFabMenu(
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
              } else if (!(_fitnessEquipment?.descriptor?.isFitnessMachine ?? false)) {
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
