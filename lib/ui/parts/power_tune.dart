import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/power_tune.dart';
import '../../persistence/preferences.dart';

class PowerTuneBottomSheet extends StatefulWidget {
  final Activity activity;

  PowerTuneBottomSheet({Key key, @required this.activity})
      : assert(activity != null), super(key: key);

  @override
  PowerTuneBottomSheetState createState() => PowerTuneBottomSheetState(
    activity: activity);
}

class PowerTuneBottomSheetState extends State<PowerTuneBottomSheet> {
  PowerTuneBottomSheetState({@required this.activity}) : assert(activity != null);

  final Activity activity;
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

    _powerFactorPercent = activity.powerFactor * 100;
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
          var powerTune = await database?.powerTuneDao?.findPowerTuneByMac(activity.deviceId)?.first;
          final powerFactor = _powerFactorPercent / 100;
          if (powerTune == null) {
            powerTune = PowerTune(mac: activity.deviceId, powerFactor: powerFactor);
            await database?.powerTuneDao?.insertPowerTune(powerTune);
          } else {
            powerTune.powerFactor = powerFactor;
            await database?.powerTuneDao?.updatePowerTune(powerTune);
          }
          Get.close(1);
        },
      ),
    );
  }
}
