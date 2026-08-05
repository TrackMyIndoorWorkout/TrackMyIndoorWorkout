import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:pref/pref.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:tuple/tuple.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../devices/bluetooth_device_ex.dart';
import '../../devices/device_descriptors/device_descriptor.dart';
import '../../devices/device_descriptors/kayak_first_descriptor.dart';
import '../../devices/gadgets/cadence_monitor_internal.dart';
import '../../devices/gadgets/fitness_equipment.dart';
import '../../devices/gadgets/heart_rate_monitor.dart';
import '../../export/export_target.dart';
import '../../export/fit/fit_export.dart';
import '../../persistence/activity.dart';
import '../../persistence/db_utils.dart';
import '../../persistence/record.dart';
import '../../persistence/workout_summary.dart';
import '../../preferences/app_debug_mode.dart';
import '../../preferences/calculate_gps.dart';
import '../../preferences/data_stream_gap_sound_effect.dart';
import '../../preferences/distance_resolution.dart';
import '../../preferences/heart_rate_monitor_workout.dart';
import '../../preferences/graph_view_duration.dart';
import '../../preferences/instant_export.dart';
import '../../preferences/instant_measurement_start.dart';
import '../../preferences/instant_upload.dart';
import '../../preferences/lap_counter.dart';
import '../../preferences/last_equipment_id.dart';
import '../../preferences/leaderboard_and_rank.dart';
import '../../preferences/log_level.dart';
import '../../preferences/measurement_font_size_adjust.dart';
import '../../preferences/measurement_sink_address.dart';
import '../../preferences/measurement_ui_state.dart';
import '../../preferences/metric_spec.dart';
import '../../preferences/palette_spec.dart';
import '../../preferences/show_pacer.dart';
import '../../preferences/show_resistance_level.dart';
import '../../preferences/show_inclination.dart';
import '../../preferences/show_strokes_strides_revs.dart';
import '../../preferences/simpler_ui.dart';
import '../../preferences/sound_effects.dart';
import '../../preferences/speed_spec.dart';
import '../../preferences/sport_spec.dart';
import '../../preferences/stage_mode.dart';
import '../../preferences/stationary_workout.dart';
import '../../preferences/target_heart_rate.dart';
import '../../preferences/time_display_mode.dart';
import '../../preferences/two_column_layout.dart';
import '../../preferences/unit_system.dart';
import '../../preferences/use_heart_rate_based_calorie_counting.dart';
import '../../preferences/workout_mode.dart';
import '../../track/calculator.dart';
import '../../track/constants.dart';
import '../../track/record_processor.dart';
import '../../track/track_descriptor.dart';
import '../../utils/bluetooth.dart';
import '../../utils/constants.dart';
import '../../utils/display.dart';
import '../../utils/logging.dart';
import '../../utils/preferences.dart';
import '../../utils/sound.dart';
import '../../utils/statistics_accumulator.dart';
import '../../utils/target_heart_rate.dart';
import '../../utils/theme_manager.dart';
import '../../utils/time_zone.dart';
import '../models/display_record.dart';
import '../models/progress_state.dart';
import '../models/row_configuration.dart';
import '../parts/cadence_monitor_pairing.dart';
import '../parts/heart_rate_monitor_pairing.dart';
import '../parts/legend_dialog.dart';
import '../parts/pick_directory.dart';
import '../parts/pre_measurement_progress.dart';
import '../parts/three_choices.dart';
import '../parts/upload_portal_picker.dart';
import 'measurement_row.dart';
import 'header_row.dart';
import 'recording_chart.dart';
import 'widgets/recording_fab_menu.dart';
import 'track_visualization.dart';

typedef DataFn = List<charts.LineSeries<DisplayRecord, DateTime>> Function();

enum TargetHrState { off, under, inRange, over }

class RecordingScreen extends StatefulWidget {
  final BluetoothDevice device;
  final DeviceDescriptor descriptor;
  final BluetoothConnectionState initialState;
  final Size size;
  final String sport;

  const RecordingScreen({
    super.key,
    required this.device,
    required this.descriptor,
    required this.initialState,
    required this.size,
    required this.sport,
  });

  @override
  RecordingState createState() => RecordingState();
}

class RecordingState extends State<RecordingScreen> {
  static const String tag = "RECORDING";
  static const double _markerStyleSizeAdjust = 1.4;
  static const double _markerStyleSmallSizeAdjust = 0.9;
  static const int _unlockChoices = 6;
  // Measurement display indexes
  static const int _calories0Index = 0;
  static const int _power0Index = _calories0Index + 1;
  static const int _speed0Index = _power0Index + 1;
  static const int _cadence0Index = _speed0Index + 1;
  static const int _hr0Index = _cadence0Index + 1;
  static const int _distance0Index = _hr0Index + 1;
  static const int _time1Index = 0;
  static const int _calories1Index = _calories0Index + 1;
  static const int _power1Index = _power0Index + 1;
  static const int _speed1Index = _speed0Index + 1;
  static const int _cadence1Index = _cadence0Index + 1;
  static const int _hr1Index = _hr0Index + 1;
  static const int _distance1Index = _distance0Index + 1;
  // static const int _caloriesNIndex = _calories0Index - 1;
  static const int _powerNIndex = _power0Index - 1;
  static const int _speedNIndex = _speed0Index - 1;
  static const int _cadenceNIndex = _cadence0Index - 1;
  static const int _hrNIndex = _hr0Index - 1;
  static const int _distanceNIndex = _distance0Index - 1;
  // Extra optional measurements
  static const int _resistanceIndex = 0;
  static const int _strokeCountIndex = 1;
  static const int _inclinationIndex = 2;

  late Size size = const Size(0, 0);
  FitnessEquipment? _fitnessEquipment;
  HeartRateMonitor? _heartRateMonitor;
  DeviceInternalMotion? _internalMotion;
  TrackCalculator? _trackCalculator;
  PaletteSpec? _paletteSpec;
  double _trackLength = 0; // Just default
  bool _busy = false;
  bool _measuring = false;
  bool _onStage = false;
  int _pointCount = 0;
  ListQueue<DisplayRecord> _graphData = ListQueue<DisplayRecord>();
  List<DisplayRecord> graphData = [];
  ListQueue<DisplayRecord> _graphAvgData = ListQueue<DisplayRecord>();
  List<DisplayRecord> graphAvgData = [];
  ListQueue<DisplayRecord> _graphMaxData = ListQueue<DisplayRecord>();
  List<DisplayRecord> graphMaxData = [];
  double _mediaSizeMin = 0;
  double _mediaHeight = 0;
  double _mediaWidth = 0;
  double _sizeDefault = 10.0;
  double _sizeAdjust = 1.0;
  double _halfWidthNonExpandable = 48.0;
  double _halfWidthExpandable = 48.0;
  bool _landscape = false;
  TextStyle _measurementStyle = const TextStyle();
  TextStyle _fullMeasurementStyle = const TextStyle();
  TextStyle _timeStyle = const TextStyle();
  TextStyle _unitStyle = const TextStyle();
  TextStyle _fullUnitStyle = const TextStyle();
  Color _chartTextColor = Colors.black;
  Color _chartAvgColor = Colors.orange;
  Color _chartMaxColor = Colors.red;
  TextStyle _chartLabelStyle = const TextStyle(fontFamily: fontFamily, fontSize: 11);
  TextStyle _markerStyle = const TextStyle();
  TextStyle _markerStyleSmall = const TextStyle();
  ExpandableThemeData _expandableThemeData = const ExpandableThemeData(
    hasIcon: !simplerUiSlowDefault,
    iconColor: Colors.black,
  );
  List<bool> _expandedState = [];
  final List<ExpandableController> _rowControllers = [];
  final List<int> _expandedHeights = [];
  List<MetricSpec> _preferencesSpecs = [];
  List<bool> _extraExpandedState = [];
  final List<ExpandableController> _extraRowControllers = [];

  DbUtils get dbUtils => Get.isRegistered<DbUtils>() ? Get.find<DbUtils>() : DbUtils();
  final List<int> _extraExpandedHeights = [];

  Activity? _activity;
  final _database = Get.find<Isar>();
  bool _si = unitSystemDefault;
  bool _highRes = distanceResolutionDefault;
  bool _simplerUi = simplerUiSlowDefault;
  bool _twoColumnLayout = twoColumnLayoutDefault;
  bool _instantUpload = instantUploadDefault;
  bool _instantExport = instantExportDefault;
  String _instantExportLocation = instantExportLocationDefault;
  bool _calculateGps = calculateGpsDefault;
  bool _stationaryWorkout = stationaryWorkoutDefault;
  bool _uxDebug = appDebugModeDefault;
  String _timeDisplayMode = timeDisplayModeDefault;
  bool _circuitWorkout = workoutModeDefault == workoutModeCircuit;
  String _dataGapSoundEffect = dataStreamGapSoundEffectDefault;
  double _graphViewDuration = graphViewDurationDefault;
  bool _firstDataReceived = false;

  Map<String, DataFn> _metricToDataFn = {};
  List<RowConfiguration> _rowConfig = [];
  List<String> _values = [];
  List<String> _optionalValues = [];
  List<String> _statistics = [];
  List<String> _optionalStatistics = [];
  List<int?> _zoneIndexes = [];
  double _distance = 0.0;
  int _elapsed = 0;
  int _movingTime = 0;
  int _markedTime = 0;

  bool _instantOnStage = instantOnStageDefault;
  String _onStageStatisticsType = onStageStatisticsTypeDefault;
  int _onStageStatisticsAlternationDuration = onStageStatisticsAlternationPeriodDefault;

  String _targetHrMode = targetHeartRateModeDefault;
  Tuple2<double, double> _targetHrBounds = const Tuple2(0, 0);
  int? _heartRate;
  Timer? _hrBeepPeriodTimer;
  int _hrBeepPeriod = targetHeartRateAudioPeriodDefault;
  bool _targetHrAudio = targetHeartRateAudioDefault;
  bool _targetHrAlerting = false;
  bool _heartRateMonitorWorkout = heartRateMonitorWorkoutDefault;
  bool _hrBasedCalorieCounting = useHeartRateBasedCalorieCountingDefault;
  bool _showResistanceLevel = showResistanceLevelDefault;
  bool _showStrokesStridesRevs = showStrokesStridesRevsDefault;
  bool _showInclination = showInclinationDefault;
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
  bool _chartTouchInteractionExtra = false;
  int? _latestInternalCadence;
  double? _latestInternalPreciseCadence;
  ThemeManager _themeManager = Get.find<ThemeManager>();
  bool _isLight = true;
  int _lapCount = 0;
  bool _isLocked = false;
  int _unlockButtonIndex = 0;
  final Random _rng = Random();
  final List<GlobalKey> _unlockKeys = [];
  final GlobalKey<FabCircularMenuPlusState> _fabKey = GlobalKey();
  int _unlockKey = -2;
  int _logLevel = logLevelDefault;
  StatisticsAccumulator _workoutStats = StatisticsAccumulator(si: true, sport: ActivityType.ride);
  StatisticsAccumulator _graphStats = StatisticsAccumulator(si: true, sport: ActivityType.ride);
  Tuple2<String, int> _sinkAddress = dummyAddressTuple;
  Socket? _sinkSocket;

