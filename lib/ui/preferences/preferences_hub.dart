import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
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
  TextStyle _measurementStyle;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = Get.mediaQuery.size.width;
    if (_mediaWidth == null || (_mediaWidth - mediaWidth).abs() > EPS) {
      _mediaWidth = mediaWidth;
      _sizeDefault = Get.mediaQuery.size.width / 4;
      _measurementStyle = TextStyle(
        fontFamily: FONT_FAMILY,
        fontSize: _sizeDefault / 2.5,
      );
    }
    final separatorHeight = 1.0;

    return Scaffold(
      appBar: AppBar(title: Text('Preferences')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => Get.to(UXPreferencesScreen()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextOneLine(
                    " " + UXPreferencesScreen.shortTitle,
                    style: _measurementStyle,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Icon(Icons.chevron_right, size: _sizeDefault, color: Colors.indigo),
                ],
              ),
            ),
            Divider(height: separatorHeight),
            GestureDetector(
              onTap: () => Get.to(DataPreferencesScreen()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextOneLine(
                    " " + DataPreferencesScreen.shortTitle,
                    style: _measurementStyle,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Icon(Icons.chevron_right, size: _sizeDefault, color: Colors.indigo),
                ],
              ),
            ),
            Divider(height: separatorHeight),
            GestureDetector(
              onTap: () => Get.to(TargetHrPreferencesScreen()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextOneLine(
                    " " + TargetHrPreferencesScreen.shortTitle,
                    style: _measurementStyle,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Icon(Icons.chevron_right, size: _sizeDefault, color: Colors.indigo),
                ],
              ),
            ),
            Divider(height: separatorHeight),
            GestureDetector(
              onTap: () => Get.to(MeasurementZonesPreferencesScreen()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextOneLine(
                    " " + MeasurementZonesPreferencesScreen.shortTitle,
                    style: _measurementStyle,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Icon(Icons.chevron_right, size: _sizeDefault, color: Colors.indigo),
                ],
              ),
            ),
            Divider(height: separatorHeight),
            GestureDetector(
              onTap: () => Get.to(ExpertPreferencesScreen()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextOneLine(
                    " " + ExpertPreferencesScreen.shortTitle,
                    style: _measurementStyle,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Icon(Icons.chevron_right, size: _sizeDefault, color: Colors.indigo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
