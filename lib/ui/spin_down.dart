import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'package:spinner_input/spinner_input.dart';
import '../devices/gadgets/fitness_equipment.dart';
import '../devices/bluetooth_device_ex.dart';
import '../devices/gatt_constants.dart';
import '../persistence/preferences.dart';
import '../utils/constants.dart';
import '../utils/display.dart';

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
  CalibrationSuccess,
  CalibrationFail,
  NotSupported,
}

class _SpinDownBottomSheetState extends State<SpinDownBottomSheet> {
  static const STEP_WEIGHT_INPUT = 0;
  static const STEP_CALIBRATING = 1;
  static const STEP_DONE = 2;
  static const STEP_NOT_SUPPORTED = 3;

  FitnessEquipment _fitnessEquipment;
  double _sizeDefault;
  TextStyle _smallerTextStyle;
  TextStyle _largerTextStyle;
  bool _si;
  int _step;
  int _weight;
  bool _weightRetry;
  BluetoothCharacteristic _weightData;
  StreamSubscription _weightDataSubscription;
  BluetoothCharacteristic _controlPoint;
  StreamSubscription _controlPointSubscription;
  BluetoothCharacteristic _fitnessMachineStatus;
  StreamSubscription _statusSubscription;
  CalibrationState _calibrationState;
  String _targetSpeedHigh;
  String _targetSpeedLow;
  String _currentSpeed;

  bool get _spinDownPossible =>
      _weightData != null &&
      _controlPoint != null &&
      _fitnessMachineStatus != null &&
      _fitnessEquipment.characteristic != null;
  bool get _canSubmitWeight =>
      _spinDownPossible && _calibrationState == CalibrationState.ReadyToWeighIn;

  Future<bool> _prepareSpinDownCore() async {
    if (_fitnessEquipment?.device == null) return false;

    if (!_fitnessEquipment.connected) {
      await _fitnessEquipment.connect();
    }

    if (!_fitnessEquipment.connected) return false;

    if (!_fitnessEquipment.discovered) {
      await _fitnessEquipment.discover();
    }

    if (!_fitnessEquipment.discovered) return false;

    final userData = BluetoothDeviceEx.filterService(_fitnessEquipment.services, USER_DATA_SERVICE);
    _weightData =
        BluetoothDeviceEx.filterCharacteristic(userData?.characteristics, WEIGHT_CHARACTERISTIC);
    final fitnessMachine =
        BluetoothDeviceEx.filterService(_fitnessEquipment.services, FITNESS_MACHINE_ID);
    _controlPoint = BluetoothDeviceEx.filterCharacteristic(
        fitnessMachine?.characteristics, FITNESS_MACHINE_CONTROL_POINT);
    _fitnessMachineStatus = BluetoothDeviceEx.filterCharacteristic(
        fitnessMachine?.characteristics, FITNESS_MACHINE_STATUS);

    return _spinDownPossible;
  }