  Future<void> _connectOnDemand() async {
    if (!(await bluetoothCheck(true, _logLevel))) {
      return;
    }

    setState(() {
      _busy = true;
    });

    bool success = await _fitnessEquipment?.connectOnDemand() ?? false;
    if (success) {
      await _fitnessEquipment?.additionalSensorsOnDemand();
      if (!_uxDebug) {
        await _fitnessEquipment?.prePumpConfiguration();
      }

      await _fitnessEquipment?.attach();
      _startPumpingData();
      if (!_uxDebug) {
        await _fitnessEquipment?.postPumpStart();
      }

      final prefService = Get.find<BasePrefService>();
      if (prefService.get<bool>(instantMeasurementStartTag) ?? instantMeasurementStartDefault) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          progressBottomSheet("Starting...", KayakFirstDescriptor.progressBarCompletionTime);
          await Future.delayed(KayakFirstDescriptor.commandLongDelay);
          await _startMeasurement(false);
          ProgressState.optionallyCloseProgress();
        });
      }

      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }

      Get.defaultDialog(
        middleText: 'Problem connecting to ${widget.descriptor.fullName}. Aborting...',
        confirm: TextButton(child: const Text("Ok"), onPressed: () => Get.close(1)),
      );
    }
  }

  void optionallyChangeMeasurementByZone(int valueIndex, num value, bool amendZone) {
    if (amendZone && _preferencesSpecs[valueIndex].indexDisplay ||
        _preferencesSpecs[valueIndex].coloringByZone) {
      int zoneIndex = _preferencesSpecs[valueIndex].binIndex(value);
      if (amendZone && _preferencesSpecs[valueIndex].indexDisplay) {
        _values[valueIndex + 1] += " Z${zoneIndex + 1}";
      }

      if (_preferencesSpecs[valueIndex].coloringByZone) {
        _zoneIndexes[valueIndex] = zoneIndex;
      }
    }
  }

  Future<void> _recordHandlerFunction(RecordWithSport record) async {
    // Allow if measuring AND (FE is measuring OR we are driven by internal cadence)
    bool drivenByInternal = (_latestInternalCadence ?? 0) > 0;
    if (!_measuring || (!(_fitnessEquipment?.measuring ?? false) && !drivenByInternal)) {
      return;
    }
    if (_internalMotion != null && _latestInternalCadence != null && _latestInternalCadence! > 0) {
      // Overwrite or supplement cadence
      // If we pair an internal sensor, we likely want to use it.
      record.cadence = _latestInternalCadence;
      if (_latestInternalPreciseCadence != null) {
        record.preciseCadence = _latestInternalPreciseCadence;
      }
    }

    _sinkSocket?.add(record.binarySerialize());

    final workoutState = _fitnessEquipment?.workoutState ?? WorkoutState.waitingForFirstMove;
    if (workoutState != WorkoutState.waitingForFirstMove) {
      if (!_uxDebug &&
          (workoutState == WorkoutState.moving ||
              workoutState == WorkoutState.startedMoving ||
              workoutState == WorkoutState.justPaused)) {
        _database.writeTxnSync(() {
          _database.records.putSync(record);
        });
      }

      if (!mounted) {
        return;
      }

      setState(() {
        if (!_simplerUi) {
          _graphData.add(DisplayRecord.fromRecord(record));
          _firstDataReceived = true;
          if (_onStageStatisticsType == onStageStatisticsTypeAverage ||
              _onStageStatisticsType == onStageStatisticsTypeAlternating) {
            _graphAvgData.add(_workoutStats.averageDisplayRecord(record.timeStamp));
          }

          if (_onStageStatisticsType == onStageStatisticsTypeMaximum ||
              _onStageStatisticsType == onStageStatisticsTypeAlternating) {
            _graphMaxData.add(_workoutStats.maximumDisplayRecord(record.timeStamp));
          }

          if (_graphViewDuration > 0) {
            final cutoff = record.timeStamp!.subtract(
              Duration(milliseconds: (_graphViewDuration * 60000).round()),
            );
            while (_graphData.isNotEmpty &&
                (_graphData.first.timeStamp?.isBefore(cutoff) ?? false)) {
              _graphData.removeFirst();
              if (_onStageStatisticsType == onStageStatisticsTypeAverage ||
                  _onStageStatisticsType == onStageStatisticsTypeAlternating) {
                _graphAvgData.removeFirst();
              }

              if (_onStageStatisticsType == onStageStatisticsTypeMaximum ||
                  _onStageStatisticsType == onStageStatisticsTypeAlternating) {
                _graphMaxData.removeFirst();
              }
            }
          } else if (_pointCount > 0 && _graphData.length > _pointCount) {
            _graphData.removeFirst();
            if (_onStageStatisticsType == onStageStatisticsTypeAverage ||
                _onStageStatisticsType == onStageStatisticsTypeAlternating) {
              _graphAvgData.removeFirst();
            }

            if (_onStageStatisticsType == onStageStatisticsTypeMaximum ||
                _onStageStatisticsType == onStageStatisticsTypeAlternating) {
              _graphMaxData.removeFirst();
            }
          }

          graphData = _graphData.toList(growable: false);
          if (_onStageStatisticsType == onStageStatisticsTypeAverage ||
              _onStageStatisticsType == onStageStatisticsTypeAlternating) {
            graphAvgData = _graphAvgData.toList(growable: false);
          }

          if (_onStageStatisticsType == onStageStatisticsTypeMaximum ||
              _onStageStatisticsType == onStageStatisticsTypeAlternating) {
            graphMaxData = _graphMaxData.toList(growable: false);
          }

          if (_onStageStatisticsType != onStageStatisticsTypeNone) {
            _graphStats.reset();
            for (final data in _graphData) {
              _graphStats.processDisplayRecord(data);
            }
          }
        }

        final tickResult = RecordProcessor.process(
          record: record,
          workoutState: workoutState,
          displayLapCounter: _displayLapCounter,
          trackLength: _trackLength,
          currentLapCount: _lapCount,
          timeDisplayMode: _timeDisplayMode,
          markedTime: _markedTime,
          currentHeartRate: _heartRate,
          onStage: _onStage,
          onStageStatisticsType: _onStageStatisticsType,
          onStageStatisticsAlternationDuration: _onStageStatisticsAlternationDuration,
          stationaryWorkout: _stationaryWorkout,
          showResistanceLevel: _showResistanceLevel,
          showInclination: _showInclination,
          si: _si,
          sport: widget.descriptor.sport,
          workoutStats: _workoutStats,
          statistics: _statistics,
          optionalStatistics: _optionalStatistics,
          power0Index: _power0Index,
          speed0Index: _speed0Index,
          cadence0Index: _cadence0Index,
          hr0Index: _hr0Index,
          resistanceIndex: _resistanceIndex,
          inclinationIndex: _inclinationIndex,
        );
        _distance = tickResult.distance;
        _lapCount = tickResult.lapCount;
        _elapsed = tickResult.elapsed;
        _markedTime = tickResult.markedTime;
        _movingTime = tickResult.movingTime;
        _heartRate = tickResult.heartRate;

        if (_leaderboardFeature || _showPacer) {
          final selfRankTuple = _getSelfRank();
          _selfRank = selfRankTuple.item1;
          _selfAvgSpeed = selfRankTuple.item2;
          _selfRankString = _getSelfRankString();
        }

        _values = [
          record.calories?.toString() ?? emptyMeasurement,
          record.power?.toString() ?? emptyMeasurement,
          record.speedOrPaceStringByUnit(_si, widget.descriptor.sport),
          record.cadence?.toString() ?? emptyMeasurement,
          record.heartRate?.toString() ?? emptyMeasurement,
          record.distanceStringByUnit(_si, _highRes),
        ];

        if (_showResistanceLevel) {
          _optionalValues[_resistanceIndex] = record.resistance?.toString() ?? emptyMeasurement;
        }

        if (_showStrokesStridesRevs) {
          _optionalValues[_strokeCountIndex] =
              record.strokeCount?.toInt().toString() ?? emptyMeasurement;
        }

        if (_showInclination) {
          _optionalValues[_inclinationIndex] =
              record.inclination?.toStringAsFixed(1) ?? emptyMeasurement;
        }

        if (!_stationaryWorkout) {
          optionallyChangeMeasurementByZone(_speedNIndex, record.speed ?? 0.0, false);
          optionallyChangeMeasurementByZone(_powerNIndex, record.power ?? 0, true);
        }

        optionallyChangeMeasurementByZone(_cadenceNIndex, record.cadence ?? 0, true);
        optionallyChangeMeasurementByZone(_hrNIndex, record.heartRate ?? 0, true);
      });
    }
  }

  void _startPumpingData() {
    _fitnessEquipment?.pumpData((record) async => await _recordHandlerFunction(record));
  }

  Future<void> _startMeasurement(bool checkBluetooth) async {
    if (checkBluetooth && !(await bluetoothCheck(true, _logLevel))) {
      return;
    }

    if (!_uxDebug &&
        _sinkAddress != dummyAddressTuple &&
        (widget.sport == ActivityType.ride ||
            widget.sport == ActivityType.kayaking ||
            widget.sport == ActivityType.canoeing ||
            widget.sport == ActivityType.rowing ||
            widget.sport == ActivityType.swim)) {
      try {
        _sinkSocket = await Socket.connect(_sinkAddress.item1, _sinkAddress.item2);
        // Send descriptor packet
        const version = 1;
        final uuidLsb = widget.sport == ActivityType.ride ? 0xD2 : 0xD1;
        final packetLength = RecordWithSport.binarySerializedLength(widget.sport);
        _sinkSocket?.add([version, 0x18, 0x26, 0x2A, uuidLsb, packetLength]);
      } on SocketException {
        Get.snackbar("Error", "Could not connect to Sink Server");
        _sinkSocket = null;
      }
    }

    final now = DateTime.now();
    var continued = false;
    double powerFactor = 1.0;
    double calorieFactor = 1.0;
    double hrmCalorieFactor = 1.0;
    final dbUtils = this.dbUtils;

    if (widget.device.remoteId.str.isNotEmpty) {
      final factors = await dbUtils.getFactors(widget.device.remoteId.str);
      powerFactor = factors.item1;
      calorieFactor = factors.item2;
      hrmCalorieFactor = factors.item3;
    }

    if (!_uxDebug) {
      // dbUtils used from outer scope
      final unfinished = await dbUtils.unfinishedDeviceActivities(widget.device.remoteId.str);
      if (unfinished.isNotEmpty) {
        final yesterday = now.subtract(const Duration(days: 1));
        if (unfinished.first.start.isAfter(yesterday)) {
          _activity = unfinished.first;
          continued = true;
        }

        for (final activity in unfinished) {
          if (!continued || _activity == null || _activity!.id != activity.id) {
            await dbUtils.finalizeActivity(activity);
          }
        }
      }
    }

    if (_onStageStatisticsType != onStageStatisticsTypeNone) {
      _workoutStats.reset();
    }

    if (!continued) {
      _activity = Activity(
        fourCC: widget.descriptor.fourCC,
        deviceName: widget.device.nonEmptyName,
        deviceId: widget.device.remoteId.str,
        hrmId: _fitnessEquipment?.heartRateMonitor?.device?.remoteId.str ?? "",
        start: now,
        sport: widget.descriptor.sport,
        powerFactor: powerFactor,
        calorieFactor: calorieFactor,
        hrCalorieFactor: _fitnessEquipment?.hrCalorieFactor ?? 1.0,
        hrmCalorieFactor: hrmCalorieFactor,
        hrBasedCalories: _hrBasedCalorieCounting,
        timeZone: await getTimeZone(),
      );
    }

    if (!_uxDebug) {
      if (!continued) {
        _database.writeTxnSync(() {
          _database.activitys.putSync(_activity!);
        });
      }
    }

    if (_leaderboardFeature || _showPacer) {
      _selfRank = 0;
      _selfAvgSpeed = 0.0;
      _selfRankString = [];
      _averageSpeeds.clear();
      _averageSpeedSum = 0.0;
      if (_leaderboardFeature) {
        _leaderboard = _rankingForSportOrDevice
            ? await _database.workoutSummarys
                  .filter()
                  .sportEqualTo(widget.descriptor.sport)
                  .sortBySpeedDesc()
                  .findAll()
            : await _database.workoutSummarys
                  .filter()
                  .deviceIdEqualTo(widget.device.remoteId.str)
                  .sortBySpeedDesc()
                  .findAll();

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

    await _fitnessEquipment?.setActivity(_activity!);

    setState(() {
      _elapsed = 0;
      _movingTime = 0;
      _distance = 0.0;
      _lapCount = 0;
      _measuring = true;
      _zoneIndexes = [null, null, null, null];
      if (_onStageStatisticsType != onStageStatisticsTypeNone) {
        if (_instantOnStage) {
          _onStage = true;
        }

        _statistics[_power0Index] = emptyMeasurement;
        _statistics[_speed0Index] = emptyMeasurement;
        _statistics[_cadence0Index] = emptyMeasurement;
        _statistics[_hr0Index] = emptyMeasurement;

        if (_showResistanceLevel) {
          _optionalStatistics[_resistanceIndex] = emptyMeasurement;
        }
      }
    });
    _fitnessEquipment?.measuring = true;
    _fitnessEquipment?.startWorkout();
  }

  void _onToggleDetails(int index, bool extra) {
    setState(() {
      if (!extra) {
        _expandedState[index] = _rowControllers[index].expanded;
        applyExpandedStates(_expandedState);
      } else {
        _extraExpandedState[index] = _extraRowControllers[index].expanded;
      }
    });
  }

  void _onTogglePower() {
    _onToggleDetails(_powerNIndex, false);
  }

  void _onToggleSpeed() {
    _onToggleDetails(_speedNIndex, false);
  }

  void _onToggleRpm() {
    _onToggleDetails(_cadenceNIndex, false);
  }

  void _onToggleHr() {
    _onToggleDetails(_hrNIndex, false);
  }

  void _onToggleDistance() {
    _onToggleDetails(_distanceNIndex, false);
  }

  void _rotateChartHeight(int index, bool extra) {
    setState(() {
      if (!extra) {
        _expandedHeights[index] = (_expandedHeights[index] + 1) % 3;
        applyDetailSizes(_expandedHeights);
      } else {
        _extraExpandedHeights[index] = (_extraExpandedHeights[index] + 1) % 3;
      }
    });
  }

  void _onToggleResistance() {
    _onToggleDetails(_resistanceIndex, true);
  }

  void _onToggleInclination() {
    _onToggleDetails(_inclinationIndex, true);
  }

  void _onChartTouchInteractionDown(int index, Offset position, bool extra) {
    _chartTouchInteractionDownTime = DateTime.now();
    _chartTouchInteractionPosition = position;
    _chartTouchInteractionIndex = index;
    _chartTouchInteractionExtra = extra;
  }

  void _onChartTouchInteractionUp(int index, Offset position, bool extra) {
    if (_chartTouchInteractionIndex == index &&
        _chartTouchInteractionExtra == extra &&
        _chartTouchInteractionDownTime != null) {
      final distanceSquared = (position - _chartTouchInteractionPosition).distanceSquared;
      if (distanceSquared <= 25) {
        Duration pressTime = DateTime.now().difference(_chartTouchInteractionDownTime!);
        if (pressTime.inMilliseconds >= 1300) {
          _rotateChartHeight(index, extra);
        }
      }
    }

    _chartTouchInteractionDownTime = null;
    _chartTouchInteractionIndex = -1;
    _chartTouchInteractionExtra = !_chartTouchInteractionExtra;
  }

  Future<String> _initializeHeartRateMonitor(bool checkBluetooth) async {
    if (_heartRateMonitorWorkout || (_fitnessEquipment?.descriptor?.isHeartRateMonitor ?? false)) {
      return "";
    }

    if (checkBluetooth && !(await bluetoothCheck(true, _logLevel))) {
      return "";
    }

    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    final discovered = (await _heartRateMonitor?.discover()) ?? false;
    if (discovered) {
      if (_heartRateMonitor?.device?.remoteId.str !=
          (_fitnessEquipment?.heartRateMonitor?.device?.remoteId.str ?? notAvailable)) {
        _fitnessEquipment?.setHeartRateMonitor(_heartRateMonitor!);
      }
      _heartRateMonitor?.attach().then((_) async {
        if (_heartRateMonitor?.subscription != null) {
          _heartRateMonitor?.cancelSubscription();
        }
        _heartRateMonitor?.pumpData((record) async {
          if (!mounted) {
            return;
          }

          setState(() {
            if ((_heartRate == null || _heartRate == 0) &&
                (record.heartRate != null && record.heartRate! > 0)) {
              _heartRate = record.heartRate;
            }

            _values[_hr0Index] = record.heartRate?.toString() ?? emptyMeasurement;
            optionallyChangeMeasurementByZone(_hrNIndex, record.heartRate ?? 0, true);
          });
        });
      });

      return _heartRateMonitor?.device?.remoteId.str ?? "";
    }

    return "";
  }

  Future<void> _initializeInternalMotion() async {
    _internalMotion = Get.isRegistered<DeviceInternalMotion>()
        ? Get.find<DeviceInternalMotion>()
        : null;
    if (_internalMotion != null) {
      await _internalMotion!.connect(); // Should be no-op if already connected
      await _internalMotion!.discover();
      await _internalMotion!.attach();

      // Ensure FitnessEquipment has our record handler
      _startPumpingData();

      _internalMotion!.pumpData((record) {
        if (mounted) {
          setState(() {
            _latestInternalCadence = record.cadence;
            _latestInternalPreciseCadence = record.preciseCadence;
          });

          // Pipe the record through FitnessEquipment so it manages the state machine (moving, paused, etc)
          // and throttling, then calls _recordHandlerFunction.
          if (_measuring) {
            _fitnessEquipment?.pumpDataCore(record, false);
          }
        }
      });
    }
  }

  Future<void> _onCadencePairing() async {
    await Get.bottomSheet(
      const SafeArea(
        child: Column(
          children: [Expanded(child: Center(child: CadenceMonitorPairingBottomSheet()))],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
      enableDrag: false,
    );
    await _initializeInternalMotion();
  }

  @override
  void initState() {
    super.initState();

    size = widget.size;

    WakelockPlus.enable();

    _busy = false;
    _themeManager = Get.find<ThemeManager>();
    _isLight = !_themeManager.isDark();
    _unitStyle = TextStyle(fontFamily: fontFamily, color: _themeManager.getBlueColor());
    _fullUnitStyle = TextStyle(fontFamily: fontFamily, color: _themeManager.getBlueColor());
    final prefService = Get.find<BasePrefService>();
    _logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
    final sinkAddressString =
        prefService.get<String>(measurementSinkAddressTag) ?? measurementSinkAddressDefault;
    if (sinkAddressString.isNotEmpty) {
      _sinkAddress = parseNetworkAddress(sinkAddressString, false);
    }
    final sizeAdjustInt =
        prefService.get<int>(measurementFontSizeAdjustTag) ?? measurementFontSizeAdjustDefault;
    if (sizeAdjustInt != 100) {
      _sizeAdjust = sizeAdjustInt / 100.0;
    }
    _markerStyle = _themeManager.boldStyle(
      Get.textTheme.bodyLarge!,
      fontSizeFactor: _markerStyleSizeAdjust,
    );
    _markerStyleSmall = _themeManager.boldStyle(
      Get.textTheme.bodyLarge!,
      fontSizeFactor: _markerStyleSmallSizeAdjust,
    );
    prefService.set<String>(
      lastEquipmentIdTagPrefix + SportSpec.sport2Sport(widget.sport),
      widget.device.remoteId.str,
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

    final displayTrack = TrackDescriptor.forDisplay(widget.sport);
    _trackCalculator = TrackCalculator(track: displayTrack);
    _trackLength = displayTrack.length;
    _si = prefService.get<bool>(unitSystemTag) ?? unitSystemDefault;
    _highRes = prefService.get<bool>(distanceResolutionTag) ?? distanceResolutionDefault;
    _simplerUi = prefService.get<bool>(simplerUiTag) ?? simplerUiSlowDefault;
    _twoColumnLayout = prefService.get<bool>(twoColumnLayoutTag) ?? twoColumnLayoutDefault;
    _timeDisplayMode = prefService.get<String>(timeDisplayModeTag) ?? timeDisplayModeDefault;
    _instantUpload = prefService.get<bool>(instantUploadTag) ?? instantUploadDefault;
    _instantExport = prefService.get<bool>(instantExportTag) ?? instantExportDefault;
    _instantExportLocation =
        prefService.get<String>(instantExportLocationTag) ?? instantExportLocationDefault;
    _calculateGps = prefService.get<bool>(calculateGpsTag) ?? calculateGpsDefault;
    _stationaryWorkout = prefService.get<bool>(stationaryWorkoutTag) ?? stationaryWorkoutDefault;
    // #252: Disable fixed point retention to allow full history for time scaling.
    // Originally: _pointCount = min(60, size.width ~/ 2);
    _pointCount = 0;
    _onStageStatisticsType =
        prefService.get<String>(onStageStatisticsTypeTag) ?? onStageStatisticsTypeDefault;
    final now = DateTime.now();
    if (!_simplerUi) {
      _graphData = ListQueue.from(
        List<DisplayRecord>.generate(
          _pointCount,
          (i) =>
              DisplayRecord.blank(widget.sport, now.subtract(Duration(seconds: _pointCount - i))),
        ),
      );
      graphData = _graphData.toList(growable: false);
      if (_onStageStatisticsType == onStageStatisticsTypeAverage ||
          _onStageStatisticsType == onStageStatisticsTypeAlternating) {
        _graphAvgData = ListQueue.from(
          List<DisplayRecord>.generate(
            _pointCount,
            (i) =>
                DisplayRecord.blank(widget.sport, now.subtract(Duration(seconds: _pointCount - i))),
          ),
        );
        graphAvgData = _graphAvgData.toList(growable: false);
      }

      if (_onStageStatisticsType == onStageStatisticsTypeMaximum ||
          _onStageStatisticsType == onStageStatisticsTypeAlternating) {
        _graphMaxData = ListQueue.from(
          List<DisplayRecord>.generate(
            _pointCount,
            (i) =>
                DisplayRecord.blank(widget.sport, now.subtract(Duration(seconds: _pointCount - i))),
          ),
        );
        graphMaxData = _graphMaxData.toList(growable: false);
      }
    }

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

    _preferencesSpecs = MetricSpec.getPreferencesSpecs(_si, widget.descriptor.sport);
    for (var prefSpec in _preferencesSpecs) {
      prefSpec.calculateBounds(
        0,
        decimalRound(prefSpec.threshold * (prefSpec.zonePercents.last + 15) / 100.0),
        _isLight,
        _paletteSpec!,
      );
    }

    _circuitWorkout =
        (prefService.get<String>(workoutModeTag) ?? workoutModeDefault) == workoutModeCircuit;
    _dataGapSoundEffect =
        prefService.get<String>(dataStreamGapSoundEffectTag) ?? dataStreamGapSoundEffectDefault;
    _targetHrMode = prefService.get<String>(targetHeartRateModeTag) ?? targetHeartRateModeDefault;
    _targetHrBounds = getTargetHeartRateBounds(_targetHrMode, _preferencesSpecs[3], prefService);
    _targetHrAlerting = false;
    _targetHrAudio = prefService.get<bool>(targetHeartRateAudioTag) ?? targetHeartRateAudioDefault;
    if (_targetHrMode != targetHeartRateModeNone && _targetHrAudio) {
      _hrBeepPeriod =
          prefService.get<int>(targetHeartRateAudioPeriodIntTag) ??
          targetHeartRateAudioPeriodDefault;
    }

    if (_targetHrMode != targetHeartRateModeNone && _targetHrAudio ||
        _dataGapSoundEffect != soundEffectNone) {
      if (!Get.isRegistered<SoundService>()) {
        Get.put<SoundService>(SoundService(), permanent: true);
      }
    }

    _hrBasedCalorieCounting =
        prefService.get<bool>(useHeartRateBasedCalorieCountingTag) ??
        useHeartRateBasedCalorieCountingDefault;
    _heartRateMonitorWorkout =
        prefService.get<bool>(heartRateMonitorWorkoutTag) ?? heartRateMonitorWorkoutDefault;
    _showResistanceLevel =
        prefService.get<bool>(showResistanceLevelTag) ?? showResistanceLevelDefault;
    _showStrokesStridesRevs =
        prefService.get<bool>(showStrokesStridesRevsTag) ?? showStrokesStridesRevsDefault;
    _graphViewDuration = prefService.get<double>(graphViewDurationTag) ?? graphViewDurationDefault;
    _showInclination = prefService.get<bool>(showInclinationTag) ?? showInclinationDefault;

    _instantOnStage = prefService.get<bool>(instantOnStageTag) ?? instantOnStageDefault;
    _onStageStatisticsType =
        prefService.get<String>(onStageStatisticsTypeTag) ?? onStageStatisticsTypeDefault;
    _onStageStatisticsAlternationDuration =
        prefService.get<int>(onStageStatisticsAlternationPeriodTag) ??
        onStageStatisticsAlternationPeriodDefault;

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
    _chartAvgColor = _themeManager.getAverageChartColor();
    _chartMaxColor = _themeManager.getMaximumChartColor();
    _expandableThemeData = ExpandableThemeData(
      hasIcon: !_simplerUi,
      iconColor: _themeManager.getProtagonistColor(),
    );
    _rowConfig = [
      RowConfiguration(title: "Calories", icon: Icons.whatshot, unit: 'cal', expandable: false),
      RowConfiguration(
        title: _preferencesSpecs[_powerNIndex].title,
        icon: _preferencesSpecs[_powerNIndex].icon,
        unit: _preferencesSpecs[_powerNIndex].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        title: _preferencesSpecs[_speedNIndex].title,
        icon: _preferencesSpecs[_speedNIndex].icon,
        unit: _preferencesSpecs[_speedNIndex].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        title: _preferencesSpecs[_cadenceNIndex].title,
        icon: _preferencesSpecs[_cadenceNIndex].icon,
        unit: _preferencesSpecs[_cadenceNIndex].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        title: _preferencesSpecs[_hrNIndex].title,
        icon: _preferencesSpecs[_hrNIndex].icon,
        unit: _preferencesSpecs[_hrNIndex].unit,
        expandable: !_simplerUi,
      ),
      RowConfiguration(
        title: "Distance",
        icon: Icons.add_road,
        unit: distanceUnit(_si, _highRes),
        expandable: !_simplerUi,
      ),
    ];

    if (_showResistanceLevel) {
      _extraExpandedState = [false];
      ExpandableController rowController = ExpandableController(initialExpanded: false);
      rowController.addListener(_onToggleResistance);
      _extraRowControllers.add(rowController);
      _extraExpandedHeights.add(0);
    }

    if (_showInclination) {
      if (_extraExpandedState.isEmpty) {
        _extraExpandedState = [false];
      } else {
        _extraExpandedState.add(false);
      }
      ExpandableController rowController = ExpandableController(initialExpanded: false);
      rowController.addListener(_onToggleInclination);
      _extraRowControllers.add(rowController);
      _extraExpandedHeights.add(0);
    }

    final expandedStateStr =
        prefService.get<String>(measurementPanelsExpandedTag) ?? measurementPanelsExpandedDefault;
    final expandedHeightStr =
        prefService.get<String>(measurementDetailSizeTag) ?? measurementDetailSizeDefault;
    _expandedState = List<bool>.generate(expandedStateStr.length, (int index) {
      final expanded = expandedStateStr[index] == "1" && !_stationaryWorkout;
      ExpandableController rowController = ExpandableController(initialExpanded: expanded);
      _rowControllers.add(rowController);
      switch (index) {
        case _powerNIndex:
          if (!_stationaryWorkout) {
            rowController.addListener(_onTogglePower);
          }
          break;
        case _speedNIndex:
          if (!_stationaryWorkout) {
            rowController.addListener(_onToggleSpeed);
          }
          break;
        case _cadenceNIndex:
          rowController.addListener(_onToggleRpm);
          break;
        case _hrNIndex:
          rowController.addListener(_onToggleHr);
          break;
        case _distanceNIndex:
        default:
          if (!_stationaryWorkout) {
            rowController.addListener(_onToggleDistance);
          }
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

    _optionalValues = [emptyMeasurement, emptyMeasurement, emptyMeasurement];

    _statistics = [
      emptyMeasurement,
      emptyMeasurement,
      emptyMeasurement,
      emptyMeasurement,
      emptyMeasurement,
      emptyMeasurement,
    ];

    // 3 slots to match _optionalValues indices: resistance=0, strokeCount=1 (unused, no stats), inclination=2
    _optionalStatistics = [emptyMeasurement, emptyMeasurement, emptyMeasurement];

    final calculateCadences = true;
    _workoutStats = StatisticsAccumulator(
      si: _si,
      sport: widget.sport,
      calculateAvgPower: !_stationaryWorkout,
      calculateMaxPower: !_stationaryWorkout,
      calculateAvgSpeed: !_stationaryWorkout,
      calculateMaxSpeed: !_stationaryWorkout,
      calculateAvgCadence: calculateCadences,
      calculateMaxCadence: calculateCadences,
      calculateAvgHeartRate: true,
      calculateMaxHeartRate: true,
      calculateAvgResistance: _showResistanceLevel,
      calculateMaxResistance: _showResistanceLevel,
      calculateAvgInclination: _showInclination,
      calculateMaxInclination: _showInclination,
    );
    _graphStats = StatisticsAccumulator(
      si: _si,
      sport: widget.sport,
      calculateAvgPower: false,
      calculateMaxPower: !_stationaryWorkout && _onStageStatisticsType != onStageStatisticsTypeNone,
      calculateMinPower: !_stationaryWorkout && _onStageStatisticsType != onStageStatisticsTypeNone,
      calculateAvgSpeed: false,
      calculateMaxSpeed: !_stationaryWorkout && _onStageStatisticsType != onStageStatisticsTypeNone,
      calculateMinSpeed: !_stationaryWorkout && _onStageStatisticsType != onStageStatisticsTypeNone,
      calculateAvgCadence: false,
      calculateMaxCadence: calculateCadences && _onStageStatisticsType != onStageStatisticsTypeNone,
      calculateMinCadence: calculateCadences && _onStageStatisticsType != onStageStatisticsTypeNone,
      calculateAvgHeartRate: false,
      calculateMaxHeartRate: _onStageStatisticsType != onStageStatisticsTypeNone,
      calculateMinHeartRate: _onStageStatisticsType != onStageStatisticsTypeNone,
      calculateAvgResistance: false,
      calculateMaxResistance:
          _showResistanceLevel && _onStageStatisticsType != onStageStatisticsTypeNone,
      calculateMinResistance:
          _showResistanceLevel && _onStageStatisticsType != onStageStatisticsTypeNone,
      calculateAvgInclination: false,
      calculateMaxInclination:
          _showInclination && _onStageStatisticsType != onStageStatisticsTypeNone,
      calculateMinInclination:
          _showInclination && _onStageStatisticsType != onStageStatisticsTypeNone,
    );
    _zoneIndexes = [null, null, null, null];

    _leaderboard = [];
    _selfRankString = [];
    _rankingForSportOrDevice =
        prefService.get<bool>(rankingForSportOrDeviceTag) ?? rankingForSportOrDeviceDefault;
    if (_stationaryWorkout) {
      _leaderboardFeature = false;
      _rankRibbonVisualization = false;
      _rankTrackVisualization = false;
      _rankInfoOnTrack = false;
      _displayLapCounter = false;
      _avgSpeedOnTrack = false;
    } else {
      _leaderboardFeature =
          prefService.get<bool>(leaderboardFeatureTag) ?? leaderboardFeatureDefault;
      _rankRibbonVisualization =
          prefService.get<bool>(rankRibbonVisualizationTag) ?? rankRibbonVisualizationDefault;
      _rankTrackVisualization =
          prefService.get<bool>(rankTrackVisualizationTag) ?? rankTrackVisualizationDefault;
      _rankInfoOnTrack = prefService.get<bool>(rankInfoOnTrackTag) ?? rankInfoOnTrackDefault;
      _displayLapCounter = prefService.get<bool>(displayLapCounterTag) ?? displayLapCounterDefault;
      _avgSpeedOnTrack = prefService.get<bool>(avgSpeedOnTrackTag) ?? avgSpeedOnTrackDefault;
    }

    _rankInfoColumnCount = 2;
    if (_displayLapCounter) {
      _rankInfoColumnCount++;
    }

    if (_avgSpeedOnTrack) {
      _rankInfoColumnCount++;
    }

    final isLight = !_themeManager.isDark();
    _darkRed = isLight ? Colors.red.shade900 : Colors.redAccent.shade100;
    _darkGreen = isLight ? Colors.green.shade900 : Colors.lightGreenAccent.shade100;
    _darkBlue = isLight ? Colors.indigo.shade900 : Colors.lightBlueAccent.shade100;
    _lightRed = isLight ? Colors.redAccent.shade100 : Colors.red.shade900;
    _lightGreen = isLight ? Colors.lightGreenAccent.shade100 : Colors.green.shade900;
    _lightBlue = isLight ? Colors.lightBlueAccent.shade100 : Colors.indigo.shade900;

    _initializeHeartRateMonitor(false);
    // Delay initialization of internal motion to prevent main thread blocking during screen transition
    // and allow the UI to render the first frame.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _initializeInternalMotion();
      }
    });
    _connectOnDemand();
    _isLocked = false;
    _unlockButtonIndex = 0;
    if (_unlockKeys.isEmpty) {
      _unlockKeys.addAll([for (var i = 0; i < _unlockChoices; ++i) GlobalKey()]);
    }

    _unlockKey = -2;
  }

  @override
  void dispose() {
    _hrBeepPeriodTimer?.cancel();
    if (_targetHrMode != targetHeartRateModeNone && _targetHrAudio ||
        _dataGapSoundEffect != soundEffectNone) {
      Get.find<SoundService>().stopSoundEffect();
    }

    WakelockPlus.disable();

    super.dispose();
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

  Future<void> _activityUpload(bool onlyWhenAuthenticated) async {
    if (_activity == null) return;

    if (!await hasInternetConnection()) {
      Get.snackbar("Warning", "No data connection detected, try again later!");
      return;
    }

    Get.bottomSheet(
      SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(child: UploadPortalPickerBottomSheet(activity: _activity!)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
      enableDrag: false,
    );
  }

  Future<void> _activityExport() async {
    if (_activity?.id == null || !_instantExport) return;

    if (_instantExportLocation.isEmpty) {
      _instantExportLocation = await pickDirectory(
        context,
        instantExportLocationPickerTitle,
        _instantExportLocation,
      );
      if (_instantExportLocation.isEmpty) {
        return;
      }
    }

    final exporter = FitExport();
    final fileBytes = await exporter.getExport(
      _activity!,
      false,
      _calculateGps,
      false,
      ExportTarget.regular,
    );
    final fileName = _activity!.getFileNameStub() + exporter.fileExtension(false);
    String fileFullPath = p.join(_instantExportLocation, fileName);
    await File(fileFullPath).writeAsBytes(fileBytes, flush: true);
  }

  Future<void> _stopMeasurement(bool quick) async {
    _fitnessEquipment?.measuring = false;
    if (!_measuring || _activity == null) return;

    _hrBeepPeriodTimer?.cancel();
    if (_targetHrMode != targetHeartRateModeNone && _targetHrAudio ||
        _dataGapSoundEffect != soundEffectNone) {
      Get.find<SoundService>().stopSoundEffect();
    }

    setState(() {
      _measuring = false;
    });

    try {
      if (await isBluetoothOn()) {
        await _fitnessEquipment?.stopWorkout();
      }
    } on Exception catch (e, stack) {
      Logging().logException(
        _logLevel,
        tag,
        "_stopMeasurement",
        "_fitnessEquipment.stopWorkout()",
        e,
        stack,
      );
    }

    final last = _fitnessEquipment?.lastRecord;
    _activity!.finish(
      last?.distance,
      last?.elapsed,
      last?.calories,
      last?.strokeCount?.toInt() ?? 0,
      last?.movingTime ?? 0,
    );

    if (!_uxDebug) {
      if (_leaderboardFeature && (last?.distance ?? 0.0) > displayEps) {
        final workoutSummary = _activity!.getWorkoutSummary(
          _fitnessEquipment?.manufacturerName ?? "Unknown",
        );
        _database.writeTxnSync(() {
          _database.workoutSummarys.putSync(workoutSummary);
        });
      }

      _database.writeTxnSync(() {
        _database.activitys.putSync(_activity!);
      });

      if (!quick && _activity != null) {
        if (_instantUpload) {
          await _activityUpload(true);
        }

        if (_instantExport) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await _activityExport();
            await _initializeHeartRateMonitor(true);
            await _initializeInternalMotion();
            // Only do the connection if we are not expecting an instant start,
            // because in that case the startMeasurement will do it.
          });
        }
      }
    }

    _sinkSocket?.destroy();
    _sinkSocket = null;
  }

  List<charts.PlotBand> _safeGetPlotBands(List<charts.PlotBand> bands) {
    // Need at least 3 data points for the chart to have a valid Y-axis range
    if (!_firstDataReceived || graphData.length < 3) {
      return <charts.PlotBand>[];
    }

    for (var band in bands) {
      // Check start and end for NaN
      final start = band.start;
      final end = band.end;
      if (start is double && (start.isNaN || start.isInfinite)) {
        return <charts.PlotBand>[];
      }
      if (end is double && (end.isNaN || end.isInfinite)) {
        return <charts.PlotBand>[];
      }
    }
    return bands;
  }

  bool _hasDataForMetric(String metric) {
    switch (metric) {
      case "power":
        return _graphStats.maxPower > 0;
      case "speed":
        return _graphStats.maxSpeed > 0;
      case "cadence":
        return _graphStats.maxCadence > 0;
      case "hr":
        return _graphStats.maxHeartRate > 0;
      default:
        return false;
    }
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _powerChartData() {
    List<charts.LineSeries<DisplayRecord, DateTime>> series = [
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: graphData,
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.power,
        color: _chartTextColor,
        animationDuration: 0,
      ),
    ];

    int minPowerThreshold = minInit;
    int maxPowerThreshold = maxInit;
    if (_onStageStatisticsType != onStageStatisticsTypeNone) {
      final minPower = _graphStats.minPower;
      if (minPower < minInit) {
        minPowerThreshold = (minPower * 0.8).toInt();
      }

      final maxPower = _graphStats.maxPower;
      if (maxPower > maxInit) {
        maxPowerThreshold = (maxPower * 1.2).toInt();
      }
    }

    if ((_onStageStatisticsType == onStageStatisticsTypeAverage ||
            _onStageStatisticsType == onStageStatisticsTypeAlternating) &&
        _graphAvgData.isNotEmpty) {
      final latestAvgPower = _graphAvgData.last.power;
      if (latestAvgPower != null &&
          latestAvgPower >= minPowerThreshold &&
          latestAvgPower <= maxPowerThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphAvgData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.power,
            color: _chartAvgColor,
            animationDuration: 0,
          ),
        );
      }
    }

    if ((_onStageStatisticsType == onStageStatisticsTypeMaximum ||
            _onStageStatisticsType == onStageStatisticsTypeAlternating) &&
        _graphMaxData.isNotEmpty) {
      final latestMaxPower = _graphMaxData.last.power;
      if (latestMaxPower != null &&
          latestMaxPower >= minPowerThreshold &&
          latestMaxPower <= maxPowerThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphMaxData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.power,
            color: _chartMaxColor,
            animationDuration: 0,
          ),
        );
      }
    }

    return series;
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _speedChartData() {
    List<charts.LineSeries<DisplayRecord, DateTime>> series = [
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: graphData,
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.speedByUnit(_si),
        color: _chartTextColor,
        animationDuration: 0,
      ),
    ];

    double minSpeedThreshold = minInit.toDouble();
    double maxSpeedThreshold = maxInit.toDouble();
    if (_onStageStatisticsType != onStageStatisticsTypeNone) {
      final minSpeed = _graphStats.minSpeed;
      if (minSpeed < minInit) {
        minSpeedThreshold = minSpeed * 0.8;
      }

      final maxSpeed = _graphStats.maxSpeed;
      if (maxSpeed > maxInit) {
        maxSpeedThreshold = maxSpeed * 1.2;
      }
    }

    if ((_onStageStatisticsType == onStageStatisticsTypeAverage ||
            _onStageStatisticsType == onStageStatisticsTypeAlternating) &&
        _graphAvgData.isNotEmpty) {
      final latestAvgSpeed = _graphAvgData.last.speed;
      if (latestAvgSpeed != null &&
          latestAvgSpeed >= minSpeedThreshold &&
          latestAvgSpeed <= maxSpeedThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphAvgData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.speedByUnit(_si),
            color: _chartAvgColor,
            animationDuration: 0,
          ),
        );
      }
    }

    if ((_onStageStatisticsType == onStageStatisticsTypeMaximum ||
            _onStageStatisticsType == onStageStatisticsTypeAlternating) &&
        _graphMaxData.isNotEmpty) {
      final latestMaxSpeed = _graphMaxData.last.speed;
      if (latestMaxSpeed != null &&
          latestMaxSpeed >= minSpeedThreshold &&
          latestMaxSpeed <= maxSpeedThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphMaxData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.speedByUnit(_si),
            color: _chartMaxColor,
            animationDuration: 0,
          ),
        );
      }
    }

    return series;
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _cadenceChartData() {
    List<charts.LineSeries<DisplayRecord, DateTime>> series = [
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: graphData,
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.cadence,
        color: _chartTextColor,
        animationDuration: 0,
      ),
    ];

    int minCadenceThreshold = minInit;
    int maxCadenceThreshold = maxInit;
    if (_onStageStatisticsType != onStageStatisticsTypeNone) {
      final minCadence = _graphStats.minCadence;
      if (minCadence < minInit) {
        minCadenceThreshold = (minCadence * 0.8).toInt();
      }

      final maxCadence = _graphStats.maxCadence;
      if (maxCadence > maxInit) {
        maxCadenceThreshold = (maxCadence * 1.2).toInt();
      }
    }

    if ((_onStageStatisticsType == onStageStatisticsTypeAverage ||
            _onStageStatisticsType == onStageStatisticsTypeAlternating) &&
        _graphAvgData.isNotEmpty) {
      final latestAvgCadence = _graphAvgData.last.cadence;
      if (latestAvgCadence != null &&
          latestAvgCadence >= minCadenceThreshold &&
          latestAvgCadence <= maxCadenceThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphAvgData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.cadence,
            color: _chartAvgColor,
            animationDuration: 0,
          ),
        );
      }
    }

    if ((_onStageStatisticsType == onStageStatisticsTypeMaximum ||
            _onStageStatisticsType == onStageStatisticsTypeAlternating) &&
        _graphMaxData.isNotEmpty) {
      final latestMaxCadence = _graphMaxData.last.cadence;
      if (latestMaxCadence != null &&
          latestMaxCadence >= minCadenceThreshold &&
          latestMaxCadence <= maxCadenceThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphMaxData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.cadence,
            color: _chartMaxColor,
            animationDuration: 0,
          ),
        );
      }
    }

    return series;
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _hRChartData() {
    List<charts.LineSeries<DisplayRecord, DateTime>> series = [
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: graphData,
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.heartRate,
        color: _chartTextColor,
        animationDuration: 0,
      ),
    ];

    int minHrThreshold = minInit;
    int maxHrThreshold = maxInit;
    if (_onStageStatisticsType != onStageStatisticsTypeNone) {
      final minHr = _graphStats.minHeartRate;
      if (minHr < minInit) {
        minHrThreshold = (minHr * 0.8).toInt();
      }

      final maxHr = _graphStats.maxHeartRate;
      if (maxHr > maxInit) {
        maxHrThreshold = (maxHr * 1.2).toInt();
      }
    }

    if ((_onStageStatisticsType == onStageStatisticsTypeAverage ||
            _onStageStatisticsType == onStageStatisticsTypeAlternating) &&
        _graphAvgData.isNotEmpty) {
      final latestAvgHr = _graphAvgData.last.heartRate;
      if (latestAvgHr != null && latestAvgHr >= minHrThreshold && latestAvgHr <= maxHrThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphAvgData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.heartRate,
            color: _chartAvgColor,
            animationDuration: 0,
          ),
        );
      }
    }

    if ((_onStageStatisticsType == onStageStatisticsTypeMaximum ||
            _onStageStatisticsType == onStageStatisticsTypeAlternating) &&
        _graphMaxData.isNotEmpty) {
      final latestMaxHr = _graphMaxData.last.heartRate;
      if (latestMaxHr != null && latestMaxHr >= minHrThreshold && latestMaxHr <= maxHrThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphMaxData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.heartRate,
            color: _chartMaxColor,
            animationDuration: 0,
          ),
        );
      }
    }

    return series;
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _resistanceChartData() {
    List<charts.LineSeries<DisplayRecord, DateTime>> series = [
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: graphData,
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.resistance,
        color: _chartTextColor,
        animationDuration: 0,
      ),
    ];

    int minResistanceThreshold = minInit;
    int maxResistanceThreshold = maxInit;
    if (_onStageStatisticsType != onStageStatisticsTypeNone) {
      final minResistance = _graphStats.minResistance;
      if (minResistance < minInit) {
        minResistanceThreshold = (minResistance * 0.8).toInt();
      }

      final maxResistance = _graphStats.maxResistance;
      if (maxResistance > maxInit) {
        maxResistanceThreshold = (maxResistance * 1.2).toInt();
      }
    }

    if ((_onStageStatisticsType == onStageStatisticsTypeAverage ||
            _onStageStatisticsType == onStageStatisticsTypeAlternating) &&
        _graphAvgData.isNotEmpty) {
      final latestAvgResistance = _graphAvgData.last.resistance;
      if (latestAvgResistance != null &&
          latestAvgResistance >= minResistanceThreshold &&
          latestAvgResistance <= maxResistanceThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphAvgData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.resistance,
            color: _chartAvgColor,
            animationDuration: 0,
          ),
        );
      }
    }

    if ((_onStageStatisticsType == onStageStatisticsTypeMaximum ||
            _onStageStatisticsType == onStageStatisticsTypeAlternating) &&
        _graphMaxData.isNotEmpty) {
      final latestMaxResistance = _graphMaxData.last.resistance;
      if (latestMaxResistance != null &&
          latestMaxResistance >= minResistanceThreshold &&
          latestMaxResistance <= maxResistanceThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphMaxData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.resistance,
            color: _chartMaxColor,
            animationDuration: 0,
          ),
        );
      }
    }

    return series;
  }

  List<charts.LineSeries<DisplayRecord, DateTime>> _inclinationChartData() {
    List<charts.LineSeries<DisplayRecord, DateTime>> series = [
      charts.LineSeries<DisplayRecord, DateTime>(
        dataSource: graphData,
        xValueMapper: (DisplayRecord record, _) => record.timeStamp,
        yValueMapper: (DisplayRecord record, _) => record.inclination,
        color: _chartTextColor,
        animationDuration: 0,
      ),
    ];

    double minInclinationThreshold = minInit.toDouble();
    double maxInclinationThreshold = maxInit.toDouble();
    if (_onStageStatisticsType != onStageStatisticsTypeNone) {
      final minInclination = _graphStats.minInclinationDisplay;
      if (minInclination < minInit.toDouble()) {
        minInclinationThreshold = minInclination * 0.8;
      }

      final maxInclination = _graphStats.maxInclinationDisplay;
      if (maxInclination > maxInit.toDouble()) {
        maxInclinationThreshold = maxInclination * 1.2;
      }
    }

    if (_onStageStatisticsType == onStageStatisticsTypeAverage ||
        _onStageStatisticsType == onStageStatisticsTypeAlternating) {
      final latestAvgInclination = _graphAvgData.last.inclination;
      if (latestAvgInclination != null &&
          latestAvgInclination >= minInclinationThreshold &&
          latestAvgInclination <= maxInclinationThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphAvgData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.inclination,
            color: _chartAvgColor,
            animationDuration: 0,
          ),
        );
      }
    }

    if (_onStageStatisticsType == onStageStatisticsTypeMaximum ||
        _onStageStatisticsType == onStageStatisticsTypeAlternating) {
      final latestMaxInclination = _graphMaxData.last.inclination;
      if (latestMaxInclination != null &&
          latestMaxInclination >= minInclinationThreshold &&
          latestMaxInclination <= maxInclinationThreshold) {
        series.add(
          charts.LineSeries<DisplayRecord, DateTime>(
            dataSource: graphMaxData,
            xValueMapper: (DisplayRecord record, _) => record.timeStamp,
            yValueMapper: (DisplayRecord record, _) => record.inclination,
            color: _chartMaxColor,
            animationDuration: 0,
          ),
        );
      }
    }

    return series;
  }

  Color _getZoneColor(int metricIndex, bool background) {
    if (_zoneIndexes[metricIndex] == null) {
      return background ? Colors.transparent : _themeManager.getProtagonistColor();
    }

    if (background) {
      return _paletteSpec?.bgColorByBin(
            _zoneIndexes[metricIndex]!,
            _isLight,
            _preferencesSpecs[metricIndex],
          ) ??
          PaletteSpec.bgColorByBinDefault(
            _zoneIndexes[metricIndex]!,
            _isLight,
            _preferencesSpecs[metricIndex],
          );
    }

    return _paletteSpec?.fgColorByBin(
          _zoneIndexes[metricIndex]!,
          _isLight,
          _preferencesSpecs[metricIndex],
        ) ??
        PaletteSpec.fgColorByBinDefault(
          _zoneIndexes[metricIndex]!,
          _isLight,
          _preferencesSpecs[metricIndex],
        );
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
        _averageSpeeds.addAll([
          for (var i = 0; i < averageSpeedSmoothingWindowSizeDefault; ++i) averageSpeed,
        ]);
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

      rank++;
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

  Color _getSpeedColor(int selfRank, {required bool background}) {
    if (!_leaderboardFeature || selfRank == 0) {
      if (_zoneIndexes[_speedNIndex] != null) {
        return _getZoneColor(_speedNIndex, background);
      } else {
        return background ? Colors.transparent : _themeManager.getBlueColor();
      }
    }

    if (selfRank <= 1) {
      return background ? _lightGreen : _darkGreen;
    }

    return background ? _lightBlue : _darkBlue;
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
      return _getZoneColor(_hrNIndex, background);
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
    final measurementStyle = getMeasurementStyle(_hr0Index);
    if (hrState == TargetHrState.off) {
      if (_zoneIndexes[_hrNIndex] == null) {
        return measurementStyle.apply();
      } else {
        return measurementStyle.apply(color: _getZoneColor(_hrNIndex, false));
      }
    }

    return measurementStyle.apply(color: _getTargetHrColor(hrState, false));
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
      markers.add(
        _getTrackMarker(
          position,
          isPacer ? pacerColor : markerColor,
          isPacer ? pacerText : "$rank",
          false,
        ),
      );
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
        final isPacer = _addLeaderboardTrackMarker(
          0xFF00FF00,
          leaderboard[rank - 3],
          rank - 2,
          markers,
        );
        wasPacer |= isPacer;
      }

      // Preceding dot (chasing directly) if any
      if (rank > 1 && rank - 2 < length) {
        final isPacer = _addLeaderboardTrackMarker(
          0xFF00FF00,
          leaderboard[rank - 2],
          rank - 1,
          markers,
        );
        wasPacer |= isPacer;
      }

      // Following dot (following directly) if any
      if (rank - 1 < length) {
        final isPacer = _addLeaderboardTrackMarker(
          0xFF0000FF,
          leaderboard[rank - 1],
          rank + 1,
          markers,
        );
        wasPacer |= isPacer;
      }

      // Following dot after the follower (if any)
      if (rank < length) {
        final isPacer = _addLeaderboardTrackMarker(
          0xFF0000FF,
          leaderboard[rank],
          rank + 2,
          markers,
        );
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
        isPacer ? _getPacerInfoText() : _getLeaderboardInfoText(rank - 2, distance, speed, true),
      );
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
        isPacer ? _getPacerInfoText() : _getLeaderboardInfoText(rank - 1, distance, speed, true),
      );
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
        _si,
        _selfAvgSpeed,
        widget.descriptor.slowPace,
        widget.sport,
      );
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
      cells.addAll(
        isPacer ? _getPacerInfoText() : _getLeaderboardInfoText(rank + 1, distance, speed, false),
      );
      rowCount++;
      wasPacer |= isPacer;
    }

    // Following dot after the follower (if any)
    if (rank < length) {
      final isPacer = leaderboard[rank].isPacer;
      final distance = leaderboard[rank].distanceAtTime(_elapsed);
      final speed = _avgSpeedOnTrack
          ? leaderboard[rank].speedString(_si, widget.descriptor.slowPace)
          : "";
      cells.addAll(
        isPacer ? _getPacerInfoText() : _getLeaderboardInfoText(rank + 2, distance, speed, false),
      );
      rowCount++;
      wasPacer |= isPacer;
    }

    if (_showPacer && !wasPacer && _pacerWorkout!.speed < leaderboard[rank].speed) {
      cells.addAll(_getPacerInfoText());
      rowCount++;
      wasPacer = true;
    }

    final innerWidth =
        _trackCalculator!.trackSize!.width -
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

  Future<void> startStopAction() async {
    if (_measuring) {
      if (_circuitWorkout && !_uxDebug) {
        final selection = await Get.bottomSheet(
          const SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: ThreeChoicesBottomSheet(
                      title:
                          "Circuit workout in progress, use pause to move to a new machine without stopping the workout",
                      verticalActions: true,
                      firstChoice: "Continue workout",
                      secondChoice: "Finish on THIS machine for good",
                      thirdChoice: "Finish an ALL machines (the whole circuit workout is over)",
                    ),
                  ),
                ),
              ],
            ),
          ),
          isScrollControlled: true,
          ignoreSafeArea: false,
          isDismissible: false,
          enableDrag: false,
        );
        if (selection > 0) {
          await _stopMeasurement(false);
          if (selection > 1) {
            final dbUtils = this.dbUtils;
            final unfinished = await dbUtils.unfinishedActivities();
            for (final activity in unfinished) {
              await dbUtils.finalizeActivity(activity);
            }
          }
        }
      } else {
        await _stopMeasurement(false);
      }
    } else {
      await _startMeasurement(true);
    }
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

  TextStyle getMeasurementStyle(int entryKey) {
    return ([_calories0Index, _distance0Index].contains(entryKey) ||
            _onStageStatisticsType == onStageStatisticsTypeNone)
        ? _fullMeasurementStyle.apply()
        : _measurementStyle.apply();
  }

  double getExpandedHeight(int heightSetting, Size measuredHeight) {
    var height = 0.0;
    switch (heightSetting) {
      case 0:
        height = measuredHeight.height / 4;
        break;
      case 1:
        height = measuredHeight.height / 3;
        break;
      case 2:
        height = measuredHeight.height / 2;
        break;
    }

    return height;
  }

  void _onTutorial() {
    final legendList = [
      const Tuple2<IconData, String>(Icons.whatshot, "Calories"),
      const Tuple2<IconData, String>(Icons.add_road, "Distance"),
      const Tuple2<IconData, String>(Icons.timer, "Elapsed / moving time"),
      const Tuple2<IconData, String>(Icons.bolt, "Power (Watts)"),
      const Tuple2<IconData, String>(Icons.speed, "Speed"),
      const Tuple2<IconData, String>(Icons.directions_bike, "Bike Cadence"),
      const Tuple2<IconData, String>(Icons.directions_run, "Running Cadence"),
      const Tuple2<IconData, String>(Icons.rowing, "Rowing Cadence"),
      const Tuple2<IconData, String>(Icons.downhill_skiing, "X Train / Ski Cadence"),
      const Tuple2<IconData, String>(Icons.stairs, "Stair Step / Climb Cadence"),
      const Tuple2<IconData, String>(Icons.numbers, "Revolutions / steps"),
      const Tuple2<IconData, String>(Icons.lock_open, "Lock Screen"),
      const Tuple2<IconData, String>(Icons.cloud_upload, "Upload Workout"),
      const Tuple2<IconData, String>(Icons.list_alt, "Workout List"),
      const Tuple2<IconData, String>(Icons.battery_unknown, "Battery & Extras"),
      const Tuple2<IconData, String>(Icons.build, "Calibration"),
      const Tuple2<IconData, String>(Icons.favorite, "HR / HRM Pairing"),
      const Tuple2<IconData, String>(Icons.stop, "Stop Workout"),
      const Tuple2<IconData, String>(Icons.play_arrow, "Start Workout"),
    ];
    if (!_instantOnStage && _onStageStatisticsType != onStageStatisticsTypeNone) {
      legendList.add(const Tuple2<IconData, String>(Icons.sports_score, "On/Off Stage (Stats)"));
    }
    legendDialog(legendList);
  }

  void _onLock() {
    _unlockButtonIndex = _rng.nextInt(_unlockChoices);
    _fabKey.currentState?.close();
    setState(() {
      _isLocked = true;
    });
  }

  void _handleOnStage() {
    setState(() {
      _onStage = !_onStage;
      if (!_onStage) {
        _statistics[_power0Index] = emptyMeasurement;
        _statistics[_speed0Index] = emptyMeasurement;
        _statistics[_cadence0Index] = emptyMeasurement;
        _statistics[_hr0Index] = emptyMeasurement;

        if (_showResistanceLevel) {
          _optionalStatistics[_resistanceIndex] = emptyMeasurement;
        }
      }

      _workoutStats.reset();
    });
  }

  Future<void> _onHrmPairing() async {
    await Get.bottomSheet(
      const SafeArea(
        child: Column(
          children: [Expanded(child: Center(child: HeartRateMonitorPairingBottomSheet()))],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
      isDismissible: false,
      enableDrag: false,
    );
    String hrmId = await _initializeHeartRateMonitor(true);
    if (hrmId.isNotEmpty && _activity != null && (_activity!.hrmId != hrmId)) {
      _activity!.hrmId = hrmId;
      _activity!.hrmCalorieFactor = await dbUtils.calorieFactorValue(hrmId, true);
      _database.writeTxnSync(() {
        _database.activitys.putSync(_activity!);
      });
    }
  }

  Widget _buildSmallScreenLayout(List<Widget> rows) {
    // 2x2 Grid: HR, Power, Speed, Cadence
    // Indices in rows (shifted by 1 for Header):
    // HR: _hr1Index + 1, Power: _power1Index + 1, Speed: _speed1Index + 1, Cadence: _cadence1Index + 1
    // Footer: Distance: _distance1Index + 1
    // Header: Time (rows[0] is HeaderRow, but we might want a simpler one or reuse it)

    // Ensure we have enough rows
    if (rows.length <= _distance1Index + 1) {
      return ListView(children: rows); // Fallback
    }

    final gridChildren = [
      rows[_hr1Index + 1], // Top-Left
      rows[_power1Index + 1], // Top-Right
      rows[_speed1Index + 1], // Bottom-Left
      rows[_cadence1Index + 1], // Bottom-Right
    ];

    return Column(
      children: [
        SizedBox(
          height: 40,
          child: FittedBox(child: rows[0]), // Header, scaled down
        ),
        SizedBox(height: 30, child: FittedBox(child: rows[_distance1Index + 1])),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.3, // Squarish logic
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: gridChildren.map((w) => FittedBox(fit: BoxFit.scaleDown, child: w)).toList(),
          ),
        ),
      ],
    );
  }

  /// Recomputes cached layout metrics (sizes, text styles) derived from the
  /// current [measuredSize] whenever it changes meaningfully.
  void _updateLayoutMetrics(Size measuredSize) {
    if (measuredSize.width != _mediaWidth || measuredSize.height != _mediaHeight) {
      _mediaWidth = measuredSize.width;
      _mediaHeight = measuredSize.height;
      _landscape = _mediaWidth > _mediaHeight;
    }

    final mediaSizeMin = _landscape && _twoColumnLayout
        ? _mediaWidth / 2
        : min(_mediaWidth, _mediaHeight);
    if (_mediaSizeMin < eps || (_mediaSizeMin - mediaSizeMin).abs() > eps) {
      _mediaSizeMin = mediaSizeMin;
      _sizeDefault = mediaSizeMin / 8 * _sizeAdjust;
      _measurementStyle = TextStyle(fontFamily: fontFamily, fontSize: _sizeDefault * 0.75);
      _halfWidthNonExpandable = (_mediaSizeMin - max(_sizeDefault / 2, _sizeDefault)) / 2;
      _halfWidthExpandable =
          (_mediaSizeMin - max(_sizeDefault / 2, _sizeDefault * 0.65) - 48.0) / 2;
      _fullMeasurementStyle = TextStyle(fontFamily: fontFamily, fontSize: _sizeDefault);
      _timeStyle = TextStyle(fontFamily: fontFamily, fontSize: _sizeDefault / 1.8);
      _unitStyle = _themeManager.getBlueTextStyle(_sizeDefault / 6);
      _fullUnitStyle = _themeManager.getBlueTextStyle(_sizeDefault / 3);
    }
  }

  /// Plays or stops the target heart rate audio alert based on the latest
  /// heart rate reading versus the configured target bounds.
  void _maybeAlertTargetHeartRate() {
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
          Get.find<SoundService>().stopSoundEffect();
        }
        _targetHrAlerting = false;
      }
    }
  }

  /// Computes the moving/elapsed/single time display strings, the current
  /// [WorkoutState], and the "moving"/"elapsed" column header row.
  ({
    String movingTimeDisplay,
    String elapsedTimeDisplay,
    String timeDisplay,
    WorkoutState workoutState,
    Widget timeHeaderRow,
  })
  _buildTimeDisplays() {
    final movingTimeDisplay = _onStageStatisticsType != onStageStatisticsTypeNone
        ? Duration(seconds: _movingTime ~/ 1000).toDisplay()
        : "";
    final elapsedTimeDisplay = _onStageStatisticsType != onStageStatisticsTypeNone
        ? Duration(seconds: _elapsed).toDisplay()
        : "";
    final timeDisplay = _onStageStatisticsType == onStageStatisticsTypeNone
        ? Duration(
            seconds: _timeDisplayMode == timeDisplayModeMoving ? _movingTime ~/ 1000 : _elapsed,
          ).toDisplay()
        : "";

    final workoutState = _fitnessEquipment?.workoutState ?? WorkoutState.waitingForFirstMove;
    final timeHeaderRow = _onStageStatisticsType != onStageStatisticsTypeNone
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text("moving", style: _unitStyle),
              const Spacer(),
              Text("elapsed", style: _unitStyle),
              const Spacer(),
            ],
          )
        : Container();

    return (
      movingTimeDisplay: movingTimeDisplay,
      elapsedTimeDisplay: elapsedTimeDisplay,
      timeDisplay: timeDisplay,
      workoutState: workoutState,
      timeHeaderRow: timeHeaderRow,
    );
  }

  /// Builds the measurement row widgets (header row plus one row per
  /// configured metric), along with the target heart rate state/style and
  /// the speed row's text style - both of which downstream extras/columns
  /// need to stay visually consistent with these rows.
  ({
    List<Widget> rows,
    TargetHrState targetHrState,
    TextStyle targetHrTextStyle,
    TextStyle? speedTextStyle,
  })
  _buildMeasurementRows({
    required String movingTimeDisplay,
    required String elapsedTimeDisplay,
    required String timeDisplay,
    required WorkoutState workoutState,
  }) {
    List<Widget> rows = [
      RecordingHeaderRow(
        themeManager: _themeManager,
        onStageStatisticsType: _onStageStatisticsType,
        movingTimeDisplay: movingTimeDisplay,
        elapsedTimeDisplay: elapsedTimeDisplay,
        singleTimeDisplay: timeDisplay,
        timeDisplayMode: _timeDisplayMode,
        workoutState: workoutState,
        paletteSpec: _paletteSpec,
        baseTimeStyle: _onStageStatisticsType != onStageStatisticsTypeNone
            ? _timeStyle
            : _fullMeasurementStyle,
        measurementStyle: _measurementStyle,
        iconSize: _sizeDefault,
      ),
    ];

    final targetHrState = _getTargetHrState();
    final targetHrTextStyle = _getTargetHrTextStyle(targetHrState);
    TextStyle? speedTextStyle;

    for (var entry in _rowConfig.asMap().entries) {
      var measurementStyle = getMeasurementStyle(entry.key);
      Color? rowColor;

      if (entry.key == _speed0Index &&
          !_stationaryWorkout &&
          (_leaderboardFeature || _zoneIndexes[_speedNIndex] != null)) {
        rowColor = _getSpeedColor(_selfRank, background: false);
        speedTextStyle = measurementStyle.apply(color: rowColor);
        measurementStyle = speedTextStyle;
      }

      if (entry.key == _hr0Index &&
          (_targetHrMode != targetHeartRateModeNone || _zoneIndexes[_hrNIndex] != null)) {
        measurementStyle = targetHrTextStyle;
        rowColor = measurementStyle.color;
      }

      if ((entry.key == _power0Index && !_stationaryWorkout || entry.key == _cadence0Index) &&
          _zoneIndexes[entry.key - 1] != null) {
        rowColor = _getZoneColor(entry.key - 1, false);
        measurementStyle = measurementStyle.apply(color: rowColor);
      }

      MeasurementRowLayout layout = MeasurementRowLayout.split;
      if (_stationaryWorkout && [_power0Index, _speed0Index, _distance0Index].contains(entry.key)) {
        layout = MeasurementRowLayout.divider;
      } else if ([_calories0Index, _distance0Index].contains(entry.key) ||
          _onStageStatisticsType == onStageStatisticsTypeNone) {
        layout = MeasurementRowLayout.standard;
      }

      rows.add(
        MeasurementRow(
          themeManager: _themeManager,
          layout: layout,
          icon: entry.value.icon,
          iconColor: rowColor,
          iconSize: _sizeDefault,
          value: _values[entry.key],
          unit: entry.value.unit,
          statistic: _statistics[entry.key],
          measurementStyle: measurementStyle,
          unitStyle: _unitStyle,
          fullUnitStyle: _fullUnitStyle,
          expandable: entry.value.expandable,
          simplerUi: _simplerUi,
          halfWidth: _simplerUi ? _halfWidthNonExpandable : _halfWidthExpandable,
        ),
      );
    }

    return (
      rows: rows,
      targetHrState: targetHrState,
      targetHrTextStyle: targetHrTextStyle,
      speedTextStyle: speedTextStyle,
    );
  }

  /// Builds the "current"/"average or maximum" statistics header row shown
  /// above the on-stage statistics column.
  Widget _buildStatHeaderRow() {
    final statString =
        ([
              onStageStatisticsTypeAverage,
              onStageStatisticsTypeNone,
            ].contains(_onStageStatisticsType) ||
            _onStageStatisticsType == onStageStatisticsTypeAlternating &&
                _elapsed % (_onStageStatisticsAlternationDuration * 2) <
                    _onStageStatisticsAlternationDuration)
        ? "average"
        : "maximum";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Text("current", style: _unitStyle),
        const Spacer(),
        Text(statString, style: _unitStyle),
        const Spacer(),
      ],
    );
  }

  /// Builds the expandable "extras" (per-metric charts, plus the optional
  /// resistance/inclination charts) and the track visualization that gets
  /// appended to [regularExtras], mirroring the metric rows built by
  /// [_buildMeasurementRows]. Returns empty lists when the simpler UI is in
  /// effect, since none of these extras are shown in that mode.
  ({List<Widget?> regularExtras, List<Widget> extras}) _buildExtrasAndTrack({
    required Size measuredSize,
    required TargetHrState targetHrState,
    required TextStyle targetHrTextStyle,
    required TextStyle? speedTextStyle,
  }) {
    List<Widget?> regularExtras = [];
    List<Widget> extras = [];
    if (!_simplerUi) {
      if (_showResistanceLevel) {
        extras.add(
          SizedBox(
            width: measuredSize.width,
            height: getExpandedHeight(_extraExpandedHeights[_resistanceIndex], measuredSize),
            child: RecordingChart(
              chartLabelStyle: _chartLabelStyle,
              chartTextColor: _chartTextColor,
              graphViewDuration: _graphViewDuration,
              series: _resistanceChartData(),
              onTouchDown: (arg) =>
                  _onChartTouchInteractionDown(_resistanceIndex, arg.position, true),
              onTouchUp: (arg) => _onChartTouchInteractionUp(_resistanceIndex, arg.position, true),
            ),
          ),
        );
      }

      if (_showInclination) {
        extras.add(
          SizedBox(
            width: measuredSize.width,
            height: getExpandedHeight(_extraExpandedHeights[_inclinationIndex], measuredSize),
            child: RecordingChart(
              chartLabelStyle: _chartLabelStyle,
              chartTextColor: _chartTextColor,
              graphViewDuration: _graphViewDuration,
              series: _inclinationChartData(),
              onTouchDown: (arg) =>
                  _onChartTouchInteractionDown(_inclinationIndex, arg.position, true),
              onTouchUp: (arg) => _onChartTouchInteractionUp(_inclinationIndex, arg.position, true),
            ),
          ),
        );
      }

      for (var entry in _preferencesSpecs.asMap().entries) {
        if (_stationaryWorkout && ["speed", "power"].contains(entry.value.metric)) {
          regularExtras.add(null);
          continue;
        }

        Widget extra = SizedBox(
          width: measuredSize.width,
          height: getExpandedHeight(_expandedHeights[entry.key], measuredSize),
          child: RecordingChart(
            chartLabelStyle: _chartLabelStyle,
            chartTextColor: _chartTextColor,
            graphViewDuration: _graphViewDuration,
            series: _metricToDataFn[entry.value.metric]!(),
            plotBands: _hasDataForMetric(entry.value.metric)
                ? _safeGetPlotBands(entry.value.plotBands)
                : <charts.PlotBand>[],
            onTouchDown: (arg) => _onChartTouchInteractionDown(entry.key, arg.position, false),
            onTouchUp: (arg) => _onChartTouchInteractionUp(entry.key, arg.position, false),
          ),
        );

        if (entry.value.metric == "hr" && _targetHrMode != targetHeartRateModeNone) {
          int zoneIndex = targetHrState == TargetHrState.off
              ? 0
              : entry.value.binIndex(_heartRate ?? 0) + 1;
          String targetText = _getTargetHrText(targetHrState);
          targetText = "Z$zoneIndex $targetText";
          extra = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(targetText, style: targetHrTextStyle),
              extra,
            ],
          );
        } else if (entry.value.metric == "speed" &&
            _leaderboardFeature &&
            _rankRibbonVisualization) {
          List<Widget> regularExtraExtras = [];
          regularExtraExtras.add(Text(_selfRankString.join(" "), style: speedTextStyle));

          if (widget.descriptor.sport != ActivityType.ride) {
            regularExtraExtras.add(Text("Speed ${_si ? 'km' : 'mi'}/h"));
          }

          regularExtraExtras.add(extra);
          extra = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: regularExtraExtras,
          );
        }

        regularExtras.add(extra);
      }

      List<Widget> markers = [];
      final markerPosition = _stationaryWorkout ? null : _trackCalculator?.trackMarker(_distance);
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
              Center(child: _infoForLeaderboard(_leaderboard, _selfRank, _selfRankString)),
            );
          }

          // Add red circle around the athlete marker to distinguish
          markers.add(_getTrackMarker(markerPosition, selfMarkerColor, "", false));
          selfMarkerColor = _getSpeedColor(_selfRank, background: true).toARGB32();
        } else if (_displayLapCounter) {
          markers.add(Center(child: Text("Lap $_lapCount", style: _measurementStyle)));
        }

        markers.add(
          _getTrackMarker(markerPosition, selfMarkerColor, selfMarkerText, _rankTrackVisualization),
        );
      }

      if (_trackCalculator != null) {
        regularExtras.add(
          TrackVisualization(
            calculator: _trackCalculator!,
            markers: markers,
            width: measuredSize.width,
          ),
        );
      }
    }

    return (regularExtras: regularExtras, extras: extras);
  }

  /// Assembles the two display columns (used side by side in landscape with
  /// the two-column layout, or stacked into a single column otherwise) from
  /// the previously built [rows], header rows, and extras.
  ({List<Widget> columnOne, List<Widget> columnTwo}) _buildColumns({
    required List<Widget> rows,
    required Widget timeHeaderRow,
    required Widget statHeaderRow,
    required List<Widget> extras,
    required List<Widget?> regularExtras,
    required TargetHrState targetHrState,
  }) {
    List<Widget> columnOne = _onStageStatisticsType != onStageStatisticsTypeNone
        ? [timeHeaderRow]
        : [];
    List<Widget> columnTwo = _onStageStatisticsType != onStageStatisticsTypeNone
        ? [statHeaderRow]
        : [];

    columnOne.addAll([rows[_time1Index], rows[_calories1Index]]);

    if (_onStageStatisticsType != onStageStatisticsTypeNone) {
      columnOne.add(statHeaderRow);
    }

    if (_showResistanceLevel) {
      final resistanceLayout = _onStageStatisticsType == onStageStatisticsTypeNone
          ? MeasurementRowLayout.standard
          : MeasurementRowLayout.split;

      columnOne.add(
        ExpandablePanel(
          theme: _expandableThemeData,
          header: MeasurementRow(
            themeManager: _themeManager,
            layout: resistanceLayout,
            icon: Icons.onetwothree,
            iconSize: _sizeDefault,
            value: _optionalValues[_resistanceIndex],
            unit: "",
            statistic: _optionalStatistics[_resistanceIndex],
            measurementStyle: resistanceLayout == MeasurementRowLayout.standard
                ? _fullMeasurementStyle
                : _measurementStyle,
            unitStyle: _unitStyle,
            fullUnitStyle: _fullUnitStyle,
            expandable: true,
            simplerUi: _simplerUi,
            halfWidth: _simplerUi ? _halfWidthNonExpandable : _halfWidthExpandable,
          ),
          collapsed: Container(),
          expanded: _simplerUi ? Container() : extras[_resistanceIndex],
          controller: _extraRowControllers[_resistanceIndex],
        ),
      );
    }

    if (_showInclination) {
      final inclinationLayout = _onStageStatisticsType == onStageStatisticsTypeNone
          ? MeasurementRowLayout.standard
          : MeasurementRowLayout.split;

      columnOne.add(
        ExpandablePanel(
          theme: _expandableThemeData,
          header: MeasurementRow(
            themeManager: _themeManager,
            layout: inclinationLayout,
            icon: Icons.terrain,
            iconSize: _sizeDefault,
            value: _optionalValues[_inclinationIndex],
            unit: "%",
            statistic: _optionalStatistics[_inclinationIndex],
            measurementStyle: inclinationLayout == MeasurementRowLayout.standard
                ? _fullMeasurementStyle
                : _measurementStyle,
            unitStyle: _unitStyle,
            fullUnitStyle: _fullUnitStyle,
            expandable: true,
            simplerUi: _simplerUi,
            halfWidth: _simplerUi ? _halfWidthNonExpandable : _halfWidthExpandable,
          ),
          collapsed: Container(),
          expanded: _simplerUi ? Container() : extras[_inclinationIndex],
          controller: _extraRowControllers[_inclinationIndex],
        ),
      );
    }

    if (_stationaryWorkout) {
      columnOne.addAll([const Divider(), const Divider()]);
    } else {
      columnOne.addAll([
        ColoredBox(
          color: _getZoneColor(_powerNIndex, true),
          child: ExpandablePanel(
            theme: _expandableThemeData,
            header: rows[_power1Index],
            collapsed: Container(),
            expanded: _simplerUi ? Container() : regularExtras[_powerNIndex]!,
            controller: _rowControllers[_powerNIndex],
          ),
        ),
        ColoredBox(
          color: _getSpeedColor(_selfRank, background: true),
          child: ExpandablePanel(
            theme: _expandableThemeData,
            header: rows[_speed1Index],
            collapsed: Container(),
            expanded: _simplerUi ? Container() : regularExtras[_speedNIndex]!,
            controller: _rowControllers[_speedNIndex],
          ),
        ),
      ]);
    }

    List<Widget> columnRest = [
      ColoredBox(
        color: _getZoneColor(_cadenceNIndex, true),
        child: ExpandablePanel(
          theme: _expandableThemeData,
          header: rows[_cadence1Index],
          collapsed: Container(),
          expanded: _simplerUi ? Container() : regularExtras[_cadenceNIndex]!,
          controller: _rowControllers[_cadenceNIndex],
        ),
      ),
      ColoredBox(
        color: _getTargetHrColor(targetHrState, true),
        child: ExpandablePanel(
          theme: _expandableThemeData,
          header: rows[_hr1Index],
          collapsed: Container(),
          expanded: _simplerUi ? Container() : regularExtras[_hrNIndex]!,
          controller: _rowControllers[_hrNIndex],
        ),
      ),
    ];

    if (_showStrokesStridesRevs) {
      columnRest.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _themeManager.getBlueIcon(Icons.numbers, _sizeDefault),
            const Spacer(),
            Text(_optionalValues[_strokeCountIndex], style: _fullMeasurementStyle.apply()),
            SizedBox(
              width: _sizeDefault * 2,
              child: Center(child: Text("#", style: _fullUnitStyle)),
            ),
          ],
        ),
      );
    }

    columnRest.add(
      _stationaryWorkout
          ? const Divider()
          : ExpandablePanel(
              theme: _expandableThemeData,
              header: rows[_distance1Index],
              collapsed: Container(),
              expanded: _simplerUi ? Container() : regularExtras[_distanceNIndex]!,
              controller: _rowControllers[_distanceNIndex],
            ),
    );

    if (_landscape && _twoColumnLayout) {
      columnTwo.addAll(columnRest);
    } else {
      columnOne.addAll(columnRest);
    }

    return (columnOne: columnOne, columnTwo: columnTwo);
  }

  /// Builds the scrollable body: a single column on small screens, two
  /// side-by-side columns in landscape with the two-column layout enabled,
  /// or a single scrolling column otherwise.
  Widget _buildBody(
    BuildContext context,
    List<Widget> rows,
    List<Widget> columnOne,
    List<Widget> columnTwo,
  ) {
    return isSmallScreen(context)
        ? _buildSmallScreenLayout(rows)
        : (_landscape && _twoColumnLayout
              ? GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: _mediaWidth / _mediaHeight / 2,
                  physics: const NeverScrollableScrollPhysics(),
                  semanticChildCount: 2,
                  children: [
                    ListView(children: columnOne),
                    ListView(children: columnTwo),
                  ],
                )
              : ListView(children: columnOne));
  }

  /// Builds the app bar's action buttons (play/stop, plus pause when a
  /// circuit workout is in progress).
  List<Widget> _buildAppBarActions() {
    final actions = [
      IconButton(
        icon: Icon(_measuring ? Icons.stop : Icons.play_arrow),
        onPressed: () async {
          await startStopAction();
        },
      ),
    ];

    if (_circuitWorkout && _measuring) {
      actions.insert(0, IconButton(icon: const Icon(Icons.pause), onPressed: () => Get.back()));
    }

    return actions;
  }

  /// Handles the lock-screen unlock gesture's tap-up: completes the unlock
  /// sequence if the matching button was tapped twice in a row, otherwise
  /// resets the in-progress unlock choice.
  void _handleUnlockTapUp(TapUpDetails details) {
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
  }

  /// Handles the lock-screen unlock gesture's tap-down: records which
  /// unlock choice (or the FAB itself) the tap started on.
  void _handleUnlockTapDown(TapDownDetails details) {
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
  }

  @override
  Widget build(BuildContext context) {
    final measuredSize = Get.mediaQuery.size;
    _updateLayoutMetrics(measuredSize);
    _maybeAlertTargetHeartRate();

    final timeDisplays = _buildTimeDisplays();
    final workoutState = timeDisplays.workoutState;
    final timeHeaderRow = timeDisplays.timeHeaderRow;

    final measurementRows = _buildMeasurementRows(
      movingTimeDisplay: timeDisplays.movingTimeDisplay,
      elapsedTimeDisplay: timeDisplays.elapsedTimeDisplay,
      timeDisplay: timeDisplays.timeDisplay,
      workoutState: workoutState,
    );
    List<Widget> rows = measurementRows.rows;
    final targetHrState = measurementRows.targetHrState;
    final targetHrTextStyle = measurementRows.targetHrTextStyle;
    TextStyle? speedTextStyle = measurementRows.speedTextStyle;

    final statHeaderRow = _buildStatHeaderRow();

    final extrasAndTrack = _buildExtrasAndTrack(
      measuredSize: measuredSize,
      targetHrState: targetHrState,
      targetHrTextStyle: targetHrTextStyle,
      speedTextStyle: speedTextStyle,
    );
    var regularExtras = extrasAndTrack.regularExtras;
    var extras = extrasAndTrack.extras;

    final columns = _buildColumns(
      rows: rows,
      timeHeaderRow: timeHeaderRow,
      statHeaderRow: statHeaderRow,
      extras: extras,
      regularExtras: regularExtras,
      targetHrState: targetHrState,
    );
    List<Widget> columnOne = columns.columnOne;
    List<Widget> columnTwo = columns.columnTwo;

    final body = _buildBody(context, rows, columnOne, columnTwo);
    final actions = _buildAppBarActions();

    return PopScope(
      canPop: !_measuring || _circuitWorkout,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTapUp: _handleUnlockTapUp,
        onTapDown: _handleUnlockTapDown,
        child: AbsorbPointer(
          absorbing: _isLocked,
          child: Scaffold(
            appBar: isSmallScreen(context)
                ? null
                : AppBar(
                    title: TextOneLine(widget.device.nonEmptyName, overflow: TextOverflow.ellipsis),
                    actions: _busy
                        ? [
                            HeartbeatProgressIndicator(
                              child: IconButton(
                                icon: const Icon(Icons.hourglass_empty),
                                onPressed: () => {},
                              ),
                            ),
                          ]
                        : actions,
                  ),
            body: body,
            floatingActionButtonLocation: isSmallScreen(context)
                ? FloatingActionButtonLocation.centerFloat
                : FloatingActionButtonLocation.centerDocked,
            floatingActionButton: RecordingFabMenu(
              themeManager: _themeManager,
              fabKey: _fabKey,
              isLocked: _isLocked,
              measuring: _measuring,
              busy: _busy,
              circuitWorkout: _circuitWorkout,
              heartRateMonitorWorkout: _heartRateMonitorWorkout,
              fitnessEquipment: _fitnessEquipment,
              instantOnStage: _instantOnStage,
              onStageStatisticsType: _onStageStatisticsType,
              onStartStop: startStopAction,
              onUpload: () => _activityUpload(false),
              onLock: _onLock,
              onUnlock: () {
                _fabKey.currentState?.close();
                setState(() {
                  _isLocked = false;
                });
              },
              onStage: _handleOnStage,
              onTutorial: _onTutorial,
              onHrmPairing: _onHrmPairing,
              onCadencePairing: _onCadencePairing,
              unlockKeys: _unlockKeys,
              unlockButtonIndex: _unlockButtonIndex,
              unlockChoices: _unlockChoices,
            ),
          ),
        ),
      ),
    );
  }
}
