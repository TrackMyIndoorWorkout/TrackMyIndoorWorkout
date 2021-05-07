import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/models/activity.dart';
import '../../persistence/models/calorie_tune.dart';
import '../../persistence/preferences.dart';

class CalorieTuneBottomSheet extends StatefulWidget {
  final Activity activity;

  CalorieTuneBottomSheet({Key key, @required this.activity})
      : assert(activity != null), super(key: key);

  @override
  CalorieTuneBottomSheetState createState() => CalorieTuneBottomSheetState(
    activity: activity);
}

class CalorieTuneBottomSheetState extends State<CalorieTuneBottomSheet> {
  CalorieTuneBottomSheetState({@required this.activity}) : assert(activity != null);

  final Activity activity;
  double _calorie;
  double _sizeDefault;
  TextStyle _selectedTextStyle;
  TextStyle _largerTextStyle;

  @override
  void initState() {
    super.initState();

    _sizeDefault = Get.mediaQuery.size.width / 10;
    _selectedTextStyle = TextStyle(fontFamily: FONT_FAMILY, fontSize: _sizeDefault);
    _largerTextStyle = _selectedTextStyle.apply(color: Colors.black);

    _calorie = activity.calories.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Desired Calories", style: _largerTextStyle),
          SpinBox(
            min: 1,
            max: 800,
            value: _calorie,
            onChanged: (value) => _calorie = value,
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
          var calorieTune = await database?.calorieTuneDao?.findCalorieTuneByMac(activity.deviceId)?.first;
          final calorieFactor = _calorie / activity.calories;
          if (calorieTune == null) {
            calorieTune = CalorieTune(mac: activity.deviceId, calorieFactor: calorieFactor);
            await database?.calorieTuneDao?.insertCalorieTune(calorieTune);
          } else {
            calorieTune.calorieFactor = calorieFactor;
            await database?.calorieTuneDao?.updateCalorieTune(calorieTune);
          }
          Get.close(1);
        },
      ),
    );
  }
}
