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
import 'package:flutter_brand_icons/flutter_brand_icons.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:wakelock/wakelock.dart';
import '../devices/device_descriptors/device_descriptor.dart';
import '../devices/gadgets/fitness_equipment.dart';
import '../devices/gadgets/heart_rate_monitor.dart';
import '../devices/bluetooth_device_ex.dart';
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
import 'models/advertisement_digest.dart';
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
  final AdvertisementDigest advertisementDigest;
  final BluetoothDeviceState initialState;
  final Size size;
  final String sport;

  RecordingScreen({
    Key key,
    @required this.device,
    @required this.advertisementDigest,
    @required this.initialState,
    @required this.size,
    @required this.sport,
  })  : assert(device != null),
        assert(advertisementDigest != null),
        assert(initialState != null),
        assert(size != null),
        assert(sport != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RecordingState(
      device: device,
      advertisementDigest: advertisementDigest,
      initialState: initialState,
      size: size,
      sport: sport,
    );
  }
}

class RecordingState extends State<RecordingScreen> {
  RecordingState({
    @required this.device,
    @required this.advertisementDigest,
    @required this.initialState,
    @required this.size,
    @required this.sport,
  })  : assert(device != null),
        assert(advertisementDigest != null),
        assert(initialState != null),
        assert(size != null),
        assert(sport != null) {
    this._descriptor = device.getDescriptor(advertisementDigest.serviceUuids);
  }

  Size size;
  final BluetoothDevice device;
  final AdvertisementDigest advertisementDigest;
  final BluetoothDeviceState initialState;
  final String sport;
  FitnessEquipment _fitnessEquipment;
  HeartRateMonitor _heartRateMonitor;
  DeviceDescriptor _descriptor;
  TrackCalculator _trackCalculator;
  bool _measuring;
  int _pointCount;
  ListQueue<DisplayRecord> _graphData;
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _measurementStyle;
  TextStyle _unitStyle;
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

  Timer _connectionWatchdog;
  int _connectionWatchdogTime = EQUIPMENT_DISCONNECTION_WATCHDOG_DEFAULT_INT;

  List<DisplayRecord> get graphData => _graphData.toList();
  Map<String, DataFn> _metricToDataFn = {};
  List<RowConfiguration> _rowConfig;
  List<String> _values;
  double _distance;
  int _elapsed;

  String _targetHrMode;
  Tuple2<double, double> _targetHrBounds;
  int _heartRate;
  Timer _beepPeriodTimer;
  int _beepPeriod = TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT_INT;
  bool _targetHrAudio;
  bool _targetHrAlerting;
  bool _leaderboardFeature;
  bool _waveLightForDevice;
  List<WorkoutSummary> _deviceLeaderboard;
  bool _waveLightForSport;
  List<WorkoutSummary> _sportLeaderboard;
  Color _darkRed;
  Color _darkGreen;
  Color _darkBlue;
  Color _lightRed;
  Color _lightGreen;
  Color _lightBlue;

