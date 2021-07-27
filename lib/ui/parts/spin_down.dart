import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:rxdart/rxdart.dart';
import 'package:spinner_input/spinner_input.dart';
import 'package:tuple/tuple.dart';
import '../../devices/gadgets/fitness_equipment.dart';
import '../../devices/bluetooth_device_ex.dart';
import '../../devices/gatt_constants.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../../utils/delays.dart';
import '../../utils/display.dart';
import '../../utils/theme_manager.dart';

class SpinDownBottomSheet extends StatefulWidget {
  @override
  _SpinDownBottomSheetState createState() => _SpinDownBottomSheetState();
}

enum CalibrationState {
  PreInit,
  Initializing,
  ReadyToWeighIn,
  WeightSubmitting,
  WeighInProblem,
  WeighInSuccess,
  ReadyToCalibrate,
  CalibrationStarting,
  CalibrationInProgress,
  CalibrationOver,
  CalibrationSuccess,
  CalibrationFail,
  NotSupported,
}

class _SpinDownBottomSheetState extends State<SpinDownBottomSheet> {
  static const STEP_WEIGHT_INPUT = 0;
  static const STEP_CALIBRATING = 1;
  static const STEP_DONE = 2;
  static const STEP_NOT_SUPPORTED = 3;

  FitnessEquipment? _fitnessEquipment;
  double _sizeDefault = 10.0;
  TextStyle _smallerTextStyle = TextStyle();
  TextStyle _largerTextStyle = TextStyle();
  bool _si = UNIT_SYSTEM_DEFAULT;
  int _step = STEP_WEIGHT_INPUT;
  int _weight = 80;
  int _oldWeightLsb = 0;
  int _oldWeightMsb = 0;
  int _newWeightLsb = 0;
  int _newWeightMsb = 0;
  BluetoothCharacteristic? _weightData;
  StreamSubscription? _weightDataSubscription;
  BluetoothCharacteristic? _controlPoint;
  StreamSubscription? _controlPointSubscription;
  BluetoothCharacteristic? _fitnessMachineStatus;
  StreamSubscription? _statusSubscription;
  CalibrationState _calibrationState = CalibrationState.PreInit;
  double _targetSpeedHigh = 0.0;
  double _targetSpeedLow = 0.0;
  double _currentSpeed = 0.0;
  String _targetSpeedHighString = "...";
  String _targetSpeedLowString = "...";
  String _currentSpeedString = "...";
  ThemeManager _themeManager = Get.find<ThemeManager>();
  bool _isLight = true;
  int _preferencesWeight = ATHLETE_BODY_WEIGHT_DEFAULT;
  bool _rememberLastWeight = REMEMBER_ATHLETE_BODY_WEIGHT_DEFAULT;

  bool get _spinDownPossible =>
      _weightData != null &&
      _controlPoint != null &&
      _fitnessMachineStatus != null &&
      _fitnessEquipment?.characteristic != null;
  bool get _canSubmitWeight =>
      _spinDownPossible && _calibrationState == CalibrationState.ReadyToWeighIn;

  Tuple2<int, int> getWeightBytes(int weight) {
    final weightTransport = (weight * (_si ? 1.0 : LB_TO_KG) * 200).round();
    return Tuple2<int, int>(weightTransport % MAX_UINT8, weightTransport ~/ MAX_UINT8);
  }

  int getWeightFromBytes(int weightLsb, int weightMsb) {
    return (weightLsb + weightMsb * MAX_UINT8) / (_si ? 1.0 : LB_TO_KG) ~/ 200;
  }

