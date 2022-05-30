// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
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
import '../preferences/app_debug_mode.dart';
import '../preferences/data_stream_gap_sound_effect.dart';
import '../preferences/data_stream_gap_watchdog_time.dart';
import '../preferences/distance_resolution.dart';
import '../preferences/generic.dart';
import '../preferences/instant_measurement_start.dart';
import '../preferences/instant_upload.dart';
import '../preferences/lap_counter.dart';
import '../preferences/last_equipment_id.dart';
import '../preferences/leaderboard_and_rank.dart';
import '../preferences/measurement_font_size_adjust.dart';
import '../preferences/measurement_ui_state.dart';
import '../preferences/metric_spec.dart';
import '../preferences/moving_or_elapsed_time.dart';
import '../preferences/palette_spec.dart';
import '../preferences/show_pacer.dart';
import '../preferences/simpler_ui.dart';
import '../preferences/speed_spec.dart';
import '../preferences/sport_spec.dart';
import '../preferences/sound_effects.dart';
import '../preferences/target_heart_rate.dart';
import '../preferences/two_column_layout.dart';
import '../preferences/unit_system.dart';
import '../preferences/use_heart_rate_based_calorie_counting.dart';
import '../preferences/workout_mode.dart';
import '../preferences/zone_index_display_coloring.dart';
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
  RecordingState createState() => RecordingState();
}

class RecordingState extends State<RecordingScreen> {
  static const double _markerStyleSizeAdjust = 1.4;
  static const double _markerStyleSmallSizeAdjust = 0.9;
  static const int _unlockChoices = 6;

