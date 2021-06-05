import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/sound.dart';
import 'athlete.dart';
import 'data_preferences.dart';
import 'expert.dart';
import 'leaderboard.dart';
import 'target_heart_rate.dart';
import 'ux_preferences.dart';
import 'zones_hub.dart';

class PreferencesHubScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PreferencesHubScreenState();
}

class PreferencesHubScreenState extends State<PreferencesHubScreen> {
  late double _sizeDefault;
  late TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.headline4!.apply(
      fontFamily: FONT_FAMILY,
      color: Colors.white,
    );
    _sizeDefault = _textStyle.fontSize! * 2;
    if (!Get.isRegistered<SoundService>()) {
      Get.put<SoundService>(SoundService());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preferences')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(5.0),
              margin: const EdgeInsets.all(5.0),
              child: ElevatedButton(
                onPressed: () => Get.to(UXPreferencesScreen()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextOneLine(
                      UXPreferencesScreen.shortTitle,
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
                onPressed: () => Get.to(DataPreferencesScreen()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextOneLine(
                      DataPreferencesScreen.shortTitle,
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
                onPressed: () => Get.to(TargetHrPreferencesScreen()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextOneLine(
                      TargetHrPreferencesScreen.shortTitle,
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
                onPressed: () => Get.to(LeaderboardPreferencesScreen()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextOneLine(
                      LeaderboardPreferencesScreen.shortTitle,
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
                onPressed: () => Get.to(ZonesHubScreen()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextOneLine(
                      ZonesHubScreen.shortTitle,
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
                onPressed: () => Get.to(AthletePreferencesScreen()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextOneLine(
                      AthletePreferencesScreen.shortTitle,
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
                onPressed: () => Get.to(ExpertPreferencesScreen()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextOneLine(
                      ExpertPreferencesScreen.shortTitle,
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