  _prepareSpinDown() async {
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
    var backColor = Colors.black12;
    if (_calibrationState == CalibrationState.WeighInProblem || _calibrationState == CalibrationState.CalibrationFail ||
        _calibrationState == CalibrationState.NotSupported) {
      backColor = Colors.red.shade50;
    } else if (_calibrationState == CalibrationState.ReadyToWeighIn || _calibrationState == CalibrationState.WeighInSuccess ||
        _calibrationState == CalibrationState.ReadyToCalibrate || _calibrationState == CalibrationState.CalibrationSuccess) {
      backColor = Colors.lightGreen.shade100;
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
            ? Colors.black
            : Colors.black87));
  }

  ButtonStyle _weightInputButtonStyle() {
    return ElevatedButton.styleFrom(
      primary: _calibrationState == CalibrationState.WeighInSuccess || _canSubmitWeight
          ? Colors.lightGreen.shade100
          : Colors.black12,
    );
  }

  Future<void> _onWeightInputButtonPressed() async {
    if (_calibrationState == CalibrationState.WeighInSuccess) {
      setState(() {
        _step = STEP_CALIBRATING;
        _calibrationState = CalibrationState.ReadyToCalibrate;
        _weightRetry = false;
      });
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
    final weight = ((_si ? _weight : _weight * LB_TO_KG) * 100).round();
    final weightLsb = weight % 256;
    final weightMsb = weight ~/ 256;
    try {
      await _weightData.setNotifyValue(true);
    } on PlatformException catch (e, stack) {
      debugPrint("${e.message}");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }
    _weightDataSubscription =
        _weightData.value.throttleTime(Duration(milliseconds: 500)).listen((response) async {
      setState(() {
        _weightRetry = false;
      });
      if (response?.length == 1) {
        if (response[0] != WEIGHT_SUCCESS_OPCODE) {
          setState(() {
            _calibrationState = CalibrationState.WeighInProblem;
          });
        }
      } else if (response?.length == 2) {
        if (response[0] == weightLsb && response[1] == weightMsb) {
          setState(() {
            _calibrationState = CalibrationState.WeighInSuccess;
          });
        } else {
          setState(() {
            _calibrationState = CalibrationState.WeighInProblem;
          });
        }
      } else {
        if (_weightRetry) {
          setState(() {
            _calibrationState = CalibrationState.WeighInProblem;
          });
        } else {
          setState(() {
            _weightRetry = true;
          });
          try {
            await _weightData.write([weightLsb, weightMsb]);
          } on PlatformException catch (e, stack) {
            debugPrint("${e.message}");
            debugPrintStack(stackTrace: stack, label: "trace:");
          }
        }
      }
    });
    try {
      await _weightData.write([weightLsb, weightMsb]);
    } on PlatformException catch (e, stack) {
      debugPrint("${e.message}");
      debugPrintStack(stackTrace: stack, label: "trace:");
      setState(() {
        _calibrationState = CalibrationState.WeighInProblem;
      });
    }
  }

  String _calibrationInstruction() {
    if (_calibrationState == CalibrationState.ReadyToCalibrate ||
        _calibrationState == CalibrationState.CalibrationStarting) {
      return "START!";
    }

    if (_calibrationState == CalibrationState.CalibrationInProgress) return "FASTER!";

    return "STOP!!!";
  }

  TextStyle _calibrationInstructionStyle() {
    var color = Colors.red;

    if (_calibrationState == CalibrationState.ReadyToCalibrate ||
        _calibrationState == CalibrationState.CalibrationStarting) {
      color = Colors.green;
    }

    if (_calibrationState == CalibrationState.CalibrationInProgress) color = Colors.indigo;

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
      await _controlPoint.setNotifyValue(true); // Is this what needed for indication?
    } on PlatformException catch (e, stack) {
      debugPrint("${e.message}");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }
    _controlPointSubscription =
        _controlPoint.value.throttleTime(Duration(milliseconds: 500)).listen((data) async {
      if (data?.length == 1) {
        if (data[0] != SPIN_DOWN_OPCODE) {
          setState(() {
            _step = STEP_DONE;
            _calibrationState = CalibrationState.CalibrationFail;
          });
        }
      }
      if (data?.length == 7) {
        if (data[0] != CONTROL_OPCODE ||
            data[1] != SPIN_DOWN_OPCODE ||
            data[2] != SUCCESS_RESPONSE) {
          setState(() {
            _step = STEP_DONE;
            _calibrationState = CalibrationState.CalibrationFail;
          });
          return;
        }
        setState(() {
          _calibrationState = CalibrationState.CalibrationInProgress;
          _targetSpeedHigh = speedOrPaceString(
              (data[3] * 256 + data[4]) / 100, _si, _fitnessEquipment.descriptor.sport);
          _targetSpeedLow = speedOrPaceString(
              (data[5] * 256 + data[6]) / 100, _si, _fitnessEquipment.descriptor.sport);
        });
      }
    });
    try {
      await _controlPoint.write([SPIN_DOWN_OPCODE, SPIN_DOWN_START_COMMAND]);
      await _fitnessMachineStatus.setNotifyValue(true);
    } on PlatformException catch (e, stack) {
      debugPrint("${e.message}");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }
    _statusSubscription =
        _fitnessMachineStatus.value.throttleTime(Duration(milliseconds: 250)).listen((status) {
      if (status?.length == 2 && status[0] == SPIN_DOWN_STATUS) {
        if (status[1] == SPIN_DOWN_STATUS_SUCCESS) {
          setState(() {
            _step = STEP_DONE;
            _calibrationState = CalibrationState.CalibrationSuccess;
          });
        }
        if (status[1] == SPIN_DOWN_STATUS_ERROR) {
          setState(() {
            _step = STEP_DONE;
            _calibrationState = CalibrationState.CalibrationFail;
          });
        }
        if (status[1] == SPIN_DOWN_STATUS_STOP_PEDALING) {
          setState(() {
            _calibrationState = CalibrationState.CalibrationSuccess;
          });
        }
      }
    });
    await _fitnessEquipment.attach();
    _fitnessEquipment.pumpData((record) async {
      setState(() {
        _currentSpeed = record.speedStringByUnit(_si, _fitnessEquipment.descriptor.sport);
      });
    });
  }

  @override
  initState() {
    _fitnessEquipment = Get.isRegistered<FitnessEquipment>() ? Get.find<FitnessEquipment>() : null;
    _step = STEP_WEIGHT_INPUT;
    _calibrationState = CalibrationState.PreInit;
    _targetSpeedHigh = "N/A";
    _targetSpeedLow = "N/A";
    _currentSpeed = "N/A";
    _sizeDefault = Get.mediaQuery.size.width / 10;
    _smallerTextStyle = TextStyle(
        fontFamily: FONT_FAMILY, fontSize: _sizeDefault, color: Get.textTheme.bodyText1.color);
    _largerTextStyle = TextStyle(fontFamily: FONT_FAMILY, fontSize: _sizeDefault * 2);
    _si = PrefService.getBool(UNIT_SYSTEM_TAG);
    _weight = _si ? 60 : 130;
    _weightRetry = false;
    _prepareSpinDown();
    super.initState();
  }

  @override
  dispose() {
    _controlPointSubscription?.cancel();
    _controlPoint?.setNotifyValue(false);

    _weightDataSubscription?.cancel();
    _weightData?.setNotifyValue(false);

    _statusSubscription?.cancel();
    _fitnessMachineStatus.setNotifyValue(false);

    _fitnessEquipment.detach();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _step,
        children: <Widget>[
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
                    Text(_targetSpeedLow, style: _smallerTextStyle),
                    Icon(Icons.compare_arrows, size: _sizeDefault),
                    Text(_targetSpeedHigh, style: _smallerTextStyle),
                  ],
                ),
                Text(_currentSpeed,
                    style: _largerTextStyle.merge(TextStyle(color: Colors.indigo))),
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
                Text(_calibrationState == CalibrationState.CalibrationSuccess ? "SUCCESS" : "ERROR",
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
                      _fitnessEquipment.detach();
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
                text: "${_fitnessEquipment.device.name} doesn't seem to support calibration",
                style: _smallerTextStyle,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.clear),
        onPressed: () => Get.close(1),
      ),
    );
  }
}
