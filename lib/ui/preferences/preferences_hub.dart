import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuple/tuple.dart';
import '../../upload/constants.dart';
import '../../upload/upload_service.dart';
import '../../utils/constants.dart';
import '../../utils/sound.dart';
import 'athlete.dart';
import 'data.dart';
import 'equipment.dart';
import 'expert.dart';
import 'heart_rate.dart';
import 'integrations.dart';
import 'leaderboard.dart';
import 'target_heart_rate.dart';
import 'user_experience_preferences.dart';
import 'workout.dart';
import 'zones_hub.dart';

class PreferencesHubScreen extends StatefulWidget {
  const PreferencesHubScreen({super.key});

  @override
  PreferencesHubScreenState createState() => PreferencesHubScreenState();
}

class PreferencesHubScreenState extends State<PreferencesHubScreen> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SoundService>()) {
      Get.put<SoundService>(SoundService(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineSmall!.apply(
          fontFamily: fontFamily,
          color: Colors.white,
        );
    final sizeDefault = textStyle.fontSize! * 2;

    final keyPart = portalNames
        .asMap()
        .entries
        .map((e) => UploadService.isIntegrationEnabled(e.value) ? "1" : "0")
        .toList()
        .join("_");
    final integrationsKey = "integrations$keyPart";
    final List<Tuple2<String, Function>> screenConfigs = [
      Tuple2(UserExperiencePreferencesScreen.shortTitle,
          () => const UserExperiencePreferencesScreen()),
      Tuple2(DataPreferencesScreen.shortTitle, () => const DataPreferencesScreen()),
      Tuple2(HeartRatePreferencesScreen.shortTitle, () => const HeartRatePreferencesScreen()),
      Tuple2(TargetHrPreferencesScreen.shortTitle, () => const TargetHrPreferencesScreen()),
      Tuple2(ZonesHubScreen.shortTitle, () => const ZonesHubScreen()),
      Tuple2(LeaderboardPreferencesScreen.shortTitle, () => const LeaderboardPreferencesScreen()),
      Tuple2(AthletePreferencesScreen.shortTitle, () => const AthletePreferencesScreen()),
      Tuple2(EquipmentPreferencesScreen.shortTitle, () => const EquipmentPreferencesScreen()),
      Tuple2(WorkoutPreferencesScreen.shortTitle, () => const WorkoutPreferencesScreen()),
      Tuple2(IntegrationPreferencesScreen.shortTitle,
          () => IntegrationPreferencesScreen(key: Key(integrationsKey))),
      Tuple2(ExpertPreferencesScreen.shortTitle, () => const ExpertPreferencesScreen()),
    ];

    final List<Widget> screens = screenConfigs
        .map(
          (c) => Container(
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () => Get.to(c.item2),
              child: FitHorizontally(
                shrinkLimit: shrinkLimit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(c.item1, style: textStyle),
                    Icon(Icons.chevron_right, size: sizeDefault),
                  ],
                ),
              ),
            ),
          ),
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: ListView(
        children: screens,
      ),
    );
  }
}