  @override
  void initState() {
    _fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;
    final prefService = Get.find<BasePrefService>();
    _si = prefService.get<bool>(UNIT_SYSTEM_TAG) ?? UNIT_SYSTEM_DEFAULT;
    _rememberLastWeight = prefService.get<bool>(REMEMBER_ATHLETE_BODY_WEIGHT_TAG) ??
        REMEMBER_ATHLETE_BODY_WEIGHT_DEFAULT;
    _preferencesWeight =
        prefService.get<int>(ATHLETE_BODY_WEIGHT_INT_TAG) ?? ATHLETE_BODY_WEIGHT_DEFAULT;
    _weight = (_preferencesWeight * (_si ? 1.0 : KG_TO_LB)).round();
    final weightBytes = getWeightBytes(_weight);
    _oldWeightLsb = weightBytes.item1;
    _oldWeightMsb = weightBytes.item2;
    _newWeightLsb = weightBytes.item1;
    _newWeightMsb = weightBytes.item2;
    _isLight = !_themeManager.isDark();
    _smallerTextStyle = Get.textTheme.headline5!.apply(
      fontFamily: FONT_FAMILY,
      color: _themeManager.getProtagonistColor(),
    );
    _sizeDefault = _smallerTextStyle.fontSize!;
    _largerTextStyle = Get.textTheme.headline2!.apply(
      fontFamily: FONT_FAMILY,
      color: _themeManager.getProtagonistColor(),
    );
    _prepareSpinDown();
    super.initState();
  }

