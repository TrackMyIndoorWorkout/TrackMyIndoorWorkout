import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../persistence/database.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import 'device_leaderboard.dart';
import 'leaderboard_device_hub.dart';
import 'leaderboard_sport_hub.dart';
import 'sport_leaderboard.dart';

class LeaderBoardTypeBottomSheet extends StatefulWidget {
  @override
  LeaderBoardTypeBottomSheetState createState() => LeaderBoardTypeBottomSheetState();
}

class LeaderBoardTypeBottomSheetState extends State<LeaderBoardTypeBottomSheet> {
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _textStyle;

  @override
  Widget build(BuildContext context) {
    final mediaWidth = min(Get.mediaQuery.size.width, Get.mediaQuery.size.height);
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = _mediaWidth / 5;
      _textStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _mediaWidth / 10,
      ).merge(TextStyle(color: Colors.black));
    }
    final buttonStyle = ElevatedButton.styleFrom(primary: Colors.grey.shade200);
    final database = Get.find<AppDatabase>();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Leaderboards:", style: _textStyle),
          Container(
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () async {
                final sports = await database.findDistinctWorkoutSummarySports();
                if (sports == null || sports.length <= 0) {
                  Get.snackbar("Warning", "No sports found");
                } else if (sports.length > 1) {
                  Get.to(LeaderboardSportHubScreen(sports: sports));
                } else {
                  Get.to(SportLeaderboardScreen(sport: sports.first));
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
                  Icon(Icons.chevron_right, size: _sizeDefault, color: Colors.indigo),
                ],
              ),
              style: buttonStyle,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () async {
                final devices = await database.findDistinctWorkoutSummaryDevices();
                if (devices == null || devices.length <= 0) {
                  Get.snackbar("Warning", "No devices found");
                } else if (devices.length > 1) {
                  Get.to(LeaderboardDeviceHubScreen(devices: devices));
                } else {
                  Get.to(DeviceLeaderboardScreen(device: devices.first));
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
                  Icon(Icons.chevron_right, size: _sizeDefault, color: Colors.indigo),
                ],
              ),
              style: buttonStyle,
            ),
          ),
        ],
      ),
    );
  }
}
