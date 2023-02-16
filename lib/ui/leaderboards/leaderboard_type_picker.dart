import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/theme_manager.dart';
import 'device_leaderboard.dart';
import 'leaderboard_device_hub.dart';
import 'leaderboard_sport_hub.dart';
import 'sport_leaderboard.dart';

class LeaderBoardTypeBottomSheet extends StatefulWidget {
  const LeaderBoardTypeBottomSheet({Key? key}) : super(key: key);

  @override
  LeaderBoardTypeBottomSheetState createState() => LeaderBoardTypeBottomSheetState();
}

class LeaderBoardTypeBottomSheetState extends State<LeaderBoardTypeBottomSheet> {
  final ThemeManager _themeManager = Get.find<ThemeManager>();
  double _sizeDefault = 10.0;
  TextStyle _textStyle = const TextStyle();
  TextStyle _inverseTextStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.headlineMedium!.apply(
      fontFamily: fontFamily,
      color: Colors.white,
    );
    _inverseTextStyle = Get.textTheme.headlineMedium!.apply(
      fontFamily: fontFamily,
      color: _themeManager.getProtagonistColor(),
    );
    _sizeDefault = _textStyle.fontSize! * 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Text("Leaderboards:", style: _inverseTextStyle),
          Container(
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () async {
                final sports = await _database.workoutSummaryDao.findDistinctWorkoutSummarySports();
                if (sports.isEmpty) {
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
                if (devices.isEmpty) {
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _themeManager.getBlueFab(Icons.clear, () => Get.back()),
    );
  }
}