  // Crazy! https://stackoverflow.com/a/50337157/292502
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    } else {
      debugPrint("Turd in the punch bowl!");
    }
  }

  Future<bool> _prepareSpinDownCore() async {
    if (_fitnessEquipment == null || _fitnessEquipment?.device == null) return false;

    if (!(_fitnessEquipment?.connected ?? false)) {
      await _fitnessEquipment?.connect();
    }

    if (!(_fitnessEquipment?.connected ?? false)) return false;

    if (!(_fitnessEquipment?.discovered ?? false)) {
      await _fitnessEquipment?.discover();
    }

    if (!(_fitnessEquipment?.discovered ?? false)) return false;

    final userData =
        BluetoothDeviceEx.filterService(_fitnessEquipment?.services ?? [], USER_DATA_SERVICE);
    _weightData =
        BluetoothDeviceEx.filterCharacteristic(userData?.characteristics, WEIGHT_CHARACTERISTIC);
    if (_weightData == null) return false;

    final fitnessMachine =
        BluetoothDeviceEx.filterService(_fitnessEquipment?.services ?? [], FITNESS_MACHINE_ID);
    _controlPoint = BluetoothDeviceEx.filterCharacteristic(
        fitnessMachine?.characteristics, FITNESS_MACHINE_CONTROL_POINT);
    _fitnessMachineStatus = BluetoothDeviceEx.filterCharacteristic(
        fitnessMachine?.characteristics, FITNESS_MACHINE_STATUS);
    if (_controlPoint == null || _fitnessMachineStatus == null) return false;

    // #117 Attach the handler way ahead of the actual weight write
    try {
      await _weightData?.setNotifyValue(true);
    } on PlatformException catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }

    _weightDataSubscription = _weightData?.value
        .throttleTime(Duration(milliseconds: SPIN_DOWN_THRESHOLD))
        .listen((response) async {
      if (response.length == 1 && _calibrationState == CalibrationState.WeightSubmitting) {
        if (response[0] != WEIGHT_SUCCESS_OPCODE) {
          setState(() {
            _calibrationState = CalibrationState.WeighInProblem;
          });
        }
      } else if (response.length == 2) {
        if (_calibrationState == CalibrationState.ReadyToWeighIn) {
          setState(() {
            _calibrationState = CalibrationState.WeighInProblem;
            _oldWeightLsb = response[0];
            _oldWeightMsb = response[1];
            _weight = getWeightFromBytes(_oldWeightLsb, _oldWeightMsb);
          });
        } else {
          if (response[0] == _newWeightLsb && response[1] == _newWeightMsb) {
            setState(() {
              _step = STEP_CALIBRATING;
              _calibrationState = CalibrationState.ReadyToCalibrate;
            });
          } else {
            setState(() {
              _calibrationState = CalibrationState.WeighInProblem;
            });
          }
        }
      } else if (_calibrationState == CalibrationState.WeightSubmitting) {
        try {
          await _weightData?.write([_newWeightLsb, _newWeightMsb]);
        } on PlatformException catch (e, stack) {
          debugPrint("$e");
          debugPrintStack(stackTrace: stack, label: "trace:");
          setState(() {
            _calibrationState = CalibrationState.WeighInProblem;
          });
        }
      }
    });

    // #117 Attach the handler way ahead of the spin down start command write
    try {
      await _controlPoint?.setNotifyValue(true); // Is this what needed for indication?
    } on PlatformException catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }

    _controlPointSubscription = _controlPoint?.value
        .throttleTime(Duration(milliseconds: SPIN_DOWN_THRESHOLD))
        .listen((data) async {
      if (data.length == 1) {
        if (data[0] != SPIN_DOWN_CONTROL) {
          setState(() {
            _step = STEP_DONE;
            _calibrationState = CalibrationState.CalibrationFail;
          });
        }
      }

      if (data.length == 7) {
        if (data[0] != CONTROL_OPCODE ||
            data[1] != SPIN_DOWN_CONTROL ||
            data[2] != SUCCESS_RESPONSE) {
          setState(() {
            _step = STEP_DONE;
            _calibrationState = CalibrationState.CalibrationFail;
          });
          return;
        }
        setState(() {
          _calibrationState = CalibrationState.CalibrationInProgress;
          _targetSpeedHigh = (data[3] * MAX_UINT8 + data[4]) / 100;
          _targetSpeedHighString = speedOrPaceString(
              _targetSpeedHigh, _si, _fitnessEquipment?.sport ?? ActivityType.Ride);
          _targetSpeedLow = (data[5] * MAX_UINT8 + data[6]) / 100;
          _targetSpeedLowString = speedOrPaceString(
              _targetSpeedLow, _si, _fitnessEquipment?.sport ?? ActivityType.Ride);
        });
      }
    });

    return _spinDownPossible;
  }

  Future<void> _prepareSpinDown() async {
    final success = await _prepareSpinDownCore();
    setState(() {
      if (!success) {
        _step = STEP_NOT_SUPPORTED;
        _calibrationState = CalibrationState.NotSupported;
      } else {
        _calibrationState = CalibrationState.ReadyToWeighIn;
      }
    });
  }

  ButtonStyle _buttonBackgroundStyle() {
    var backColor = _isLight ? Colors.black12 : Colors.black87;
    if (_calibrationState == CalibrationState.WeighInProblem ||
        _calibrationState == CalibrationState.CalibrationFail ||
        _calibrationState == CalibrationState.NotSupported) {
      backColor = _isLight ? Colors.red.shade50 : Colors.red.shade900;
    } else if (_calibrationState == CalibrationState.ReadyToWeighIn ||
        _calibrationState == CalibrationState.WeighInSuccess ||
        _calibrationState == CalibrationState.ReadyToCalibrate ||
        _calibrationState == CalibrationState.CalibrationSuccess) {
      backColor = _isLight ? Colors.lightGreen.shade100 : Colors.green.shade900;
    }

    return ElevatedButton.styleFrom(primary: backColor);
  }

  String _weightInputButtonText() {
    if (_calibrationState == CalibrationState.WeighInSuccess) return 'Next >';
    if (_calibrationState == CalibrationState.ReadyToWeighIn) return 'Submit';
    if (_calibrationState == CalibrationState.WeighInProblem) return 'Retry';

    return 'Wait...';
  }

  TextStyle _weightInputButtonTextStyle() {
    return _smallerTextStyle.merge(TextStyle(
        color: _calibrationState == CalibrationState.WeighInSuccess || _canSubmitWeight
            ? (_isLight ? Colors.black : Colors.white)
            : (_isLight ? Colors.black87 : Colors.white70)));
  }

  ButtonStyle _weightInputButtonStyle() {
    return ElevatedButton.styleFrom(
      primary: _calibrationState == CalibrationState.WeighInSuccess || _canSubmitWeight
          ? (_isLight ? Colors.lightGreen.shade100 : Colors.green.shade900)
          : (_isLight ? Colors.black12 : Colors.black87),
    );
  }

  Future<void> _onWeightInputButtonPressed() async {
    if (_calibrationState == CalibrationState.WeighInSuccess) {
      return;
    }

    if (_calibrationState == CalibrationState.PreInit ||
        _calibrationState == CalibrationState.Initializing) {
      Get.snackbar("Please wait", "Initializing equipment for calibration...");
      return;
    }
    if (_calibrationState == CalibrationState.WeightSubmitting) {
      Get.snackbar("Please wait", "Weight submission is in progress...");
      return;
    }

    setState(() {
      _calibrationState = CalibrationState.WeightSubmitting;
    });
    final newWeightBytes = getWeightBytes(_weight);
    _newWeightLsb = newWeightBytes.item1;
    _newWeightMsb = newWeightBytes.item2;
    try {
      if (_rememberLastWeight) {
        final weightKg = _weight * (_si ? 1.0 : LB_TO_KG);
        final prefService = Get.find<BasePrefService>();
        await prefService.set<int>(ATHLETE_BODY_WEIGHT_INT_TAG, weightKg.round());
      }

      await _weightData?.write([_newWeightLsb, _newWeightMsb]);
    } on PlatformException catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
      setState(() {
        _calibrationState = CalibrationState.WeighInProblem;
      });
    }
  }

  String _calibrationInstruction() {
    if (_calibrationState == CalibrationState.ReadyToCalibrate) {
      return "READY!";
    }

    if (_calibrationState == CalibrationState.CalibrationStarting) {
      return "START!";
    }

    if (_calibrationState == CalibrationState.CalibrationInProgress) {
      if (_currentSpeed < EPS || _currentSpeed < _targetSpeedLow) {
        return "FASTER";
      } else if (_currentSpeed > _targetSpeedHigh) {
        return "SLOWER";
      } else {
        return "_";
      }
    }
    return "STOP!";
  }

  TextStyle _calibrationInstructionStyle() {
    var color = _themeManager.getRedColor();

    if (_calibrationState == CalibrationState.ReadyToCalibrate ||
        _calibrationState == CalibrationState.CalibrationStarting) {
      color = _themeManager.getGreenColor();
    }

    if (_calibrationState == CalibrationState.CalibrationInProgress)
      color = _themeManager.getBlueColor();

    return _largerTextStyle.merge(TextStyle(color: color));
  }

  String _calibrationButtonText() {
    if (_calibrationState == CalibrationState.ReadyToCalibrate) return 'Start';

    if (_calibrationState == CalibrationState.CalibrationStarting) return 'Wait...';

    return 'Stop';
  }

  Future<void> onCalibrationButtonPressed() async {
    if (_calibrationState == CalibrationState.CalibrationStarting) {
      Get.snackbar("Calibration", "Wait for instructions!");
      return;
    }
    setState(() {
      _calibrationState = CalibrationState.CalibrationStarting;
    });

    try {
      await _controlPoint?.write([SPIN_DOWN_CONTROL, SPIN_DOWN_START_COMMAND]);
      await _fitnessMachineStatus?.setNotifyValue(true);
    } on PlatformException catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }

    _statusSubscription = _fitnessMachineStatus?.value
        .throttleTime(Duration(milliseconds: FTMS_STATUS_THRESHOLD))
        .listen((status) {
      if (status.length == 2 && status[0] == SPIN_DOWN_STATUS) {
        if (status[1] == SPIN_DOWN_STATUS_SUCCESS) {
          _reset();
          setState(() {
            _step = STEP_DONE;
            _calibrationState = CalibrationState.CalibrationSuccess;
          });
        }
        if (status[1] == SPIN_DOWN_STATUS_ERROR) {
          _reset();
          setState(() {
            _step = STEP_DONE;
            _calibrationState = CalibrationState.CalibrationFail;
          });
        }
        if (status[1] == SPIN_DOWN_STATUS_STOP_PEDALING) {
          setState(() {
            _calibrationState = CalibrationState.CalibrationOver;
          });
        }
      }
    });

    await _fitnessEquipment?.attach();
    _fitnessEquipment?.calibrating = true;
    _fitnessEquipment?.pumpData((record) async {
      setState(() {
        _currentSpeed = record.speed ?? 0.0;
        _currentSpeedString =
            record.speedOrPaceStringByUnit(_si, _fitnessEquipment?.sport ?? ActivityType.Ride);
      });
    });
  }

  Future<void> _detachControlPoint() async {
    await _controlPoint?.setNotifyValue(false);
    _controlPointSubscription?.cancel();
  }

  Future<void> _detachWeightData() async {
    await _weightData?.setNotifyValue(false);
    _weightDataSubscription?.cancel();
  }

  Future<void> _detachFitnessMachineStatus() async {
    _fitnessMachineStatus?.setNotifyValue(false);
    _statusSubscription?.cancel();
  }

  Future<void> _detachFitnessMachine() async {
    _fitnessEquipment?.calibrating = false;
    await _fitnessEquipment?.detach();
  }

  Future<void> _reset() async {
    await _detachControlPoint();
    await _detachWeightData();
    await _detachFitnessMachineStatus();
    await _detachFitnessMachine();
  }

  @override
  void dispose() {
    _reset();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: IndexedStack(
          index: _step,
          children: [
            // 0 - STEP_WEIGHT_INPUT
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Weight (${_si ? "kg" : "lbs"}):", style: _smallerTextStyle),
                  SpinnerInput(
                    spinnerValue: _weight.toDouble(),
                    minValue: 1,
                    maxValue: 800,
                    middleNumberStyle: _largerTextStyle,
                    plusButton: SpinnerButtonStyle(
                      height: _sizeDefault * 2,
                      width: _sizeDefault * 2,
                      child: Icon(Icons.add, size: _sizeDefault * 2 - 10),
                    ),
                    minusButton: SpinnerButtonStyle(
                      height: _sizeDefault * 2,
                      width: _sizeDefault * 2,
                      child: Icon(Icons.remove, size: _sizeDefault * 2 - 10),
                    ),
                    onChange: (newValue) {
                      setState(() {
                        _weight = newValue.toInt();
                      });
                    },
                  ),
                  ElevatedButton(
                    child: Text(
                      _weightInputButtonText(),
                      style: _weightInputButtonTextStyle(),
                    ),
                    style: _weightInputButtonStyle(),
                    onPressed: () async => await _onWeightInputButtonPressed(),
                  ),
                ],
              ),
            ),
            // 1 - STEP_CALIBRATING
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_targetSpeedLowString, style: _smallerTextStyle),
                      Icon(Icons.compare_arrows, size: _sizeDefault),
                      Text(_targetSpeedHighString, style: _smallerTextStyle),
                    ],
                  ),
                  Text(_currentSpeedString,
                      style:
                          _largerTextStyle.merge(TextStyle(color: _themeManager.getBlueColor()))),
                  Text(_calibrationInstruction(), style: _calibrationInstructionStyle()),
                  ElevatedButton(
                    child: Text(_calibrationButtonText(), style: _smallerTextStyle),
                    style: _buttonBackgroundStyle(),
                    onPressed: () async => await onCalibrationButtonPressed(),
                  ),
                ],
              ),
            ),
            // 2 - STEP_END
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      _calibrationState == CalibrationState.CalibrationSuccess
                          ? "SUCCESS"
                          : "ERROR",
                      style: _largerTextStyle),
                  ElevatedButton(
                    child: Text(
                        _calibrationState == CalibrationState.CalibrationSuccess
                            ? 'Close'
                            : 'Retry',
                        style: _smallerTextStyle),
                    style: _buttonBackgroundStyle(),
                    onPressed: () {
                      if (_calibrationState == CalibrationState.CalibrationSuccess) {
                        Get.close(1);
                      } else {
                        _fitnessEquipment?.detach();
                        setState(() {
                          _calibrationState = CalibrationState.ReadyToWeighIn;
                          _step = STEP_WEIGHT_INPUT;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            // 3 - STEP_NOT_SUPPORTED
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                softWrap: true,
                text: TextSpan(
                  text: "${_fitnessEquipment?.device?.name} doesn't seem to support calibration",
                  style: _smallerTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getBlueFab(Icons.clear, () => Get.close(1)),
    );
  }
}