  Future<void> _connectOnDemand(BluetoothDeviceState deviceState) async {
    bool success = await _fitnessEquipment.connectOnDemand(deviceState);
    if (success) {
      if (PrefService.getBool(INSTANT_MEASUREMENT_START_TAG)) {
        await _startMeasurement();
      }
    } else {
      Get.defaultDialog(
        middleText: 'Problem co-operating with ${_descriptor.fullName}. Aborting...',
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
    final calorieFactor = await _database.calorieFactor(device.id.id, _descriptor) ?? 1.0;
    _activity = Activity(
      fourCC: _descriptor.fourCC,
      deviceName: device.name,
      deviceId: device.id.id,
      start: now.millisecondsSinceEpoch,
      startDateTime: now,
      sport: _descriptor.defaultSport,
      powerFactor: powerFactor,
      calorieFactor: calorieFactor,
    );
    if (!_uxDebug) {
      final id = await _database?.activityDao?.insertActivity(_activity);
      _activity.id = id;
    }

    if (_waveLightForDevice) {
      _deviceLeaderboard = await _database.workoutSummaryDao
          .findWorkoutSummaryByDevice(device.id.id, LEADERBOARD_LIMIT, 0);
    }
    if (_waveLightForSport) {
      _sportLeaderboard = await _database.workoutSummaryDao
          .findWorkoutSummaryBySport(_descriptor.defaultSport, LEADERBOARD_LIMIT, 0);
    }

    _fitnessEquipment.setActivity(_activity);

    await _fitnessEquipment.attach();
    setState(() {
      _measuring = true;
    });
    _fitnessEquipment.measuring = true;

    _fitnessEquipment.pumpData((record) async {
      _connectionWatchdog?.cancel();
      if (_connectionWatchdogTime > 0) {
        _connectionWatchdog = Timer(
          Duration(seconds: _connectionWatchdogTime),
          _reconnectionWorkaround,
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

          _values = [
            record.calories.toString(),
            record.power.toString(),
            record.speedStringByUnit(_si, _descriptor.defaultSport),
            record.cadence.toString(),
            record.heartRate.toString(),
            record.distanceStringByUnit(_si),
          ];
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
    debugPrint("Discovered $discovered");
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

    _pointCount = min(60, size.width ~/ 2);
    _unitStyle = TextStyle(
      fontFamily: FONT_FAMILY,
      color: Colors.indigo,
    );
    PrefService.setString(
      LAST_EQUIPMENT_ID_TAG_PREFIX + PreferencesSpec.sport2Sport(sport),
      device.id.id,
    );
    _descriptor.refreshTuning(device.id.id);
    if (Get.isRegistered<FitnessEquipment>()) {
      _fitnessEquipment = Get.find<FitnessEquipment>();
      _fitnessEquipment.descriptor = _descriptor;
    } else {
      _fitnessEquipment =
          Get.put<FitnessEquipment>(FitnessEquipment(descriptor: _descriptor, device: device));
    }

    _trackCalculator = TrackCalculator(
      track: TrackDescriptor(
        radiusBoost: TRACK_PAINTING_RADIUS_BOOST,
        lengthFactor: _descriptor.lengthFactor,
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
      _descriptor.slowPace = slowPace;
      _fitnessEquipment.slowPace = slowPace;
    }

    _connectionWatchdogTime = getStringIntegerPreference(
      EQUIPMENT_DISCONNECTION_WATCHDOG_TAG,
      EQUIPMENT_DISCONNECTION_WATCHDOG_DEFAULT,
      EQUIPMENT_DISCONNECTION_WATCHDOG_DEFAULT_INT,
    );
    _preferencesSpecs = PreferencesSpec.getPreferencesSpecs(_si, _descriptor.defaultSport);
    _preferencesSpecs.forEach((prefSpec) => prefSpec.calculateBounds(
          0,
          decimalRound(prefSpec.threshold * (prefSpec.zonePercents.last + 15) / 100.0),
        ));

    _targetHrMode =
        PrefService.getString(TARGET_HEART_RATE_MODE_TAG) ?? TARGET_HEART_RATE_MODE_DEFAULT;
    _targetHrBounds = getTargetHeartRateBounds(_targetHrMode, _preferencesSpecs[3]);

    _metricToDataFn = {
      "power": _powerChartData,
      "speed": _speedChartData,
      "cadence": _cadenceChartData,
      "hr": _hRChartData,
    };

    _expandableThemeData = ExpandableThemeData(hasIcon: !_simplerUi);
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

    _targetHrAlerting = false;
    _targetHrAudio =
        PrefService.getBool(TARGET_HEART_RATE_AUDIO_TAG) ?? TARGET_HEART_RATE_AUDIO_DEFAULT;
    if (_targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio) {
      _beepPeriod = getStringIntegerPreference(
        TARGET_HEART_RATE_AUDIO_PERIOD_TAG,
        TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT,
        TARGET_HEART_RATE_AUDIO_PERIOD_DEFAULT_INT,
      );
      if (!Get.isRegistered<SoundService>()) {
        Get.put<SoundService>(SoundService());
      }
    }
    _leaderboardFeature =
        PrefService.getBool(LEADERBOARD_FEATURE_TAG) ?? LEADERBOARD_FEATURE_DEFAULT;
    _waveLightForDevice =
        PrefService.getBool(WAVE_LIGHT_FOR_DEVICE_TAG) ?? WAVE_LIGHT_FOR_DEVICE_DEFAULT;
    _deviceLeaderboard = [];
    _waveLightForSport =
        PrefService.getBool(WAVE_LIGHT_FOR_SPORT_TAG) ?? WAVE_LIGHT_FOR_SPORT_DEFAULT;
    _sportLeaderboard = [];

    _darkRed = paletteToPaintColor(common.MaterialPalette.red.shadeDefault.darker);
    _darkGreen = paletteToPaintColor(common.MaterialPalette.green.shadeDefault.darker);
    _darkBlue = paletteToPaintColor(common.MaterialPalette.indigo.shadeDefault.darker);
    _lightRed = paletteToPaintColor(common.MaterialPalette.red.shadeDefault.lighter);
    _lightGreen = paletteToPaintColor(common.MaterialPalette.lime.shadeDefault.lighter);
    _lightBlue = paletteToPaintColor(common.MaterialPalette.blue.shadeDefault.lighter);

    _initializeHeartRateMonitor();
    _connectOnDemand(initialState);
    _database = Get.find<AppDatabase>();
  }

  _preDispose() async {
    _beepPeriodTimer?.cancel();
    await Get.find<SoundService>().stopAllSoundEffects();

    try {
      await _heartRateMonitor?.cancelSubscription();
    } on PlatformException catch (e, stack) {
      debugPrint("HRM device got turned off?");
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }

    _connectionWatchdog?.cancel();

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

  Future<void> _reconnectionWorkaround() async {
    Get.snackbar("Warning", "Equipment might be disconnected. Auto-starting new workout:");

    _beepPeriodTimer?.cancel();
    Get.find<SoundService>().stopAllSoundEffects();

    setState(() {
      _measuring = false;
    });
    _fitnessEquipment.measuring = false;
    try {
      await _fitnessEquipment?.detach();
      await _fitnessEquipment?.disconnect();
      final success = await _fitnessEquipment?.connect();
      await _connectOnDemand(
          success ? BluetoothDeviceState.connected : BluetoothDeviceState.disconnected);
    } on PlatformException catch (e, stack) {
      debugPrint("Equipment got turned off?");
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }
  }

  Future<void> _beeper() async {
    Get.find<SoundService>().playTargetHrSoundEffect();
    if (_measuring && _targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio) {
      if (_heartRate < _targetHrBounds.item1 || _heartRate > _targetHrBounds.item2) {
        _beepPeriodTimer = Timer(Duration(seconds: _beepPeriod), _beeper);
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

    _beepPeriodTimer?.cancel();
    Get.find<SoundService>().stopAllSoundEffects();

    setState(() {
      _measuring = false;
    });

    _connectionWatchdog?.cancel();
    _fitnessEquipment.detach();

    _activity.finish(
      _fitnessEquipment.lastRecord?.distance,
      _fitnessEquipment.lastRecord?.elapsed,
      _fitnessEquipment.lastRecord?.calories,
    );
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
        colorFn: (DisplayRecord record, __) => _preferencesSpecs[0].fgColorByValue(record.power),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.power,
        data: graphData,
      ),
    ];
  }

  List<charts.Series<DisplayRecord, DateTime>> _speedChartData() {
    return <charts.Series<DisplayRecord, DateTime>>[
      charts.Series<DisplayRecord, DateTime>(
        id: 'speed',
        colorFn: (DisplayRecord record, __) =>
            _preferencesSpecs[1].fgColorByValue(record.speedByUnit(_si, _descriptor.defaultSport)),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.speedByUnit(_si, _descriptor.defaultSport),
        data: graphData,
      ),
    ];
  }

  List<charts.Series<DisplayRecord, DateTime>> _cadenceChartData() {
    return <charts.Series<DisplayRecord, DateTime>>[
      charts.Series<DisplayRecord, DateTime>(
        id: 'cadence',
        colorFn: (DisplayRecord record, __) => _preferencesSpecs[2].fgColorByValue(record.cadence),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.cadence,
        data: graphData,
      ),
    ];
  }

  List<charts.Series<DisplayRecord, DateTime>> _hRChartData() {
    return <charts.Series<DisplayRecord, DateTime>>[
      charts.Series<DisplayRecord, DateTime>(
        id: 'hr',
        colorFn: (DisplayRecord record, __) =>
            _preferencesSpecs[3].fgColorByValue(record.heartRate),
        domainFn: (DisplayRecord record, _) => record.dt,
        measureFn: (DisplayRecord record, _) => record.heartRate,
        data: graphData,
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
      return MAX_UINT16;
    }

    final averageSpeed = _elapsed > 0 ? _distance / _elapsed : 0.0;
    var rank = 1;
    for (final entry in leaderboard) {
      if (averageSpeed > entry.speed) {
        return rank;
      }

      rank += 1;
    }

    return rank;
  }

  String _getRankString(List<WorkoutSummary> leaderboard) {
    final rank = _getRank(leaderboard);
    if (rank == null) {
      return "#$LEADERBOARD_LIMIT+";
    }

    return "#$rank";
  }

  int _getDeviceRank() {
    if (!_waveLightForDevice) return MAX_UINT16;

    return _getRank(_deviceLeaderboard);
  }

  String _getDeviceRankString() {
    return _getRankString(_deviceLeaderboard);
  }

  int _getSportRank() {
    if (!_waveLightForSport) return MAX_UINT16;

    return _getRank(_sportLeaderboard);
  }

  String _getSportRankString() {
    return _getRankString(_sportLeaderboard);
  }

  Color getWaveLightColor(int deviceRank, int sportRank, {@required bool background}) {
    if (!_waveLightForDevice && !_waveLightForSport) {
      return background ? Colors.transparent : Colors.indigo;
    }

    if (deviceRank != null && deviceRank <= 1 || sportRank != null && sportRank <= 1) {
      return background ? _lightGreen : _darkGreen;
    }
    return background ? _lightBlue : _darkBlue;
  }

  TextStyle getWaveLightTextStyle(int deviceRank, int sportRank) {
    if (!_waveLightForDevice && !_waveLightForSport) {
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

    if (_heartRate < _targetHrBounds.item1) {
      return background ? _lightBlue : _darkBlue;
    } else if (_heartRate > _targetHrBounds.item2) {
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

  @override
  Widget build(BuildContext context) {
    final separatorHeight = 1.0;

    final mediaWidth = Get.mediaQuery.size.width;
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = Get.mediaQuery.size.width / 8;
      _measurementStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault,
      );
      _unitStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault / 2,
        color: Colors.indigo,
      );
    }

    if (_measuring && _targetHrMode != TARGET_HEART_RATE_MODE_NONE && _targetHrAudio) {
      if (_heartRate < _targetHrBounds.item1 || _heartRate > _targetHrBounds.item2) {
        if (!_targetHrAlerting) {
          Get.find<SoundService>().playTargetHrSoundEffect();
          if (_beepPeriod >= 2) {
            _beepPeriodTimer = Timer(Duration(seconds: _beepPeriod), _beeper);
          }
        }
        _targetHrAlerting = true;
      } else {
        if (_targetHrAlerting) {
          _beepPeriodTimer?.cancel();
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
          Icon(Icons.timer, size: _sizeDefault, color: Colors.indigo),
          Text(_timeDisplay, style: _measurementStyle),
          SizedBox(width: _sizeDefault / 4),
        ],
      ),
    ];

    final targetHrState = getTargetHrState();
    final targetHrTextStyle = getTargetHrTextStyle(targetHrState);
    final deviceRank = _getDeviceRank();
    final sportRank = _getSportRank();

    _rowConfig.asMap().entries.forEach((entry) {
      var measurementStyle = _measurementStyle;

      if (entry.key == 2 && (_waveLightForDevice || _waveLightForSport)) {
        measurementStyle = getWaveLightTextStyle(deviceRank, sportRank);
      }

      if (entry.key == 4 && _targetHrMode != TARGET_HEART_RATE_MODE_NONE) {
        measurementStyle = targetHrTextStyle;
      }

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            _rowConfig[entry.key].icon,
            size: _sizeDefault,
            color: Colors.indigo,
          ),
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
              behaviors: [charts.RangeAnnotation(entry.value.annotationSegments)],
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
        } else if (entry.value.metric == "speed" && (_waveLightForDevice || _waveLightForSport)) {
          List<Widget> extraExtras = [];
          if (_waveLightForDevice) {
            final deviceWaveLightColor = getWaveLightTextStyle(deviceRank, null);
            extraExtras.add(Text(_getDeviceRankString(), style: deviceWaveLightColor));
          }
          if (_waveLightForSport) {
            final deviceWaveLightColor = getWaveLightTextStyle(null, sportRank);
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

      final trackMarker = _trackCalculator.trackMarker(_distance);
      extras.add(
        CustomPaint(
          painter: TrackPainter(calculator: _trackCalculator),
          child: SizedBox(
            width: size.width,
            height: size.width / 1.9,
            child: trackMarker == null
                ? null
                : Stack(
                    children: [
                      Positioned(
                        left: trackMarker.dx - THICK,
                        top: trackMarker.dy - THICK,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0x88FF0000),
                            borderRadius: BorderRadius.circular(THICK),
                          ),
                          width: THICK * 2,
                          height: THICK * 2,
                        ),
                      ),
                    ],
                  ),
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
                color: getWaveLightColor(deviceRank, sportRank, background: true),
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
          fabOpenIcon: const Icon(Icons.menu, color: Colors.white),
          fabCloseIcon: const Icon(Icons.close, color: Colors.white),
          children: [
            FloatingActionButton(
              heroTag: null,
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepOrangeAccent,
              child: Icon(BrandIcons.strava),
              onPressed: () async {
                if (_measuring) {
                  Get.snackbar("Warning", "Cannot upload while measurement is under progress");
                  return;
                }

                await _stravaUpload(false);
              },
            ),
            FloatingActionButton(
              heroTag: null,
              foregroundColor: Colors.white,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.list_alt),
              onPressed: () async {
                if (_measuring) {
                  Get.snackbar("Warning", "Cannot navigate while measurement is under progress");
                } else {
                  final hasLeaderboardData = await _database.hasLeaderboardData();
                  await Get.to(ActivitiesScreen(hasLeaderboardData: hasLeaderboardData));
                }
              },
            ),
            FloatingActionButton(
              heroTag: null,
              foregroundColor: Colors.white,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.battery_unknown),
              onPressed: () async {
                await Get.bottomSheet(
                  BatteryStatusBottomSheet(),
                  isDismissible: false,
                  enableDrag: false,
                );
              },
            ),
            FloatingActionButton(
              heroTag: null,
              foregroundColor: Colors.white,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.build),
              onPressed: () async {
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
              },
            ),
            FloatingActionButton(
              heroTag: null,
              foregroundColor: Colors.white,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.favorite),
              onPressed: () async {
                await Get.bottomSheet(
                  HeartRateMonitorPairingBottomSheet(),
                  isDismissible: false,
                  enableDrag: false,
                );
                await _initializeHeartRateMonitor();
              },
            ),
          ],
        ),
      ),
    );
  }
}
