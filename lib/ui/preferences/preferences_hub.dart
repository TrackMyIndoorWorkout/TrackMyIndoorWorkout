import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../../utils/sound.dart';
import 'data_preferences.dart';
import 'expert.dart';
import 'measurement_zones.dart';
import 'target_heart_rate.dart';
import 'ux_preferences.dart';

class PreferencesHubScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PreferencesHubScreenState();
}

class PreferencesHubScreenState extends State<PreferencesHubScreen> {
  double _mediaWidth;
  double _sizeDefault;
  TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SoundService>()) {
      Get.put<SoundService>(SoundService());
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = Get.mediaQuery.size.width;
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = Get.mediaQuery.size.width / 5;
      _textStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault / 2,
      ).merge(TextStyle(color: Colors.black));
    }
    final buttonStyle = ElevatedButton.styleFrom(primary: Colors.grey.shade200);

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
                onPressed: () => Get.to(MeasurementZonesPreferencesScreen()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextOneLine(
                      MeasurementZonesPreferencesScreen.shortTitle,
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
                    Icon(Icons.chevron_right, size: _sizeDefault, color: Colors.indigo),
                  ],
                ),
                style: buttonStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
