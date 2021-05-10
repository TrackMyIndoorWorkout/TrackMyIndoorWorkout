import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/calorie_tune.dart';
import '../../persistence/preferences.dart';

class CalorieOverrideBottomSheet extends StatefulWidget {
  final String deviceId;
  final int calories;

  CalorieOverrideBottomSheet({Key key, @required this.deviceId, @required this.calories})
      : assert(deviceId != null),
        assert(calories != null),
        super(key: key);

  @override
  CalorieOverrideBottomSheetState createState() =>
      CalorieOverrideBottomSheetState(deviceId: deviceId, oldCalories: calories.toDouble());
}

class CalorieOverrideBottomSheetState extends State<CalorieOverrideBottomSheet> {
  CalorieOverrideBottomSheetState({@required this.deviceId, @required this.oldCalories})
      : assert(deviceId != null),
        assert(oldCalories != null);

  final String deviceId;
  final double oldCalories;
  double _newCalorie;
  double _sizeDefault;
  TextStyle _selectedTextStyle;
  TextStyle _largerTextStyle;

  @override
  void initState() {
    super.initState();

    _sizeDefault = Get.mediaQuery.size.width / 10;
    _selectedTextStyle = TextStyle(fontFamily: FONT_FAMILY, fontSize: _sizeDefault);
    _largerTextStyle = _selectedTextStyle.apply(color: Colors.black);

    _newCalorie = oldCalories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Expected Calories", style: _largerTextStyle),
          SpinBox(
            min: 1,
            max: 100000,
            value: _newCalorie,
            onChanged: (value) => _newCalorie = value,
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
          final calorieFactor = _newCalorie / oldCalories;
          if (await database?.hasCalorieTune(deviceId) ?? false) {
            var calorieTune = await database?.calorieTuneDao?.findCalorieTuneByMac(deviceId)?.first;
            calorieTune.calorieFactor = calorieFactor;
            await database?.calorieTuneDao?.updateCalorieTune(calorieTune);
          } else {
            final calorieTune = CalorieTune(mac: deviceId, calorieFactor: calorieFactor);
            await database?.calorieTuneDao?.insertCalorieTune(calorieTune);
          }
          Get.back(result: calorieFactor);
        },
      ),
    );
  }
}
