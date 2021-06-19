import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import 'device_leaderboard.dart';
import 'leaderboard_device_hub.dart';
import 'leaderboard_sport_hub.dart';
import 'sport_leaderboard.dart';

class LeaderBoardTypeBottomSheet extends StatefulWidget {
  @override
  LeaderBoardTypeBottomSheetState createState() => LeaderBoardTypeBottomSheetState();
}

class LeaderBoardTypeBottomSheetState extends State<LeaderBoardTypeBottomSheet> {
  double _sizeDefault = 10.0;
  TextStyle _textStyle = TextStyle();
  TextStyle _inverseTextStyle = TextStyle();
  AppDatabase _database = Get.find<AppDatabase>();

  @override
  void initState() {
    super.initState();
    final themeManager = Get.find<ThemeManager>();
    _textStyle = Get.textTheme.headline3!.apply(
      fontFamily: FONT_FAMILY,
      color: Colors.white,
    );
    _inverseTextStyle = Get.textTheme.headline3!.apply(
      fontFamily: FONT_FAMILY,
      color: themeManager.getProtagonistColor(),
    );
    _sizeDefault = _textStyle.fontSize! * 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Leaderboards:", style: _inverseTextStyle),
            Container(
              padding: const EdgeInsets.all(5.0),
              margin: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                onPressed: () async {
                  final sports = await _database.findDistinctWorkoutSummarySports();
                  if (sports.length <= 0) {
                    Get.snackbar("Warning", "No sports found");
                  } else if (sports.length > 1) {
                    Get.to(() => LeaderboardSportHubScreen(sports: sports));
                  } else {
                    Get.to(() => SportLeaderboardScreen(sport: sports.first));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextOneLine(
                      "Sport",
                      style: _textStyle,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Icon(Icons.chevron_right, size: _sizeDefault),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              margin: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                onPressed: () async {
                  final devices = await _database.findDistinctWorkoutSummaryDevices();
                  if (devices.length <= 0) {
                    Get.snackbar("Warning", "No devices found");
                  } else if (devices.length > 1) {
                    Get.to(() => LeaderboardDeviceHubScreen(devices: devices));
                  } else {
                    Get.to(() => DeviceLeaderboardScreen(device: devices.first));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextOneLine(
                      "Device",
                      style: _textStyle,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Icon(Icons.chevron_right, size: _sizeDefault),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
