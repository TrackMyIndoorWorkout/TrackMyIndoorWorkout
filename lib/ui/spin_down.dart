import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:spinner_input/spinner_input.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import '../persistence/preferences.dart';
import '../devices/bluetooth_device_ex.dart';
import '../devices/gatt_constants.dart';
import '../devices/heart_rate_monitor.dart';

class SpinDownBottomSheet extends StatefulWidget {
  final BluetoothDevice device;

  SpinDownBottomSheet({
    Key key,
    @required this.device,
  })  : assert(device != null),
        super(key: key);

  @override
  _SpinDownBottomSheetState createState() => _SpinDownBottomSheetState(device: device);
}

class _SpinDownBottomSheetState extends State<SpinDownBottomSheet> {
  static const STEP_WEIGHT_INPUT = 0;
  static const STEP_PADDLING = 1;
  static const STEP_END = 2;

  final BluetoothDevice device;
  HeartRateMonitor _heartRateMonitor;
  String _hrmBatteryLevel;
  String _batteryLevel;
  double _sizeDefault;
  TextStyle _textStyle;
  bool _si;
  int _step;
  int _weight;
  BluetoothCharacteristic _weightData;
  BluetoothCharacteristic _controlPoint;
  bool _weightSubmitSuccess;
  bool _weightSubmitting;
  double _targetSpeedHigh;
  double _targetSpeedLow;

  bool get _spinDownReady => _weightData != null && _controlPoint != null;
  bool get _canSubmitWeight => !_spinDownReady || _weightSubmitting;

  _SpinDownBottomSheetState({
    @required this.device,
  }) : assert(device != null);

  _prepareSpinDown(List<BluetoothService> services) async {
    final userData = BluetoothDeviceEx.filterService(services, USER_DATA_SERVICE);
    _weightData =
        BluetoothDeviceEx.filterCharacteristic(userData.characteristics, BATTERY_LEVEL_ID);
    final fitnessMachine = BluetoothDeviceEx.filterService(services, FITNESS_MACHINE_ID);
    _controlPoint =
        BluetoothDeviceEx.filterCharacteristic(fitnessMachine.characteristics, BATTERY_LEVEL_ID);
  }

  Future<String> _readBatteryLevel(List<BluetoothService> services) async {
    final batteryService = BluetoothDeviceEx.filterService(services, BATTERY_SERVICE_ID);
    final batteryLevel =
        BluetoothDeviceEx.filterCharacteristic(batteryService.characteristics, BATTERY_LEVEL_ID);
    final batteryLevelData = await batteryLevel.read();
    return batteryLevelData[0]?.toString() ?? "--";
  }

  _readBatteryLevels() async {
    if (_heartRateMonitor.connected) {
      _heartRateMonitor.device.discoverServices().then((services) async {
        await _prepareSpinDown(services);
        final batteryLevel = await _readBatteryLevel(services);
        setState(() {
          _hrmBatteryLevel = batteryLevel;
        });
      });
    } else {
      setState(() {
        _hrmBatteryLevel = "--";
      });
    }
    device.discoverServices().then((services) async {
      final batteryLevel = await _readBatteryLevel(services);
      setState(() {
        _batteryLevel = batteryLevel;
      });
    });
  }

  @override
  initState() {
    super.initState();
    _step = STEP_WEIGHT_INPUT;
    _weightSubmitSuccess = false;
    _weightSubmitting = false;
    //_
    _targetSpeedHigh = 0.0;
    _targetSpeedLow = 0.0;
    _weight = 50;
    _sizeDefault = Get.mediaQuery.size.width / 8;
    _textStyle = TextStyle(fontFamily: FONT_FAMILY, fontSize: _sizeDefault);
    _si = PrefService.getBool(UNIT_SYSTEM_TAG);
    _heartRateMonitor = Get.find<HeartRateMonitor>();
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
                      Text("$_batteryLevel%", style: _textStyle),
                    ]),
              _hrmBatteryLevel == null
                  ? JumpingDotsProgressIndicator(fontSize: _sizeDefault)
                  : Row(children: [
                      Icon(Icons.favorite, color: Colors.indigo, size: _sizeDefault),
                      Icon(Icons.battery_unknown, color: Colors.indigo, size: _sizeDefault),
                      Text("$_hrmBatteryLevel%", style: _textStyle),
                    ]),
            ],
          ),
          IndexedStack(
            index: _step,
            children: <Widget>[
              Column(
                children: [
                  Text("Weight (${_si ? "kg" : "lbs"}):", style: _textStyle),
                  SpinnerInput(
                    spinnerValue: _weight.toDouble(),
                    minValue: 1,
                    maxValue: 800,
                    middleNumberStyle: _textStyle,
                    plusButton: SpinnerButtonStyle(
                      height: _sizeDefault,
                      width: _sizeDefault,
                      child: Icon(Icons.add, size: _sizeDefault - 10),
                    ),
                    minusButton: SpinnerButtonStyle(
                      height: _sizeDefault,
                      width: _sizeDefault,
                      child: Icon(Icons.remove, size: _sizeDefault - 10),
                    ),
                    onChange: (newValue) {
                      setState(() {
                        _weight = newValue.toInt();
                      });
                    },
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        child: Text('Submit',
                            style: _textStyle.merge(TextStyle(
                                color: _canSubmitWeight ? Colors.black54 : Colors.black))),
                        style: ElevatedButton.styleFrom(
                          primary: _canSubmitWeight ? Colors.black12 : Colors.lightGreen.shade100,
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
                          final responseOpcode = await _weightData.read();
                          if (responseOpcode?.length != 1 ||
                              responseOpcode[0] != WEIGHT_SUCCESS_OPCODE) {
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
                        child: Text('Next >', style: _textStyle),
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
                  Text("Target speed / pace:", style: _textStyle),
                  Row(
                    children: [
                      ElevatedButton(
                        child: Text('Start',
                            style: _textStyle.merge(TextStyle(
                                color: _canSubmitWeight ? Colors.black54 : Colors.black))),
                        style: ElevatedButton.styleFrom(
                          primary: _canSubmitWeight ? Colors.black12 : Colors.lightGreen.shade100,
                        ),
                        onPressed: () async {
                          if (_weightSubmitting) {
                            Get.snackbar("Please wait", "Weight submission already in progress...");
                            return;
                          }
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.clear),
        onPressed: () => Get.close(1),
      ),
    );
  }
}
