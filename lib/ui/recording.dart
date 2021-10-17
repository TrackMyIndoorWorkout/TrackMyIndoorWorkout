import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:overlay_tutorial/overlay_tutorial.dart';
import 'package:pref/pref.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:tuple/tuple.dart';
import 'package:wakelock/wakelock.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/gadgets/fitness_equipment.dart';
import '../devices/gadgets/heart_rate_monitor.dart';
import '../persistence/models/activity.dart';
import '../persistence/models/workout_summary.dart';
import '../persistence/database.dart';
import '../persistence/preferences.dart';
import '../persistence/preferences_spec.dart';
import '../track/calculator.dart';
import '../track/constants.dart';
import '../track/track_painter.dart';
import '../track/tracks.dart';
import '../upload/strava/strava_status_code.dart';
import '../upload/upload_service.dart';
import '../utils/constants.dart';
import '../utils/display.dart';
import '../utils/preferences.dart';
import '../utils/sound.dart';
import '../utils/target_heart_rate.dart';
import '../utils/theme_manager.dart';
import '../utils/time_zone.dart';
import 'models/display_record.dart';
import 'models/row_configuration.dart';
import 'parts/circular_menu.dart';
import 'parts/battery_status.dart';
import 'parts/heart_rate_monitor_pairing.dart';
import 'parts/spin_down.dart';
import 'parts/upload_portal_picker.dart';
import 'activities.dart';

typedef DataFn = List<charts.LineSeries<DisplayRecord, DateTime>> Function();

enum TargetHrState {
  off,
  under,
  inRange,
  over,
}

class RecordingScreen extends StatefulWidget {
  final BluetoothDevice device;
  final DeviceDescriptor descriptor;
  final BluetoothDeviceState initialState;
  final Size size;
  final String sport;

