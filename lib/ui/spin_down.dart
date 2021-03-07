import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:spinner_input/spinner_input.dart';
import 'package:track_my_indoor_exercise/devices/fitness_machine_descriptor.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';
import '../devices/bluetooth_device_ex.dart';
import '../devices/device_descriptor.dart';
import '../devices/gatt_constants.dart';
import '../devices/heart_rate_monitor.dart';
import '../persistence/preferences.dart';
import '../utils/constants.dart';

class SpinDownBottomSheet extends StatefulWidget {
  final BluetoothDevice device;
  final DeviceDescriptor descriptor;

  SpinDownBottomSheet({
    Key key,
    @required this.device,
    @required this.descriptor,
  })  : assert(device != null),
        assert(descriptor != null),
        super(key: key);

  @override
  _SpinDownBottomSheetState createState() => _SpinDownBottomSheetState(
        device: device,
        descriptor: descriptor,
      );
}

class _SpinDownBottomSheetState extends State<SpinDownBottomSheet> {
  static const STEP_WEIGHT_INPUT = 0;
  static const STEP_PADDLING = 1;
  static const STEP_END = 2;

  final BluetoothDevice device;
  final DeviceDescriptor descriptor;
  HeartRateMonitor _heartRateMonitor;
  String _hrmBatteryLevel;
  String _batteryLevel;
  double _sizeDefault;
  TextStyle _smallerTextStyle;
  TextStyle _largerTextStyle;
  bool _si;
  int _step;
  int _weight;
  BluetoothCharacteristic _weightData;
  BluetoothCharacteristic _controlPoint;
  StreamSubscription _controlPointSubscription;
  BluetoothCharacteristic _fitnessMachineStatus;
  BluetoothCharacteristic _fitnessMachineData;
  bool _weightSubmitSuccess;
  bool _weightSubmitting;
  bool _calibrationInitiating;
  bool _calibrationStarted;
  String _instruction;
  double _targetSpeedHigh;
  double _targetSpeedLow;
  double _currentSpeed;

  bool get _spinDownReady => _weightData != null && _controlPoint != null;
  bool get _canSubmitWeight => _spinDownReady && !_weightSubmitting;

  _SpinDownBottomSheetState({
    @required this.device,
    @required this.descriptor,
  }) : assert(device != null);

  _prepareSpinDown(List<BluetoothService> services) async {
    final userData = BluetoothDeviceEx.filterService(services, USER_DATA_SERVICE);
    _weightData =
        BluetoothDeviceEx.filterCharacteristic(userData.characteristics, WEIGHT_CHARACTERISTIC);
    final fitnessMachine = BluetoothDeviceEx.filterService(services, FITNESS_MACHINE_ID);
    _controlPoint = BluetoothDeviceEx.filterCharacteristic(
        fitnessMachine.characteristics, FITNESS_MACHINE_CONTROL_POINT);
    _fitnessMachineStatus = BluetoothDeviceEx.filterCharacteristic(
        fitnessMachine.characteristics, FITNESS_MACHINE_STATUS);
    final dataService = descriptor.isFitnessMachine
        ? fitnessMachine
        : BluetoothDeviceEx.filterService(services, descriptor.primaryServiceId);
    _fitnessMachineData = BluetoothDeviceEx.filterCharacteristic(
        dataService.characteristics, (descriptor as FitnessMachineDescriptor).primaryMeasurementId);
  }

  Future<String> _readBatteryLevel(List<BluetoothService> services) async {
    final batteryService = BluetoothDeviceEx.filterService(services, BATTERY_SERVICE_ID);
    if (batteryService == null) {
      return "N/A";
    }
    final batteryLevel =
        BluetoothDeviceEx.filterCharacteristic(batteryService.characteristics, BATTERY_LEVEL_ID);
    if (batteryLevel == null) {
      return "N/A";
    }
    final batteryLevelData = await batteryLevel.read();
    return "${batteryLevelData[0]}%";
  }

  _readBatteryLevels() async {
    if (_heartRateMonitor?.connected ?? false) {
      _heartRateMonitor.device.discoverServices().then((services) async {
        final batteryLevel = await _readBatteryLevel(services);
        setState(() {
          _hrmBatteryLevel = batteryLevel;
        });
      });
    } else {
      setState(() {
        _hrmBatteryLevel = "N/A";
      });
    }
    device.discoverServices().then((services) async {
      await _prepareSpinDown(services);
      final batteryLevel = await _readBatteryLevel(services);
      setState(() {
        _batteryLevel = batteryLevel;
      });
    });
  }

