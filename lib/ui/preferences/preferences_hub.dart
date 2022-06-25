import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import '../../preferences/enforced_time_zone.dart';
import '../../upload/constants.dart';
import '../../upload/upload_service.dart';
import '../../utils/constants.dart';
import '../../utils/sound.dart';
import 'athlete.dart';
import 'data_preferences.dart';
import 'equipment.dart';
import 'expert.dart';
import 'integrations.dart';
import 'leaderboard.dart';
import 'target_heart_rate.dart';
import 'ux_preferences.dart';
import 'zones_hub.dart';

class PreferencesHubScreen extends StatefulWidget {
  const PreferencesHubScreen({Key? key}) : super(key: key);

  @override
  PreferencesHubScreenState createState() => PreferencesHubScreenState();
}

class PreferencesHubScreenState extends State<PreferencesHubScreen> {
  double _sizeDefault = 10.0;
  TextStyle _textStyle = const TextStyle();

  @override
  void initState() {
    super.initState();
    _textStyle = Get.textTheme.headline5!.apply(
      fontFamily: fontFamily,
      color: Colors.white,
    );
    _sizeDefault = _textStyle.fontSize! * 2;
    if (!Get.isRegistered<SoundService>()) {
      Get.put<SoundService>(SoundService(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyPart = portalNames
        .asMap()
        .entries
        .map((e) => UploadService.isIntegrationEnabled(e.value) ? "1" : "0")
        .toList()
        .join("_");
    final integrationsKey = "integrations$keyPart";
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () => Get.to(() => const UXPreferencesScreen()),
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
              onPressed: () => Get.to(() => const DataPreferencesScreen()),
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
              onPressed: () => Get.to(() => const TargetHrPreferencesScreen()),
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
              onPressed: () => Get.to(() => const ZonesHubScreen()),
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
              onPressed: () => Get.to(() => const LeaderboardPreferencesScreen()),
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
              onPressed: () => Get.to(() => const AthletePreferencesScreen()),
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
              onPressed: () => Get.to(() => const EquipmentPreferencesScreen()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextOneLine(
                    EquipmentPreferencesScreen.shortTitle,
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
              onPressed: () =>
                  Get.to(() => IntegrationPreferencesScreen(key: Key(integrationsKey))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextOneLine(
                    IntegrationPreferencesScreen.shortTitle,
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
                final timeZoneChoicesFixed = await FlutterNativeTimezone.getAvailableTimezones();
                List<String> timeZoneChoices = [];
                timeZoneChoices.addAll(timeZoneChoicesFixed);
                timeZoneChoices.sort();
                timeZoneChoices.insert(0, enforcedTimeZoneDefault);
                Get.to(() => ExpertPreferencesScreen(timeZoneChoices: timeZoneChoices));
              },
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
    );
  }
}