  const RecordingScreen({
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
  late Size size = const Size(0, 0);
  FitnessEquipment? _fitnessEquipment;
  HeartRateMonitor? _heartRateMonitor;
  TrackCalculator? _trackCalculator;
  bool _measuring = false;
  int _pointCount = 0;
  ListQueue<DisplayRecord> _graphData = ListQueue<DisplayRecord>();
  double? _mediaWidth;
  double _sizeDefault = 10.0;
  TextStyle _measurementStyle = const TextStyle();
  TextStyle _unitStyle = const TextStyle();
  Color _chartTextColor = Colors.black;
  TextStyle _chartLabelStyle = const TextStyle(
    fontFamily: FONT_FAMILY,
    fontSize: 11,
  );
  TextStyle _markerStyle = const TextStyle();
  TextStyle _overlayStyle = const TextStyle();
  ExpandableThemeData _expandableThemeData = const ExpandableThemeData(
    hasIcon: !SIMPLER_UI_SLOW_DEFAULT,
    iconColor: Colors.black,
  );
  List<bool> _expandedState = [];
  final List<ExpandableController> _rowControllers = [];
  final List<int> _expandedHeights = [];
  List<PreferencesSpec> _preferencesSpecs = [];

  Activity? _activity;
  AppDatabase _database = Get.find<AppDatabase>();
  bool _si = UNIT_SYSTEM_DEFAULT;
  bool _highRes = DISTANCE_RESOLUTION_DEFAULT;
  bool _simplerUi = SIMPLER_UI_SLOW_DEFAULT;
  bool _instantUpload = INSTANT_UPLOAD_DEFAULT;
  bool _uxDebug = APP_DEBUG_MODE_DEFAULT;

  Timer? _dataGapWatchdog;
  int _dataGapWatchdogTime = DATA_STREAM_GAP_WATCHDOG_DEFAULT;
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
  Tuple2<double, double> _targetHrBounds = const Tuple2(0, 0);
  int? _heartRate;
  Timer? _hrBeepPeriodTimer;
  int _hrBeepPeriod = TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT;
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
  DateTime? _chartTouchInteractionDownTime;
  Offset _chartTouchInteractionPosition = const Offset(0, 0);
  int _chartTouchInteractionIndex = -1;
  ThemeManager _themeManager = Get.find<ThemeManager>();
  bool _isLight = true;
  bool _zoneIndexColoring = false;
  bool _tutorialVisible = false;

  Future<void> _connectOnDemand() async {
    bool success = await _fitnessEquipment?.connectOnDemand() ?? false;
    if (success) {
      final prefService = Get.find<BasePrefService>();
      if (prefService.get<bool>(INSTANT_MEASUREMENT_START_TAG) ??
          INSTANT_MEASUREMENT_START_DEFAULT) {
        await _startMeasurement();
      }
    } else {
      Get.defaultDialog(
        middleText: 'Problem connecting to ${widget.descriptor.fullName}. Aborting...',
        confirm: TextButton(
          child: const Text("Ok"),
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
    await _fitnessEquipment?.additionalSensorsOnDemand();

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
      timeZone: await getTimeZone(),
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
            record.calories?.toString() ?? EMPTY_MEASUREMENT,
            record.power?.toString() ?? EMPTY_MEASUREMENT,
            record.speedOrPaceStringByUnit(_si, widget.descriptor.defaultSport),
            record.cadence?.toString() ?? EMPTY_MEASUREMENT,
            record.heartRate?.toString() ?? EMPTY_MEASUREMENT,
            record.distanceStringByUnit(_si, _highRes),
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

  void _rotateChartHeight(int index) {
    setState(() {
      _expandedHeights[index] = (_expandedHeights[index] + 1) % 3;
      final expandedHeightStr = List<String>.generate(
          _expandedHeights.length, (index) => _expandedHeights[index].toString()).join("");
      final prefService = Get.find<BasePrefService>();
      prefService.set<String>(MEASUREMENT_DETAIL_SIZE_TAG, expandedHeightStr);
    });
  }

  void _onChartTouchInteractionDown(int index, Offset position) {
    _chartTouchInteractionDownTime = DateTime.now();
    _chartTouchInteractionPosition = position;
    _chartTouchInteractionIndex = index;
  }

  void _onChartTouchInteractionUp(int index, Offset position) {
    if (_chartTouchInteractionIndex == index && _chartTouchInteractionDownTime != null) {
      final distanceSquared = (position - _chartTouchInteractionPosition).distanceSquared;
      if (distanceSquared <= 25) {
        Duration pressTime = DateTime.now().difference(_chartTouchInteractionDownTime!);
        if (pressTime.inMilliseconds >= 1300) {
          _rotateChartHeight(index);
        }
      }
    }

    _chartTouchInteractionDownTime = null;
    _chartTouchInteractionIndex = -1;
  }

  Future<void> _initializeHeartRateMonitor() async {
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    final discovered = (await _heartRateMonitor?.discover()) ?? false;
    if (discovered) {
      if (_heartRateMonitor?.device?.id.id !=
          (_fitnessEquipment?.heartRateMonitor?.device?.id.id ?? NOT_AVAILABLE)) {
        _fitnessEquipment?.setHeartRateMonitor(_heartRateMonitor!);
      }
      _heartRateMonitor?.refreshFactors();
      _heartRateMonitor?.attach().then((_) async {
        if (_heartRateMonitor?.subscription != null) {
          _heartRateMonitor?.cancelSubscription();
        }
        _heartRateMonitor?.pumpData((record) async {
          setState(() {
            if ((_heartRate == null || _heartRate == 0) &&
                (record.heartRate != null && record.heartRate! > 0)) {
              _heartRate = record.heartRate;
            }
            _values[4] = record.heartRate?.toString() ?? EMPTY_MEASUREMENT;
            amendZoneToValue(3, record.heartRate ?? 0);
          });
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();

    size = widget.size;

    Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _themeManager = Get.find<ThemeManager>();
    _isLight = !_themeManager.isDark();
    _unitStyle = TextStyle(
      fontFamily: FONT_FAMILY,
      color: _themeManager.getBlueColor(),
    );
    _markerStyle = _themeManager.boldStyle(Get.textTheme.bodyText1!, fontSizeFactor: 1.4);
    _overlayStyle = Get.textTheme.headline6!.copyWith(color: Colors.yellowAccent);
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
        FitnessEquipment(descriptor: widget.descriptor, device: widget.device),
        permanent: true,
      );
    }

    _trackCalculator = TrackCalculator(
      track: TrackDescriptor(
        radiusBoost: TRACK_PAINTING_RADIUS_BOOST,
        lengthFactor: widget.descriptor.lengthFactor,
      ),
    );
    _si = prefService.get<bool>(UNIT_SYSTEM_TAG) ?? UNIT_SYSTEM_DEFAULT;
    _highRes = Get.find<BasePrefService>().get<bool>(DISTANCE_RESOLUTION_TAG) ??
        DISTANCE_RESOLUTION_DEFAULT;
    _simplerUi = prefService.get<bool>(SIMPLER_UI_TAG) ?? SIMPLER_UI_SLOW_DEFAULT;
    _instantUpload = prefService.get<bool>(INSTANT_UPLOAD_TAG) ?? INSTANT_UPLOAD_DEFAULT;
    _pointCount = min(60, size.width ~/ 2);
    final now = DateTime.now();
    _graphData = _simplerUi
        ? ListQueue<DisplayRecord>(0)
        : ListQueue.from(List<DisplayRecord>.generate(
            _pointCount,
            (i) => DisplayRecord.from(
                widget.sport, now.subtract(Duration(seconds: _pointCount - i)))));

    if (widget.sport != ActivityType.Ride) {
      final slowPace = PreferencesSpec.slowSpeeds[PreferencesSpec.sport2Sport(widget.sport)]!;
      widget.descriptor.slowPace = slowPace;
      _fitnessEquipment?.slowPace = slowPace;
    }

    _preferencesSpecs = PreferencesSpec.getPreferencesSpecs(_si, widget.descriptor.defaultSport);
    for (var prefSpec in _preferencesSpecs) {
      prefSpec.calculateBounds(
        0,
        decimalRound(prefSpec.threshold * (prefSpec.zonePercents.last + 15) / 100.0),
        _isLight,
      );
    }

    _dataGapWatchdogTime =
        prefService.get<int>(DATA_STREAM_GAP_WATCHDOG_INT_TAG) ?? DATA_STREAM_GAP_WATCHDOG_DEFAULT;
    _dataGapSoundEffect = prefService.get<String>(DATA_STREAM_GAP_SOUND_EFFECT_TAG) ??
        DATA_STREAM_GAP_SOUND_EFFECT_DEFAULT;

    _targetHrMode =
        prefService.get<String>(TARGET_HEART_RATE_MODE_TAG) ?? TARGET_HEART_RATE_MODE_DEFAULT;
    _targetHrBounds = getTargetHeartRateBounds(_targetHrMode, _preferencesSpecs[3], prefService);
    _targetHrAlerting = false;
    _targetHrAudio =
        prefService.get<bool>(TARGET_HEART_RATE_AUDIO_TAG) ?? TARGET_HEART_RATE_AUDIO_DEFAULT;
    if (_targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio) {
      _hrBeepPeriod = prefService.get<int>(TARGET_HEART_RATE_AUDIO_PERIOD_INT_TAG) ??
          TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT;
    }

    if (_targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio ||
        _dataGapSoundEffect != SOUND_EFFECT_NONE) {
      if (!Get.isRegistered<SoundService>()) {
        Get.put<SoundService>(SoundService(), permanent: true);
      }
    }

    _metricToDataFn = {
      "power": _powerChartData,
      "speed": _speedChartData,
      "cadence": _cadenceChartData,
      "hr": _hRChartData,
    };

    _chartTextColor = _themeManager.getProtagonistColor();
    _chartLabelStyle = TextStyle(
      fontFamily: FONT_FAMILY,
      fontSize: 11,
      color: _chartTextColor,
    );
    _expandableThemeData = ExpandableThemeData(
      hasIcon: !_simplerUi,
      iconColor: _themeManager.getProtagonistColor(),
    );
    _rowConfig = [
      RowConfiguration(
        title: "Calories",
        icon: Icons.whatshot,
        unit: 'cal',
        expandable: false,
      ),
      RowConfiguration(
        title: _preferencesSpecs[0].title,
        icon: _preferencesSpecs[0].icon,
        unit: _preferencesSpecs[0].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        title: _preferencesSpecs[1].title,
        icon: _preferencesSpecs[1].icon,
        unit: _preferencesSpecs[1].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        title: _preferencesSpecs[2].title,
        icon: _preferencesSpecs[2].icon,
        unit: _preferencesSpecs[2].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        title: _preferencesSpecs[3].title,
        icon: _preferencesSpecs[3].icon,
        unit: _preferencesSpecs[3].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        title: "Distance",
        icon: Icons.add_road,
        unit: distanceUnit(_si, _highRes),
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
    _values = [
      EMPTY_MEASUREMENT,
      EMPTY_MEASUREMENT,
      EMPTY_MEASUREMENT,
      EMPTY_MEASUREMENT,
      EMPTY_MEASUREMENT,
      EMPTY_MEASUREMENT,
    ];
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
    _connectOnDemand();
    _database = Get.find<AppDatabase>();
  }

  _preDispose() async {
    _hrBeepPeriodTimer?.cancel();
    _dataGapWatchdog?.cancel();
    _dataGapBeeperTimer?.cancel();
    if (_targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio ||
        _dataGapSoundEffect != SOUND_EFFECT_NONE) {
      Get.find<SoundService>().stopAllSoundEffects();
    }

    try {
      await _heartRateMonitor?.detach();
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    super.dispose();
  }

  Future<void> _dataGapTimeoutHandler() async {
    Get.snackbar("Warning", "Equipment might be disconnected!");

    _fitnessEquipment?.measuring = false;
    _hrBeepPeriodTimer?.cancel();

    if (_dataGapSoundEffect != SOUND_EFFECT_NONE) {
      await _dataTimeoutBeeper();
    }

    await _stopMeasurement(false);

    try {
      await _fitnessEquipment?.disconnect();
    } on PlatformException catch (e, stack) {
      debugPrint("Equipment got turned off?");
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }
  }

  Future<void> _dataTimeoutBeeper() async {
    await Get.find<SoundService>().playDataTimeoutSoundEffect();
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

  _workoutUpload(bool onlyWhenAuthenticated) async {
    if (_activity == null) return;

    if (!await hasInternetConnection()) {
      Get.snackbar("Warning", "No data connection detected");
      return;
    }

    final portalPick = await Get.bottomSheet(
      const UploadPortalPickerBottomSheet(),
      enableDrag: false,
    );

    if (portalPick == null) {
      return;
    }

    UploadService uploadService = UploadService.getInstance(portalPick);
    if (onlyWhenAuthenticated && !await uploadService.hasValidToken()) {
      return;
    }

    if (!await hasInternetConnection()) {
      Get.snackbar("Warning", "No data connection detected");
      return;
    }

    final success = await uploadService.login();
    if (!success) {
      Get.snackbar("Warning", "$portalPick login unsuccessful");
      return;
    }

    final records = await _database.recordDao.findAllActivityRecords(_activity?.id ?? 0);
    final statusCode = await uploadService.upload(_activity!, records);
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

    try {
      await _fitnessEquipment?.detach();
    } on PlatformException catch (e, stack) {
      debugPrint("Equipment got turned off?");
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }

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
        await _workoutUpload(true);
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
        animationDuration: 0,
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
        animationDuration: 0,
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
        animationDuration: 0,
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
        animationDuration: 0,
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
            title: const Text('About to navigate away'),
            content: const Text("The workout in progress will be finished. Are you sure?"),
            actions: [
              TextButton(
                onPressed: () => Get.close(1),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  await _stopMeasurement(true);
                  await _preDispose();
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
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
    if (leaderboard.isEmpty) {
      return 1;
    }

    if (_elapsed == 0) {
      return null;
    }

    final averageSpeed = _elapsed > 0 ? _distance / _elapsed * DeviceDescriptor.ms2kmh : 0.0;
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
    return rank == null ? EMPTY_MEASUREMENT : rank.toString();
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
      return TargetHrState.off;
    }

    if (_heartRate! < _targetHrBounds.item1) {
      return TargetHrState.under;
    } else if (_heartRate! > _targetHrBounds.item2) {
      return TargetHrState.over;
    } else {
      return TargetHrState.inRange;
    }
  }

  Color _getTargetHrColor(TargetHrState hrState, bool background) {
    if (hrState == TargetHrState.off) {
      return _getZoneColor(metricIndex: 3, background: background);
    }

    if (hrState == TargetHrState.under) {
      return background ? _lightBlue : _darkBlue;
    } else if (hrState == TargetHrState.over) {
      return background ? _lightRed : _darkRed;
    } else {
      return background ? _lightGreen : _darkGreen;
    }
  }

  TextStyle _getTargetHrTextStyle(TargetHrState hrState) {
    if (hrState == TargetHrState.off) {
      if (_zoneIndexes[3] == null) {
        return _measurementStyle;
      } else {
        return _measurementStyle.apply(color: _getZoneColor(metricIndex: 3, background: false));
      }
    }

    return _measurementStyle.apply(color: _getTargetHrColor(hrState, false));
  }

  String _getTargetHrText(TargetHrState hrState) {
    if (hrState == TargetHrState.off) {
      return EMPTY_MEASUREMENT;
    }

    if (hrState == TargetHrState.under) {
      return "UNDER!";
    } else if (hrState == TargetHrState.over) {
      return "OVER!";
    } else {
      return "IN RANGE";
    }
  }

  Widget _getTrackMarker(Offset markerPosition, int markerColor, String text, bool self) {
    double radius = thick;
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
    if (leaderboard.isEmpty || rank == null || _trackCalculator == null) {
      return markers;
    }

    final length = leaderboard.length;
    // Preceding dot ahead of the preceding (if any)
    if (rank > 2 && rank - 3 < length) {
      final distance = leaderboard[rank - 3].distanceAtTime(_elapsed);
      final position = _trackCalculator?.trackMarker(distance);
      if (position != null) {
        markers.add(_getTrackMarker(position, 0xFF00FF00, "${rank - 2}", false));
      }
    }

    // Preceding dot (chasing directly) if any
    if (rank > 1 && rank - 2 < length) {
      final distance = leaderboard[rank - 2].distanceAtTime(_elapsed);
      final position = _trackCalculator?.trackMarker(distance);
      if (position != null) {
        markers.add(_getTrackMarker(position, 0xFF00FF00, "${rank - 1}", false));
      }
    }

    // Following dot (following directly) if any
    if (rank - 1 < length) {
      final distance = leaderboard[rank - 1].distanceAtTime(_elapsed);
      final position = _trackCalculator?.trackMarker(distance);
      if (position != null) {
        markers.add(_getTrackMarker(position, 0xFF0000FF, "${rank + 1}", false));
      }
    }

    // Following dot after the follower (if any)
    if (rank < length) {
      final distance = leaderboard[rank].distanceAtTime(_elapsed);
      final position = _trackCalculator?.trackMarker(distance);
      if (position != null) {
        markers.add(_getTrackMarker(position, 0xFF0000FF, "${rank + 2}", false));
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
    final distanceString = distanceByUnit(distance - _distance, _si, _highRes);
    return _getLeaderboardInfoTextCore("#$rank $distanceString", lead);
  }

  Widget _infoForLeaderboard(List<WorkoutSummary> leaderboard, int? rank, String rankString) {
    if (leaderboard.isEmpty || rank == null) {
      return Text(rankString, style: _markerStyle);
    }

    List<Widget> rows = [];
    final length = leaderboard.length;
    // Preceding dot ahead of the preceding (if any)
    if (rank > 2 && rank - 3 < length) {
      final distance = leaderboard[rank - 3].distanceAtTime(_elapsed);
      rows.add(_getLeaderboardInfoText(rank - 2, distance, true));
      rows.add(const Divider(height: 1));
    }

    // Preceding dot (chasing directly) if any
    if (rank > 1 && rank - 2 < length) {
      final distance = leaderboard[rank - 2].distanceAtTime(_elapsed);
      rows.add(_getLeaderboardInfoText(rank - 1, distance, true));
      rows.add(const Divider(height: 1));
    }

    rows.add(_getLeaderboardInfoTextCore(rankString, rank <= 1));

    // Following dot (following directly) if any
    if (rank - 1 < length) {
      rows.add(const Divider(height: 1));
      final distance = leaderboard[rank - 1].distanceAtTime(_elapsed);
      rows.add(_getLeaderboardInfoText(rank + 1, distance, false));
    }

    // Following dot after the follower (if any)
    if (rank < length) {
      rows.add(const Divider(height: 1));
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
    const separatorHeight = 1.0;

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

    for (var entry in _rowConfig.asMap().entries) {
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
          _themeManager.getBlueIconWithHole(
            entry.value.icon,
            _sizeDefault,
            _tutorialVisible,
            entry.value.title,
            0,
          ),
          const Spacer(),
          Text(_values[entry.key], style: measurementStyle),
          SizedBox(
            width: _sizeDefault * (entry.value.expandable ? 1.3 : 2),
            child: Center(
              child: Text(
                entry.value.unit,
                maxLines: 2,
                style: _unitStyle,
              ),
            ),
          ),
        ],
      ));
    }

    var extras = [];
    if (!_simplerUi) {
      for (var entry in _preferencesSpecs.asMap().entries) {
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
        Widget extra = SizedBox(
          width: size.width,
          height: height,
          child: charts.SfCartesianChart(
            primaryXAxis: charts.DateTimeAxis(
              labelStyle: _chartLabelStyle,
              axisLine: charts.AxisLine(color: _chartTextColor),
              majorTickLines: charts.MajorTickLines(color: _chartTextColor),
              minorTickLines: charts.MinorTickLines(color: _chartTextColor),
              majorGridLines: charts.MajorGridLines(color: _chartTextColor),
              minorGridLines: charts.MinorGridLines(color: _chartTextColor),
            ),
            primaryYAxis: charts.NumericAxis(
              plotBands: entry.value.plotBands,
              labelStyle: _chartLabelStyle,
              axisLine: charts.AxisLine(color: _chartTextColor),
              majorTickLines: charts.MajorTickLines(color: _chartTextColor),
              minorTickLines: charts.MinorTickLines(color: _chartTextColor),
              majorGridLines: charts.MajorGridLines(color: _chartTextColor),
              minorGridLines: charts.MinorGridLines(color: _chartTextColor),
            ),
            margin: const EdgeInsets.all(0),
            series: _metricToDataFn[entry.value.metric]!(),
            onChartTouchInteractionDown: (arg) =>
                _onChartTouchInteractionDown(entry.key, arg.position),
            onChartTouchInteractionUp: (arg) => _onChartTouchInteractionUp(entry.key, arg.position),
          ),
        );
        if (entry.value.metric == "hr" && _targetHrMode != TARGET_HEART_RATE_MODE_NONE) {
          int zoneIndex =
              targetHrState == TargetHrState.off ? 0 : entry.value.binIndex(_heartRate ?? 0);
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

          if (widget.descriptor.defaultSport != ActivityType.Ride) {
            extraExtras.add(Text("Speed ${_si ? 'km' : 'mi'}/h"));
          }

          extraExtras.add(extra);
          extra = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: extraExtras,
          );
        }

        extras.add(extra);
      }

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
      child: GestureDetector(
        onTap: _tutorialVisible
            ? () {
                setState(() {
                  _tutorialVisible = false;
                });
              }
            : null,
        child: OverlayTutorialScope(
          enabled: _tutorialVisible,
          overlayColor: Colors.green.withOpacity(.8),
          child: AbsorbPointer(
            absorbing: _tutorialVisible,
            ignoringSemantics: true,
            child: Scaffold(
              appBar: AppBar(
                title: TextOneLine(
                  widget.device.name,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  OverlayTutorialHole(
                    enabled: _tutorialVisible,
                    overlayTutorialEntry: OverlayTutorialRectEntry(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      radius: const Radius.circular(16.0),
                      overlayTutorialHints: <OverlayTutorialWidgetHint>[
                        OverlayTutorialWidgetHint(
                          builder: (context, rect, rRect) {
                            return Positioned(
                              top: rRect.top + 8.0,
                              right: Get.width - rRect.left + 4.0,
                              child: Text("Help Overlay", style: _overlayStyle),
                            );
                          },
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(_measuring ? Icons.stop : Icons.play_arrow),
                      onPressed: () async {
                        if (_measuring) {
                          await _stopMeasurement(false);
                        } else {
                          await _startMeasurement();
                        }
                      },
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    rows[0],
                    const Divider(height: separatorHeight),
                    rows[1],
                    const Divider(height: separatorHeight),
                    ColoredBox(
                      color: _getZoneColor(metricIndex: 0, background: true),
                      child: ExpandablePanel(
                        theme: _expandableThemeData,
                        header: rows[2],
                        collapsed: Container(),
                        expanded: _simplerUi ? Container() : extras[0],
                        controller: _rowControllers[0],
                      ),
                    ),
                    const Divider(height: separatorHeight),
                    ColoredBox(
                      color: _getPaceLightColor(_deviceRank, _sportRank, background: true),
                      child: ExpandablePanel(
                        theme: _expandableThemeData,
                        header: rows[3],
                        collapsed: Container(),
                        expanded: _simplerUi ? Container() : extras[1],
                        controller: _rowControllers[1],
                      ),
                    ),
                    const Divider(height: separatorHeight),
                    ColoredBox(
                      color: _getZoneColor(metricIndex: 2, background: true),
                      child: ExpandablePanel(
                        theme: _expandableThemeData,
                        header: rows[4],
                        collapsed: Container(),
                        expanded: _simplerUi ? Container() : extras[2],
                        controller: _rowControllers[2],
                      ),
                    ),
                    const Divider(height: separatorHeight),
                    ColoredBox(
                      color: _getTargetHrColor(targetHrState, true),
                      child: ExpandablePanel(
                        theme: _expandableThemeData,
                        header: rows[5],
                        collapsed: Container(),
                        expanded: _simplerUi ? Container() : extras[3],
                        controller: _rowControllers[3],
                      ),
                    ),
                    const Divider(height: separatorHeight),
                    ExpandablePanel(
                      theme: _expandableThemeData,
                      header: rows[6],
                      collapsed: Container(),
                      expanded: _simplerUi ? Container() : extras[4],
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
                  _themeManager.getTutorialFab(
                    _tutorialVisible,
                    () async {
                      setState(() {
                        _tutorialVisible = !_tutorialVisible;
                      });
                    },
                  ),
                  _themeManager.getBlueFab(
                      Icons.cloud_upload, true, _tutorialVisible, "Upload Workout", 8, () async {
                    if (_measuring) {
                      Get.snackbar("Warning", "Cannot upload while measurement is under progress");
                      return;
                    }

                    await _workoutUpload(false);
                  }),
                  _themeManager.getBlueFab(
                    Icons.list_alt,
                    true,
                    _tutorialVisible,
                    "Workout List",
                    0,
                    () async {
                      if (_measuring) {
                        Get.snackbar(
                            "Warning", "Cannot navigate while measurement is under progress");
                      } else {
                        final hasLeaderboardData = await _database.hasLeaderboardData();
                        Get.to(() => ActivitiesScreen(hasLeaderboardData: hasLeaderboardData));
                      }
                    },
                  ),
                  _themeManager.getBlueFab(
                    Icons.battery_unknown,
                    true,
                    _tutorialVisible,
                    "Battery & Extras",
                    8,
                    () async {
                      Get.bottomSheet(
                        const BatteryStatusBottomSheet(),
                        enableDrag: false,
                      );
                    },
                  ),
                  _themeManager.getBlueFab(
                    Icons.build,
                    true,
                    _tutorialVisible,
                    "Calibration",
                    0,
                    () async {
                      if (_measuring) {
                        Get.snackbar(
                            "Warning", "Cannot calibrate while measurement is under progress");
                      } else if (!(_fitnessEquipment?.descriptor?.isFitnessMachine ?? false)) {
                        Get.snackbar("Error", "Not compatible with the calibration method");
                      } else {
                        Get.bottomSheet(
                          const SpinDownBottomSheet(),
                          isDismissible: false,
                          enableDrag: false,
                        );
                      }
                    },
                  ),
                  _themeManager.getBlueFab(
                    Icons.favorite,
                    true,
                    _tutorialVisible,
                    "HRM Pairing",
                    -10,
                    () async {
                      await Get.bottomSheet(
                        const HeartRateMonitorPairingBottomSheet(),
                        isDismissible: false,
                        enableDrag: false,
                      );
                      await _initializeHeartRateMonitor();
                    },
                  ),
                  _themeManager.getBlueFab(
                    _measuring ? Icons.stop : Icons.play_arrow,
                    true,
                    _tutorialVisible,
                    "Start / Stop Workout",
                    -20,
                    () async {
                      if (_measuring) {
                        await _stopMeasurement(false);
                      } else {
                        await _startMeasurement();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