  late Size size = const Size(0, 0);
  FitnessEquipment? _fitnessEquipment;
  HeartRateMonitor? _heartRateMonitor;
  TrackCalculator? _trackCalculator;
  PaletteSpec? _paletteSpec;
  double _trackLength = trackLength;
  bool _measuring = false;
  int _pointCount = 0;
  ListQueue<DisplayRecord> _graphData = ListQueue<DisplayRecord>();
  double _mediaSizeMin = 0;
  double _mediaHeight = 0;
  double _mediaWidth = 0;
  double _sizeDefault = 10.0;
  double _sizeAdjust = 1.0;
  bool _landscape = false;
  TextStyle _measurementStyle = const TextStyle();
  TextStyle _unitStyle = const TextStyle();
  Color _chartTextColor = Colors.black;
  TextStyle _chartLabelStyle = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
  );
  TextStyle _markerStyle = const TextStyle();
  TextStyle _markerStyleSmall = const TextStyle();
  TextStyle _overlayStyle = const TextStyle();
  ExpandableThemeData _expandableThemeData = const ExpandableThemeData(
    hasIcon: !simplerUiSlowDefault,
    iconColor: Colors.black,
  );
  List<bool> _expandedState = [];
  final List<ExpandableController> _rowControllers = [];
  final List<int> _expandedHeights = [];
  List<MetricSpec> _preferencesSpecs = [];

  Activity? _activity;
  AppDatabase _database = Get.find<AppDatabase>();
  bool _si = unitSystemDefault;
  bool _highRes = distanceResolutionDefault;
  bool _simplerUi = simplerUiSlowDefault;
  bool _twoColumnLayout = twoColumnLayoutDefault;
  bool _instantUpload = instantUploadDefault;
  bool _uxDebug = appDebugModeDefault;
  bool _movingOrElapsedTime = movingOrElapsedTimeDefault;

  bool _circuitWorkout = false;
  Timer? _dataGapWatchdog;
  int _dataGapWatchdogTime = dataStreamGapWatchdogDefault;
  String _dataGapSoundEffect = dataStreamGapSoundEffectDefault;
  Timer? _dataGapBeeperTimer;

  List<DisplayRecord> get graphData => _graphData.toList();
  Map<String, DataFn> _metricToDataFn = {};
  List<RowConfiguration> _rowConfig = [];
  List<String> _values = [];
  List<int?> _zoneIndexes = [];
  double _distance = 0.0;
  int _elapsed = 0;
  int _movingTime = 0;

  String _targetHrMode = targetHeartRateModeDefault;
  Tuple2<double, double> _targetHrBounds = const Tuple2(0, 0);
  int? _heartRate;
  Timer? _hrBeepPeriodTimer;
  int _hrBeepPeriod = targetHeartRateAudioPeriodDefault;
  bool _targetHrAudio = targetHeartRateAudioDefault;
  bool _targetHrAlerting = false;
  bool _hrBasedCalorieCounting = useHeartRateBasedCalorieCountingDefault;
  bool _leaderboardFeature = leaderboardFeatureDefault;
  bool _rankingForSportOrDevice = rankingForSportOrDeviceDefault;
  List<WorkoutSummary> _leaderboard = [];
  int _selfRank = 0;
  double _selfAvgSpeed = 0.0;
  List<String> _selfRankString = [];
  bool _rankRibbonVisualization = rankRibbonVisualizationDefault;
  bool _rankTrackVisualization = rankTrackVisualizationDefault;
  bool _rankInfoOnTrack = rankInfoOnTrackDefault;
  bool _displayLapCounter = displayLapCounterDefault;
  bool _avgSpeedOnTrack = avgSpeedOnTrackDefault;
  bool _showPacer = showPacerDefault;
  WorkoutSummary? _pacerWorkout;
  final _averageSpeeds = ListQueue<double>();
  double _averageSpeedSum = 0.0;
  int _rankInfoColumnCount = 0;
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
  int _lapCount = 0;
  bool _isLocked = false;
  int _unlockButtonIndex = 0;
  final Random _rng = Random();
  final List<GlobalKey> _unlockKeys = [];
  final GlobalKey<CircularFabMenuState> _fabKey = GlobalKey();
  int _unlockKey = -2;

  Future<void> _connectOnDemand() async {
    bool success = await _fitnessEquipment?.connectOnDemand() ?? false;
    if (success) {
      final prefService = Get.find<BasePrefService>();
      if (prefService.get<bool>(instantMeasurementStartTag) ?? instantMeasurementStartDefault) {
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
      _values[valueIndex + 1] += " Z${zoneIndex + 1}";
      if (_zoneIndexColoring) {
        _zoneIndexes[valueIndex] = zoneIndex;
      }
    }
  }

  Future<void> _startMeasurement() async {
    await _fitnessEquipment?.additionalSensorsOnDemand();

    final now = DateTime.now();
    // TODO #249
    _activity = Activity(
      fourCC: widget.descriptor.fourCC,
      deviceName: widget.device.name,
      deviceId: widget.device.id.id,
      hrmId: _fitnessEquipment?.heartRateMonitor?.device?.id.id ?? "",
      start: now.millisecondsSinceEpoch,
      startDateTime: now,
      sport: widget.descriptor.defaultSport,
      powerFactor: _fitnessEquipment?.powerFactor ?? 1.0,
      calorieFactor: _fitnessEquipment?.calorieFactor ?? 1.0,
      hrCalorieFactor: _fitnessEquipment?.hrCalorieFactor ?? 1.0,
      hrmCalorieFactor: _fitnessEquipment?.hrmCalorieFactor ?? 1.0,
      hrBasedCalories: _hrBasedCalorieCounting,
      timeZone: await getTimeZone(),
    );
    if (!_uxDebug) {
      final id = await _database.activityDao.insertActivity(_activity!);
      _activity!.id = id;
    }

    if (_leaderboardFeature || _showPacer) {
      _selfRank = 0;
      _selfAvgSpeed = 0.0;
      _selfRankString = [];
      _averageSpeeds.clear();
      _averageSpeedSum = 0.0;
      if (_leaderboardFeature) {
        _leaderboard = _rankingForSportOrDevice
            ? await _database.workoutSummaryDao
                .findAllWorkoutSummariesBySport(widget.descriptor.defaultSport)
            : await _database.workoutSummaryDao
                .findAllWorkoutSummariesByDevice(widget.device.id.id);

        if (_showPacer && _pacerWorkout != null) {
          int insertionPoint = 0;
          while (insertionPoint < _leaderboard.length &&
              _leaderboard[insertionPoint].speed > _pacerWorkout!.speed) {
            insertionPoint++;
          }

          if (insertionPoint < _leaderboard.length) {
            _leaderboard.insert(insertionPoint, _pacerWorkout!);
          } else {
            _leaderboard.add(_pacerWorkout!);
          }
        }
      } else if (_pacerWorkout != null) {
        _leaderboard = [_pacerWorkout!];
      }
    }

    _fitnessEquipment?.setActivity(_activity!);

    await _fitnessEquipment?.attach();
    setState(() {
      _elapsed = 0;
      _movingTime = 0;
      _distance = 0.0;
      _lapCount = 0;
      _measuring = true;
      _zoneIndexes = [null, null, null, null];
    });
    _fitnessEquipment?.measuring = true;
    _fitnessEquipment?.startWorkout();

    _fitnessEquipment?.pumpData((record) async {
      _dataGapWatchdog?.cancel();
      _dataGapBeeperTimer?.cancel();
      if (_dataGapWatchdogTime > 0 && !_circuitWorkout) {
        _dataGapWatchdog = Timer(
          Duration(seconds: _dataGapWatchdogTime),
          _dataGapTimeoutHandler,
        );
      }

      final workoutState = _fitnessEquipment?.workoutState ?? WorkoutState.waitingForFirstMove;
      if (_measuring &&
          (workoutState == WorkoutState.moving || workoutState == WorkoutState.justStopped) &&
          (_fitnessEquipment?.measuring ?? false)) {
        if (!_uxDebug) {
          await _database.recordDao.insertRecord(record);
        }

        setState(() {
          if (!_simplerUi) {
            _graphData.add(record.display());
            if (_pointCount > 0 && _graphData.length > _pointCount) {
              _graphData.removeFirst();
            }
          }

          _distance = record.distance ?? 0.0;
          if (_displayLapCounter) {
            _lapCount = (_distance / _trackLength).floor();
          }

          _elapsed = record.elapsed ?? 0;
          _movingTime = record.movingTime.round();
          if (record.heartRate != null &&
              (record.heartRate! > 0 || _heartRate == null || _heartRate == 0)) {
            _heartRate = record.heartRate;
          }

          if (_leaderboardFeature || _showPacer) {
            final selfRankTuple = _getSelfRank();
            _selfRank = selfRankTuple.item1;
            _selfAvgSpeed = selfRankTuple.item2;
            _selfRankString = _getSelfRankString();
          }

          _values = [
            record.calories?.toString() ?? emptyMeasurement,
            record.power?.toString() ?? emptyMeasurement,
            record.speedOrPaceStringByUnit(_si, widget.descriptor.defaultSport),
            record.cadence?.toString() ?? emptyMeasurement,
            record.heartRate?.toString() ?? emptyMeasurement,
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
      applyExpandedStates(_expandedState);
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
      applyDetailSizes(_expandedHeights);
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

  Future<String> _initializeHeartRateMonitor() async {
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    final discovered = (await _heartRateMonitor?.discover()) ?? false;
    if (discovered) {
      if (_heartRateMonitor?.device?.id.id !=
          (_fitnessEquipment?.heartRateMonitor?.device?.id.id ?? notAvailable)) {
        _fitnessEquipment?.setHeartRateMonitor(_heartRateMonitor!);
      }
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
            _values[4] = record.heartRate?.toString() ?? emptyMeasurement;
            amendZoneToValue(3, record.heartRate ?? 0);
          });
        });
      });

      return _heartRateMonitor?.device?.id.id ?? "";
    }

    return "";
  }

  @override
  void initState() {
    super.initState();

    size = widget.size;

    Wakelock.enable();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _themeManager = Get.find<ThemeManager>();
    _isLight = !_themeManager.isDark();
    _unitStyle = TextStyle(
      fontFamily: fontFamily,
      color: _themeManager.getBlueColor(),
    );
    final prefService = Get.find<BasePrefService>();
    final sizeAdjustInt =
        prefService.get<int>(measurementFontSizeAdjustTag) ?? measurementFontSizeAdjustDefault;
    if (sizeAdjustInt != 100) {
      _sizeAdjust = sizeAdjustInt / 100.0;
    }
    _markerStyle =
        _themeManager.boldStyle(Get.textTheme.bodyText1!, fontSizeFactor: _markerStyleSizeAdjust);
    _markerStyleSmall = _themeManager.boldStyle(Get.textTheme.bodyText1!,
        fontSizeFactor: _markerStyleSmallSizeAdjust);
    _overlayStyle = Get.textTheme.headline6!.copyWith(color: Colors.yellowAccent);
    prefService.set<String>(
      lastEquipmentIdTagPrefix + SportSpec.sport2Sport(widget.sport),
      widget.device.id.id,
    );
    if (Get.isRegistered<FitnessEquipment>()) {
      _fitnessEquipment = Get.find<FitnessEquipment>();
      _fitnessEquipment?.descriptor = widget.descriptor;
      _fitnessEquipment?.refreshFactors();
    } else {
      _fitnessEquipment = Get.put<FitnessEquipment>(
        FitnessEquipment(descriptor: widget.descriptor, device: widget.device),
        permanent: true,
      );
    }

    _trackCalculator = TrackCalculator(
      track: TrackDescriptor(
        radiusBoost: trackPaintingRadiusBoost,
        lengthFactor: widget.descriptor.lengthFactor,
      ),
    );
    _trackLength = trackLength * widget.descriptor.lengthFactor;
    _si = prefService.get<bool>(unitSystemTag) ?? unitSystemDefault;
    _highRes = prefService.get<bool>(distanceResolutionTag) ?? distanceResolutionDefault;
    _simplerUi = prefService.get<bool>(simplerUiTag) ?? simplerUiSlowDefault;
    _twoColumnLayout = prefService.get<bool>(twoColumnLayoutTag) ?? twoColumnLayoutDefault;
    _movingOrElapsedTime =
        prefService.get<bool>(movingOrElapsedTimeTag) ?? movingOrElapsedTimeDefault;
    _instantUpload = prefService.get<bool>(instantUploadTag) ?? instantUploadDefault;
    _pointCount = min(60, size.width ~/ 2);
    final now = DateTime.now();
    _graphData = _simplerUi
        ? ListQueue<DisplayRecord>(0)
        : ListQueue.from(List<DisplayRecord>.generate(
            _pointCount,
            (i) => DisplayRecord.from(
                widget.sport, now.subtract(Duration(seconds: _pointCount - i)))));

    if (widget.sport != ActivityType.ride) {
      final slowPace = SpeedSpec.slowSpeeds[SportSpec.sport2Sport(widget.sport)]!;
      widget.descriptor.slowPace = slowPace;
      _fitnessEquipment?.slowPace = slowPace;
    }
    _showPacer = prefService.get<bool>(showPacerTag) ?? showPacerDefault;
    if (_showPacer) {
      final pacerSpeed = SpeedSpec.pacerSpeeds[SportSpec.sport2Sport(widget.sport)]!;
      _pacerWorkout = WorkoutSummary.getPacerWorkout(pacerSpeed, widget.sport);
    }

    _paletteSpec = PaletteSpec.getInstance(prefService);

    _preferencesSpecs = MetricSpec.getPreferencesSpecs(_si, widget.descriptor.defaultSport);
    for (var prefSpec in _preferencesSpecs) {
      prefSpec.calculateBounds(
        0,
        decimalRound(prefSpec.threshold * (prefSpec.zonePercents.last + 15) / 100.0),
        _isLight,
        _paletteSpec!,
      );
    }

    _circuitWorkout = (prefService.get<int>(workoutModeTag) ?? workoutModeDefault) == workoutModeCircuit;
    _dataGapWatchdogTime =
        prefService.get<int>(dataStreamGapWatchdogIntTag) ?? dataStreamGapWatchdogDefault;
    _dataGapSoundEffect =
        prefService.get<String>(dataStreamGapSoundEffectTag) ?? dataStreamGapSoundEffectDefault;

    _targetHrMode = prefService.get<String>(targetHeartRateModeTag) ?? targetHeartRateModeDefault;
    _targetHrBounds = getTargetHeartRateBounds(_targetHrMode, _preferencesSpecs[3], prefService);
    _targetHrAlerting = false;
    _targetHrAudio = prefService.get<bool>(targetHeartRateAudioTag) ?? targetHeartRateAudioDefault;
    if (_targetHrMode != targetHeartRateModeNone && _targetHrAudio) {
      _hrBeepPeriod = prefService.get<int>(targetHeartRateAudioPeriodIntTag) ??
          targetHeartRateAudioPeriodDefault;
    }

    if (_targetHrMode != targetHeartRateModeNone && _targetHrAudio ||
        _dataGapSoundEffect != soundEffectNone) {
      if (!Get.isRegistered<SoundService>()) {
        Get.put<SoundService>(SoundService(), permanent: true);
      }
    }

    _hrBasedCalorieCounting = prefService.get<bool>(useHeartRateBasedCalorieCountingTag) ??
        useHeartRateBasedCalorieCountingDefault;

    _metricToDataFn = {
      "power": _powerChartData,
      "speed": _speedChartData,
      "cadence": _cadenceChartData,
      "hr": _hRChartData,
    };

    _chartTextColor = _themeManager.getProtagonistColor();
    _chartLabelStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 11 * _sizeAdjust,
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
    final expandedStateStr =
        prefService.get<String>(measurementPanelsExpandedTag) ?? measurementPanelsExpandedDefault;
    final expandedHeightStr =
        prefService.get<String>(measurementDetailSizeTag) ?? measurementDetailSizeDefault;
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

    _uxDebug = prefService.get<bool>(appDebugModeTag) ?? appDebugModeDefault;
    _fitnessEquipment?.measuring = false;
    _values = [
      emptyMeasurement,
      emptyMeasurement,
      emptyMeasurement,
      emptyMeasurement,
      emptyMeasurement,
      emptyMeasurement,
    ];
    _zoneIndexes = [null, null, null, null];

    _leaderboardFeature = prefService.get<bool>(leaderboardFeatureTag) ?? leaderboardFeatureDefault;
    _rankRibbonVisualization =
        prefService.get<bool>(rankRibbonVisualizationTag) ?? rankRibbonVisualizationDefault;
    _rankingForSportOrDevice =
        prefService.get<bool>(rankingForSportOrDeviceTag) ?? rankingForSportOrDeviceDefault;
    _leaderboard = [];
    _selfRankString = [];
    _rankTrackVisualization =
        prefService.get<bool>(rankTrackVisualizationTag) ?? rankTrackVisualizationDefault;
    _rankInfoOnTrack = prefService.get<bool>(rankInfoOnTrackTag) ?? rankInfoOnTrackDefault;
    _displayLapCounter = prefService.get<bool>(displayLapCounterTag) ?? displayLapCounterDefault;
    _avgSpeedOnTrack = prefService.get<bool>(avgSpeedOnTrackTag) ?? avgSpeedOnTrackDefault;

    _rankInfoColumnCount = 2;
    if (_displayLapCounter) {
      _rankInfoColumnCount += 1;
    }

    if (_avgSpeedOnTrack) {
      _rankInfoColumnCount += 1;
    }

    final isLight = !_themeManager.isDark();
    _darkRed = isLight ? Colors.red.shade900 : Colors.redAccent.shade100;
    _darkGreen = isLight ? Colors.green.shade900 : Colors.lightGreenAccent.shade100;
    _darkBlue = isLight ? Colors.indigo.shade900 : Colors.lightBlueAccent.shade100;
    _lightRed = isLight ? Colors.redAccent.shade100 : Colors.red.shade900;
    _lightGreen = isLight ? Colors.lightGreenAccent.shade100 : Colors.green.shade900;
    _lightBlue = isLight ? Colors.lightBlueAccent.shade100 : Colors.indigo.shade900;

    _zoneIndexColoring =
        prefService.get<bool>(zoneIndexDisplayColoringTag) ?? zoneIndexDisplayColoringDefault;

    _initializeHeartRateMonitor();
    _connectOnDemand();
    _database = Get.find<AppDatabase>();
    _isLocked = false;
    _unlockButtonIndex = 0;
    if (_unlockKeys.isEmpty) {
      _unlockKeys.addAll([for (var i = 0; i < _unlockChoices; ++i) GlobalKey()]);
    }
    _unlockKey = -2;
  }

  _preDispose() async {
    _hrBeepPeriodTimer?.cancel();
    _dataGapWatchdog?.cancel();
    _dataGapBeeperTimer?.cancel();
    if (_targetHrMode != targetHeartRateModeNone && _targetHrAudio ||
        _dataGapSoundEffect != soundEffectNone) {
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
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    super.dispose();
  }

  Future<void> _dataGapTimeoutHandler() async {
    Get.snackbar("Warning", "Equipment might be disconnected!");

    _fitnessEquipment?.measuring = false;
    _hrBeepPeriodTimer?.cancel();

    if (_dataGapSoundEffect != soundEffectNone) {
      _dataTimeoutBeeper();
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
    if (_measuring && _dataGapSoundEffect != soundEffectNone && _dataGapWatchdogTime >= 2) {
      _dataGapBeeperTimer = Timer(Duration(seconds: _dataGapWatchdogTime), _dataTimeoutBeeper);
    }
  }

  Future<void> _hrBeeper() async {
    Get.find<SoundService>().playTargetHrSoundEffect();
    if (_measuring &&
        _targetHrMode != targetHeartRateModeNone &&
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
      Get.snackbar("Warning", "No data connection detected, try again later!");
      return;
    }

    Get.bottomSheet(
      UploadPortalPickerBottomSheet(activity: _activity!),
      enableDrag: false,
    );
  }

  _stopMeasurement(bool quick) async {
    _fitnessEquipment?.measuring = false;
    if (!_measuring || _activity == null) return;

    _hrBeepPeriodTimer?.cancel();
    _dataGapWatchdog?.cancel();
    _dataGapBeeperTimer?.cancel();
    if (_targetHrMode != targetHeartRateModeNone && _targetHrAudio ||
        _dataGapSoundEffect != soundEffectNone) {
      Get.find<SoundService>().stopAllSoundEffects();
    }

    setState(() {
      _measuring = false;
    });

    try {
      _fitnessEquipment?.detach();
    } on PlatformException catch (e, stack) {
      debugPrint("Equipment got turned off?");
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }

    final last = _fitnessEquipment?.lastRecord;
    _activity!.finish(
      last?.distance,
      last?.elapsed,
      last?.calories,
      last?.movingTime ?? 0,
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
    if (!_measuring || _circuitWorkout) {
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

    if (background) {
      return _paletteSpec?.bgColorByBin(
              _zoneIndexes[metricIndex]!, _isLight, _preferencesSpecs[metricIndex]) ??
          PaletteSpec?.bgColorByBinDefault(
              _zoneIndexes[metricIndex]!, _isLight, _preferencesSpecs[metricIndex]);
    }

    return _paletteSpec?.fgColorByBin(
            _zoneIndexes[metricIndex]!, _isLight, _preferencesSpecs[metricIndex]) ??
        PaletteSpec?.fgColorByBinDefault(
            _zoneIndexes[metricIndex]!, _isLight, _preferencesSpecs[metricIndex]);
  }

  Tuple2<int, double> _getRank(List<WorkoutSummary> leaderboard) {
    if (_elapsed == 0) {
      return const Tuple2<int, double>(0, 0.0);
    }

    // #252 moving is in milliseconds, so 1000 multiplier is needed
    // (but for now we use elapsed because other parts use elapsed as well)
    double averageSpeed = 0.0;
    if (_elapsed > 0) {
      // #236 smooth signal of average speeds by average over a rolling window
      averageSpeed = _distance / _elapsed * DeviceDescriptor.ms2kmh;
      if (_averageSpeeds.isEmpty) {
        _averageSpeeds.addAll(
            [for (var i = 0; i < averageSpeedSmoothingWindowSizeDefault; ++i) averageSpeed]);
        _averageSpeedSum = averageSpeed * averageSpeedSmoothingWindowSizeDefault;
      } else {
        _averageSpeeds.add(averageSpeed);
        _averageSpeedSum += averageSpeed;
        _averageSpeedSum -= _averageSpeeds.first;
        _averageSpeeds.removeFirst();
        averageSpeed = _averageSpeedSum / _averageSpeeds.length;
      }
    }

    var rank = 1;
    for (final entry in leaderboard) {
      if (averageSpeed > entry.speed) {
        return Tuple2<int, double>(rank, averageSpeed);
      }

      rank += 1;
    }

    return Tuple2<int, double>(rank, averageSpeed);
  }

  String _getRankString(int rank, List<WorkoutSummary> leaderboard) {
    return rank == 0 ? emptyMeasurement : rank.toString();
  }

  Tuple2<int, double> _getSelfRank() {
    if (!_leaderboardFeature && !_showPacer) return const Tuple2<int, double>(0, 0.0);

    return _getRank(_leaderboard);
  }

  List<String> _getSelfRankString() {
    return ["#${_getRankString(_selfRank, _leaderboard)}", "(Self)"];
  }

  Color _getPaceLightColor(int selfRank, {required bool background}) {
    if (!_leaderboardFeature || selfRank == 0) {
      return background ? Colors.transparent : _themeManager.getBlueColor();
    }

    if (selfRank <= 1) {
      return background ? _lightGreen : _darkGreen;
    }
    return background ? _lightBlue : _darkBlue;
  }

  TextStyle _getPaceLightTextStyle(int selfRank) {
    if (!_leaderboardFeature) {
      return _measurementStyle;
    }

    return _measurementStyle.apply(color: _getPaceLightColor(selfRank, background: false));
  }

  TargetHrState _getTargetHrState() {
    if (_heartRate == null || _heartRate == 0 || _targetHrMode == targetHeartRateModeNone) {
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
      return emptyMeasurement;
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
        child: Center(child: Text(text, style: text.length > 2 ? _markerStyleSmall : _markerStyle)),
      ),
    );
  }

  bool _addLeaderboardTrackMarker(
    int markerColor,
    WorkoutSummary workoutSummary,
    int rank,
    List<Widget> markers,
  ) {
    final distance = workoutSummary.distanceAtTime(_elapsed);
    final position = _trackCalculator?.trackMarker(distance);
    final isPacer = workoutSummary.isPacer;
    if (position != null) {
      markers.add(_getTrackMarker(
        position,
        isPacer ? pacerColor : markerColor,
        isPacer ? pacerText : "$rank",
        false,
      ));
    }

    return isPacer;
  }

  List<Widget> _markersForLeaderboard(List<WorkoutSummary> leaderboard, int rank) {
    List<Widget> markers = [];
    if (leaderboard.isEmpty || rank == 0 || _trackCalculator == null) {
      return markers;
    }

    bool wasPacer = false;
    if (_rankTrackVisualization) {
      final length = leaderboard.length;
      // Preceding dot ahead of the preceding (if any)
      if (rank > 2 && rank - 3 < length) {
        final isPacer =
            _addLeaderboardTrackMarker(0xFF00FF00, leaderboard[rank - 3], rank - 2, markers);
        wasPacer |= isPacer;
      }

      // Preceding dot (chasing directly) if any
      if (rank > 1 && rank - 2 < length) {
        final isPacer =
            _addLeaderboardTrackMarker(0xFF00FF00, leaderboard[rank - 2], rank - 1, markers);
        wasPacer |= isPacer;
      }

      // Following dot (following directly) if any
      if (rank - 1 < length) {
        final isPacer =
            _addLeaderboardTrackMarker(0xFF0000FF, leaderboard[rank - 1], rank + 1, markers);
        wasPacer |= isPacer;
      }

      // Following dot after the follower (if any)
      if (rank < length) {
        final isPacer =
            _addLeaderboardTrackMarker(0xFF0000FF, leaderboard[rank], rank + 2, markers);
        wasPacer |= isPacer;
      }
    }

    if (!wasPacer && _showPacer && _pacerWorkout != null) {
      final distance = _pacerWorkout!.distanceAtTime(_elapsed);
      final position = _trackCalculator?.trackMarker(distance);
      if (position != null) {
        markers.add(_getTrackMarker(position, pacerColor, pacerText, false));
      }
    }

    return markers;
  }

  Widget _getLeaderboardInfoTextCellCore(String text, Color bgColor) {
    return ColoredBox(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
        child: Text(text, style: _markerStyleSmall),
      ),
    );
  }

  List<Widget> _getPacerInfoText() {
    List<Widget> widgets = [];
    if (!_showPacer || _pacerWorkout == null) {
      return widgets;
    }

    widgets.add(_getLeaderboardInfoTextCellCore("Pacer", Colors.grey));
    final distance = _pacerWorkout!.distanceAtTime(_elapsed);

    if (_displayLapCounter) {
      final lapCount = (distance / _trackLength).floor();
      widgets.add(_getLeaderboardInfoTextCellCore("L$lapCount", Colors.grey));
    }

    final distanceString = distanceByUnit(distance - _distance, _si, _highRes, autoRes: true);
    widgets.add(_getLeaderboardInfoTextCellCore(distanceString, Colors.grey));
    if (_avgSpeedOnTrack) {
      final speedString = _pacerWorkout!.speedString(_si, widget.descriptor.slowPace);

      widgets.add(_getLeaderboardInfoTextCellCore(speedString, Colors.grey));
    }

    return widgets;
  }

  Widget _getLeaderboardInfoTextCell(String text, bool lead) {
    final bgColor = lead ? _lightGreen : _lightBlue;
    return _getLeaderboardInfoTextCellCore(text, bgColor);
  }

  List<Widget> _getLeaderboardInfoText(int rank, double distance, String speed, bool lead) {
    List<Widget> widgets = [];
    widgets.add(_getLeaderboardInfoTextCell("#$rank", lead));
    if (_displayLapCounter) {
      final lapCount = (distance / _trackLength).floor();
      widgets.add(_getLeaderboardInfoTextCell("L$lapCount", lead));
    }

    final distanceString = distanceByUnit(distance - _distance, _si, _highRes, autoRes: true);
    widgets.add(_getLeaderboardInfoTextCell(distanceString, lead));
    if (_avgSpeedOnTrack) {
      widgets.add(_getLeaderboardInfoTextCell(speed, lead));
    }

    return widgets;
  }

  Widget _infoForLeaderboard(List<WorkoutSummary> leaderboard, int rank, List<String> rankString) {
    if (leaderboard.isEmpty || rank == 0) {
      var rankStringEx = rankString.join(" ");
      if (_displayLapCounter) {
        rankStringEx += " L$_lapCount";
      }
      return Text(rankStringEx, style: _markerStyle);
    }

    String areaRow = "nav content";
    if (_displayLapCounter) {
      areaRow += " content";
    }

    if (_avgSpeedOnTrack) {
      areaRow += " content";
    }

    int rowCount = 0;
    List<Widget> cells = [];
    final length = leaderboard.length;
    bool wasPacer = false;
    // Preceding dot ahead of the preceding (if any)
    if (rank > 2 && rank - 3 < length) {
      final isPacer = leaderboard[rank - 3].isPacer;
      if (_showPacer && !isPacer && _pacerWorkout!.speed > leaderboard[rank - 3].speed) {
        cells.addAll(_getPacerInfoText());
        rowCount++;
        wasPacer = true;
      }

      final distance = leaderboard[rank - 3].distanceAtTime(_elapsed);
      final speed = _avgSpeedOnTrack
          ? leaderboard[rank - 3].speedString(_si, widget.descriptor.slowPace)
          : "";
      cells.addAll(
          isPacer ? _getPacerInfoText() : _getLeaderboardInfoText(rank - 2, distance, speed, true));
      rowCount++;
      wasPacer |= isPacer;
    }

    // Preceding dot (chasing directly) if any
    if (rank > 1 && rank - 2 < length) {
      final isPacer = leaderboard[rank - 2].isPacer;
      final distance = leaderboard[rank - 2].distanceAtTime(_elapsed);
      final speed = _avgSpeedOnTrack
          ? leaderboard[rank - 2].speedString(_si, widget.descriptor.slowPace)
          : "";
      cells.addAll(
          isPacer ? _getPacerInfoText() : _getLeaderboardInfoText(rank - 1, distance, speed, true));
      rowCount++;
      wasPacer |= isPacer;
    }

    // Self section
    final lead = rank <= 1;
    cells.add(_getLeaderboardInfoTextCell(rankString[0], lead));
    if (_displayLapCounter) {
      cells.add(_getLeaderboardInfoTextCell("L$_lapCount", lead));
    }

    cells.add(_getLeaderboardInfoTextCell(rankString[1], lead));
    if (_avgSpeedOnTrack) {
      final avgSpeedString = WorkoutSummary.speedStringStatic(
          _si, _selfAvgSpeed, widget.descriptor.slowPace, widget.sport);
      cells.add(_getLeaderboardInfoTextCell(avgSpeedString, lead));
    }

    rowCount++;

    // Following dot (following directly) if any
    if (rank - 1 < length) {
      final isPacer = leaderboard[rank - 1].isPacer;
      final distance = leaderboard[rank - 1].distanceAtTime(_elapsed);
      final speed = _avgSpeedOnTrack
          ? leaderboard[rank - 1].speedString(_si, widget.descriptor.slowPace)
          : "";
      cells.addAll(isPacer
          ? _getPacerInfoText()
          : _getLeaderboardInfoText(rank + 1, distance, speed, false));
      rowCount++;
      wasPacer |= isPacer;
    }

    // Following dot after the follower (if any)
    if (rank < length) {
      final isPacer = leaderboard[rank].isPacer;
      final distance = leaderboard[rank].distanceAtTime(_elapsed);
      final speed =
          _avgSpeedOnTrack ? leaderboard[rank].speedString(_si, widget.descriptor.slowPace) : "";
      cells.addAll(isPacer
          ? _getPacerInfoText()
          : _getLeaderboardInfoText(rank + 2, distance, speed, false));
      rowCount++;
      wasPacer |= isPacer;
    }

    if (_showPacer && !wasPacer && _pacerWorkout!.speed < leaderboard[rank].speed) {
      cells.addAll(_getPacerInfoText());
      rowCount++;
      wasPacer = true;
    }

    final innerWidth = _trackCalculator!.trackSize!.width -
        2 * (_trackCalculator!.trackOffset!.dx + _trackCalculator!.trackRadius!);
    const cellHeight = (thick * _markerStyleSmallSizeAdjust / _markerStyleSizeAdjust) * 2;
    final innerHeight = (cellHeight + 1) * rowCount;

    List<TrackSize> rowSizes = [for (int i = 0; i < rowCount; i++) cellHeight.px];
    String areaSpec = [for (int i = 0; i < rowCount; i++) areaRow].join("\n");
    List<TrackSize> columnSpec = [for (int i = 0; i < _rankInfoColumnCount; i++) auto];

    return SizedBox(
      width: innerWidth,
      height: innerHeight,
      child: LayoutGrid(
        areas: areaSpec,
        columnSizes: columnSpec,
        rowSizes: rowSizes,
        columnGap: 1,
        rowGap: 1,
        children: cells,
      ),
    );
  }

  bool hitTest(GlobalKey globalKey, Offset globalPosition) {
    final RenderObject? renderObject = globalKey.currentContext?.findRenderObject();
    if (renderObject != null && renderObject is RenderBox) {
      final RenderBox renderBox = renderObject;
      final pos = renderBox.globalToLocal(globalPosition);
      final hitTestResult = BoxHitTestResult();
      return renderBox.hitTest(hitTestResult, position: pos);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    const separatorHeight = 1.0;

    final size = Get.mediaQuery.size;
    if (size.width != _mediaWidth || size.height != _mediaHeight) {
      _mediaWidth = size.width;
      _mediaHeight = size.height;
      _landscape = _mediaWidth > _mediaHeight;
    }

    final mediaSizeMin =
        _landscape && _twoColumnLayout ? _mediaWidth / 2 : min(_mediaWidth, _mediaHeight);
    if (_mediaSizeMin < eps || (_mediaSizeMin - mediaSizeMin).abs() > eps) {
      _mediaSizeMin = mediaSizeMin;
      _sizeDefault = mediaSizeMin / 8 * _sizeAdjust;
      _measurementStyle = TextStyle(
        fontFamily: fontFamily,
        fontSize: _sizeDefault,
      );
      _unitStyle = _themeManager.getBlueTextStyle(_sizeDefault / 3);
    }

    if (_measuring &&
        _targetHrMode != targetHeartRateModeNone &&
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

    final timeDisplay =
        Duration(seconds: _movingOrElapsedTime ? _movingTime ~/ 1000 : _elapsed).toDisplay();

    List<Widget> rows = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _themeManager.getBlueIcon(Icons.timer, _sizeDefault),
          Text(timeDisplay, style: _measurementStyle),
          SizedBox(width: _sizeDefault / 4),
        ],
      ),
    ];

    final targetHrState = _getTargetHrState();
    final targetHrTextStyle = _getTargetHrTextStyle(targetHrState);

    for (var entry in _rowConfig.asMap().entries) {
      var measurementStyle = _measurementStyle;

      if (entry.key == 2 && _leaderboardFeature) {
        measurementStyle = _getPaceLightTextStyle(_selfRank);
      }

      if (entry.key == 4 && _targetHrMode != targetHeartRateModeNone || _zoneIndexes[3] != null) {
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
        if (entry.value.metric == "hr" && _targetHrMode != targetHeartRateModeNone) {
          int zoneIndex =
              targetHrState == TargetHrState.off ? 0 : entry.value.binIndex(_heartRate ?? 0) + 1;
          String targetText = _getTargetHrText(targetHrState);
          targetText = "Z$zoneIndex $targetText";
          extra = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text(targetText, style: targetHrTextStyle), extra],
          );
        } else if (entry.value.metric == "speed" &&
            _leaderboardFeature &&
            _rankRibbonVisualization) {
          List<Widget> extraExtras = [];
          final paceLightColor = _getPaceLightTextStyle(_selfRank);
          extraExtras.add(Text(_selfRankString.join(" "), style: paceLightColor));

          if (widget.descriptor.defaultSport != ActivityType.ride) {
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
        if (_rankTrackVisualization || _showPacer) {
          markers.addAll(_markersForLeaderboard(_leaderboard, _selfRank));
          if (_selfRank > 0) {
            selfMarkerText = _selfRank.toString();
          }

          if (_rankInfoOnTrack || _showPacer) {
            markers.add(
              Center(
                child: _infoForLeaderboard(
                  _leaderboard,
                  _selfRank,
                  _selfRankString,
                ),
              ),
            );
          }

          // Add red circle around the athlete marker to distinguish
          markers.add(_getTrackMarker(markerPosition, selfMarkerColor, "", false));
          selfMarkerColor = _getPaceLightColor(_selfRank, background: true).value;
        } else if (_displayLapCounter) {
          markers.add(Center(
            child: Text("Lap $_lapCount", style: _measurementStyle),
          ));
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

    final body = _landscape && _twoColumnLayout
        ? GridView.count(
            crossAxisCount: 2,
            childAspectRatio: _mediaWidth / _mediaHeight / 2,
            physics: const NeverScrollableScrollPhysics(),
            semanticChildCount: 2,
            children: [
              SingleChildScrollView(
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
                      color: _getPaceLightColor(_selfRank, background: true),
                      child: ExpandablePanel(
                        theme: _expandableThemeData,
                        header: rows[3],
                        collapsed: Container(),
                        expanded: _simplerUi ? Container() : extras[1],
                        controller: _rowControllers[1],
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
            ],
          )
        : SingleChildScrollView(
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
                  color: _getPaceLightColor(_selfRank, background: true),
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
          );

    final List<Widget> menuButtons = [];
    if (_isLocked) {
      for (var i = 0; i < _unlockChoices; ++i) {
        final button = i == _unlockButtonIndex
            ? _themeManager.getGreenFabWKey(Icons.lock_open, true, true, "", 0, () {
                setState(() {
                  _isLocked = false;
                });
              }, _unlockKeys[i])
            : _themeManager.getBlueFabWKey(Icons.adjust, true, true, "", 0, null, _unlockKeys[i]);
        menuButtons.add(button);
      }
    } else {
      menuButtons.addAll([
        _themeManager.getTutorialFab(
          _tutorialVisible,
          () async {
            setState(() {
              _tutorialVisible = !_tutorialVisible;
            });
          },
        ),
      ]);

      if (_measuring) {
        menuButtons.add(_themeManager
            .getGreenFab(Icons.lock_open, true, _tutorialVisible, "Lock Screen", 0, () {
          _unlockButtonIndex = _rng.nextInt(_unlockChoices);
          _fabKey.currentState?.close();
          setState(() {
            _isLocked = true;
          });
        }));
      } else {
        menuButtons.addAll([
          _themeManager.getBlueFab(Icons.cloud_upload, true, _tutorialVisible, "Upload Workout", 8,
              () async {
            await _workoutUpload(false);
          }),
          _themeManager.getBlueFab(
            Icons.list_alt,
            true,
            _tutorialVisible,
            "Workout List",
            0,
            () async {
              final hasLeaderboardData = await _database.hasLeaderboardData();
              Get.to(() => ActivitiesScreen(hasLeaderboardData: hasLeaderboardData));
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
              if (!(_fitnessEquipment?.descriptor?.isFitnessMachine ?? false)) {
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
        ]);
      }

      menuButtons.addAll([
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
            String hrmId = await _initializeHeartRateMonitor();
            if (hrmId.isNotEmpty && _activity != null && (_activity!.hrmId != hrmId)) {
              _activity!.hrmId = hrmId;
              _activity!.hrmCalorieFactor = await _database.calorieFactorValue(hrmId, true);
              await _database.activityDao.updateActivity(_activity!);
            }
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
              if (_circuitWorkout) {
                // TODO: warning about circuit workout end
              }
              await _stopMeasurement(false);
            } else {
              await _startMeasurement();
            }
          },
        ),
      ]);
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTapUp: (details) {
          if (!_isLocked) return;

          for (var i = 0; i < _unlockChoices; ++i) {
            if (hitTest(_unlockKeys[i], details.globalPosition)) {
              if (_unlockKey == i && _unlockKey == _unlockButtonIndex) {
                _fabKey.currentState?.close();
                setState(() {
                  _isLocked = false;
                });
              } else {
                _unlockKey = -2;
              }
              return;
            }
          }

          if (hitTest(_fabKey, details.globalPosition)) {
            if (_unlockKey == -1 && _fabKey.currentState != null) {
              if (_fabKey.currentState!.isOpen) {
                _fabKey.currentState?.close();
              } else {
                _fabKey.currentState?.open();
              }
            }
            return;
          }
        },
        onTapDown: (details) {
          if (!_isLocked) return;

          for (var i = 0; i < _unlockChoices; ++i) {
            if (hitTest(_unlockKeys[i], details.globalPosition)) {
              _unlockKey = i;
              return;
            }
          }

          if (hitTest(_fabKey, details.globalPosition)) {
            _unlockKey = -1;
            return;
          }
        },
        onTap: _tutorialVisible
            ? () {
                setState(() {
                  _tutorialVisible = false;
                });
              }
            : null,
        child: OverlayTutorialScope(
          enabled: _tutorialVisible || _isLocked,
          overlayColor: _isLocked ? Colors.transparent : Colors.green.withOpacity(.8),
          child: AbsorbPointer(
            absorbing: _tutorialVisible || _isLocked,
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
                          builder: (context, oRect) {
                            return Positioned(
                              top: (oRect.rRect?.top ?? 0.0) + 8.0,
                              right: Get.width - (oRect.rRect?.left ?? 4.0) + 4.0,
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
              body: body,
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: CircularFabMenu(
                key: _fabKey,
                fabOpenIcon: Icon(_isLocked ? Icons.lock : Icons.menu,
                    color: _themeManager.getAntagonistColor()),
                fabOpenColor: _themeManager.getBlueColor(),
                fabCloseIcon: Icon(Icons.close, color: _themeManager.getAntagonistColor()),
                fabCloseColor: _themeManager.getBlueColor(),
                ringColor: _themeManager.getBlueColorInverse(),
                children: menuButtons,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