  @override
  initState() {
    super.initState();
    _hrmBatteryLevel = "N/A";
    _batteryLevel = "N/A";
    _step = STEP_WEIGHT_INPUT;
    _weightSubmitSuccess = false;
    _weightSubmitting = false;
    _calibrationInitiating = false;
    _calibrationStarted = false;
    _targetSpeedHigh = 0.0;
    _targetSpeedLow = 0.0;
    _currentSpeed = 0.0;
    _instruction = "";
    _weight = 50;
    _sizeDefault = Get.mediaQuery.size.width / 10;
    _smallerTextStyle = TextStyle(fontFamily: FONT_FAMILY, fontSize: _sizeDefault);
    _largerTextStyle = TextStyle(fontFamily: FONT_FAMILY, fontSize: _sizeDefault * 2);
    _si = PrefService.getBool(UNIT_SYSTEM_TAG);
    _heartRateMonitor = Get.isRegistered<HeartRateMonitor>() ? Get.find<HeartRateMonitor>() : null;
    _readBatteryLevels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _hrmBatteryLevel == null
                  ? JumpingDotsProgressIndicator(fontSize: _sizeDefault)
                  : Row(children: [
                      Icon(Icons.battery_unknown, color: Colors.indigo, size: _sizeDefault),
                      Text(_batteryLevel, style: _smallerTextStyle),
                    ]),
              _hrmBatteryLevel == null
                  ? JumpingDotsProgressIndicator(fontSize: _sizeDefault)
                  : Row(children: [
                      Icon(Icons.favorite, color: Colors.indigo, size: _sizeDefault),
                      Icon(Icons.battery_unknown, color: Colors.indigo, size: _sizeDefault),
                      Text(_hrmBatteryLevel, style: _smallerTextStyle),
                    ]),
            ],
          ),
          IndexedStack(
            index: _step,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: Text('Submit',
                            style: _smallerTextStyle.merge(TextStyle(
                                color: _canSubmitWeight ? Colors.black : Colors.black54))),
                        style: ElevatedButton.styleFrom(
                          primary: _canSubmitWeight ? Colors.lightGreen.shade100 : Colors.black12,
                        ),
                        onPressed: () async {
                          if (!_spinDownReady) {
                            Get.snackbar(
                                "Please wait", "Initializing equipment for calibration...");
                            return;
                          }
                          if (_weightSubmitting) {
                            Get.snackbar("Please wait", "Weight submission already in progress...");
                            return;
                          }

                          setState(() {
                            _weightSubmitting = true;
                          });
                          final weight = _si ? _weight : (_weight * LB_TO_KG).toInt();
                          final weightLsb = weight % 256;
                          final weightMsb = weight ~/ 256;
                          await _weightData.write([weightLsb, weightMsb]);
                          final responseOpcode =
                              await _weightData.read(); // TODO: stuck, need subscription?
                          if (responseOpcode?.length != 1 ||
                              responseOpcode[0] != WEIGHT_SUCCESS_OPCODE) {
                            Get.snackbar(
                                "Weight setting error", "Retry weight setting to continue");
                            setState(() {
                              _weightSubmitting = false;
                            });
                            return;
                          }
                          final weightEcho = await _weightData.read();
                          if (weightEcho?.length != 2 ||
                              weightEcho[0] != weightLsb ||
                              weightEcho[1] != weightMsb) {
                            Get.snackbar(
                                "Weight setting error", "Retry weight setting to continue");
                            setState(() {
                              _weightSubmitting = false;
                            });
                            return;
                          }
                          Get.snackbar("Weight setting", "Successful");
                          setState(() {
                            _weightSubmitting = false;
                            _weightSubmitSuccess = true;
                          });
                        },
                      ),
                      ElevatedButton(
                        child: Text('Next >', style: _smallerTextStyle),
                        onPressed: () async {
                          if (_weightSubmitSuccess) {
                            setState(() {
                              _step = STEP_PADDLING;
                            });
                          } else {
                            Get.snackbar("Weight Submission", "Need to submit weight first");
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  Text("Target ${descriptor.speedTitle}:", style: _smallerTextStyle),
                  Text("${speedOrPaceString(_targetSpeedHigh, _si, descriptor.sport)}",
                      style: _smallerTextStyle.merge(TextStyle(color: Colors.black54))),
                  Text("Current ${descriptor.speedTitle}:", style: _smallerTextStyle),
                  Text("${speedOrPaceString(_targetSpeedHigh, _si, descriptor.sport)}",
                      style: _smallerTextStyle),
                  Text("$_instruction!", style: _smallerTextStyle),
                  Row(
                    children: [
                      ElevatedButton(
                        child: Text(_calibrationInitiating ? 'Stop' : 'Start',
                            style: _smallerTextStyle),
                        onPressed: () async {
                          // TODO if _calibrationStarted
                          if (_calibrationInitiating) {
                            Get.snackbar("Calibration", "Wait for instructions!");
                            return;
                          }
                          setState(() {
                            _calibrationInitiating = true;
                          });
                          await _controlPoint.write([SPIN_DOWN_OPCODE, SPIN_DOWN_START_COMMAND]);
                          final responseOpcode = await _controlPoint.read();
                          if (responseOpcode?.length != 1 ||
                              responseOpcode[0] != SPIN_DOWN_OPCODE) {
                            Get.snackbar("Calibration Start error", "Please retry");
                            setState(() {
                              _calibrationInitiating = false;
                            });
                            return;
                          }
                          final spinDownData = await _controlPoint.read();
                          if (spinDownData?.length != 7 ||
                              spinDownData[0] != CONTROL_OPCODE ||
                              spinDownData[1] != SPIN_DOWN_OPCODE ||
                              spinDownData[2] != SUCCESS_RESPONSE) {
                            Get.snackbar("Calibration Start error", "Please retry");
                            setState(() {
                              _calibrationInitiating = false;
                            });
                            return;
                          }
                          _targetSpeedHigh = (spinDownData[3] * 256 + spinDownData[4]) / 100;
                          _targetSpeedLow = (spinDownData[5] * 256 + spinDownData[6]) / 100;
                          Get.snackbar("Calibration started", "Go!");
                          setState(() {
                            _calibrationInitiating = false;
                            _calibrationStarted = true;
                          });
                          _controlPoint.setNotifyValue(true);
                          _controlPointSubscription = _controlPoint.value.listen((data) {
                            ;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              Container(
                color: Colors.red,
              )
            ],
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
