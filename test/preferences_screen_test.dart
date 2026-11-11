import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/ui/preferences/athlete.dart';
import 'package:track_my_indoor_exercise/ui/preferences/data.dart';
import 'package:track_my_indoor_exercise/ui/preferences/equipment.dart';
import 'package:track_my_indoor_exercise/ui/preferences/heart_rate.dart';
import 'package:track_my_indoor_exercise/ui/preferences/preferences_hub.dart';
import 'package:track_my_indoor_exercise/ui/preferences/user_experience_preferences.dart';
import 'package:track_my_indoor_exercise/ui/preferences/workout.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';

void main() {
  setUp(() async {
    Get.reset();
    Get.put<ThemeManager>(ThemeManager());
    await initPrefServiceForTest();
  });

  testWidgets('Preferences screens render without errors', (tester) async {
    final prefService = Get.find<BasePrefService>();

    final screens = [
      const PreferencesHubScreen(),
      const AthletePreferencesScreen(),
      const WorkoutPreferencesScreen(),
      const DataPreferencesScreen(),
      const EquipmentPreferencesScreen(),
      const HeartRatePreferencesScreen(),
      const UserExperiencePreferencesScreen(),
    ];

    for (final screen in screens) {
      await tester.pumpWidget(
        PrefService(
          service: prefService,
          child: GetMaterialApp(home: screen),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
