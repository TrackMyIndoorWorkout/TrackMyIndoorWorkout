import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/power_tune.dart';
import '../../persistence/preferences.dart';

class PowerTuneBottomSheet extends StatefulWidget {
  final String deviceId;
  final double powerFactor;

  PowerTuneBottomSheet({Key key, @required this.deviceId, @required this.powerFactor})
      : assert(deviceId != null),
        assert(powerFactor != null),
        super(key: key);

  @override
  PowerTuneBottomSheetState createState() =>
      PowerTuneBottomSheetState(deviceId: deviceId, oldPowerFactor: powerFactor);
}

class PowerTuneBottomSheetState extends State<PowerTuneBottomSheet> {
  PowerTuneBottomSheetState({@required this.deviceId, @required this.oldPowerFactor})
      : assert(deviceId != null),
        assert(oldPowerFactor != null);

  final String deviceId;
  final double oldPowerFactor;
  double _powerFactorPercent;
  double _sizeDefault;
  TextStyle _selectedTextStyle;
  TextStyle _largerTextStyle;

  @override
  void initState() {
    super.initState();

    _sizeDefault = Get.mediaQuery.size.width / 10;
    _selectedTextStyle = TextStyle(fontFamily: FONT_FAMILY, fontSize: _sizeDefault);
    _largerTextStyle = _selectedTextStyle.apply(color: Colors.black);

    _powerFactorPercent = oldPowerFactor * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Power Factor %", style: _largerTextStyle),
          SpinBox(
            min: 1,
            max: 800,
            value: _powerFactorPercent,
            onChanged: (value) => _powerFactorPercent = value,
            textStyle: _largerTextStyle,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        child: Icon(Icons.check),
        onPressed: () async {
          final database = Get.find<AppDatabase>();
          final powerFactor = _powerFactorPercent / 100;
          if (await database?.hasPowerTune(deviceId) ?? false) {
            var powerTune = await database?.powerTuneDao?.findPowerTuneByMac(deviceId)?.first;
            powerTune.powerFactor = powerFactor;
            await database?.powerTuneDao?.updatePowerTune(powerTune);
          } else {
            final powerTune = PowerTune(mac: deviceId, powerFactor: powerFactor);
            await database?.powerTuneDao?.insertPowerTune(powerTune);
          }
          Get.close(1);
        },
      ),
    );
  }
}
