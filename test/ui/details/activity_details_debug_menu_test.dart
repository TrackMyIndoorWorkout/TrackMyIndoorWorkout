import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/activity.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/ui/details/activity_details.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';

import '../../database/in_memory_database.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    Get.put<Isar>(InMemoryDatabase("activity_details_test_db"), permanent: true);
    await initPrefServiceForTest();
    Get.put<ThemeManager>(ThemeManager());
  });

  testWidgets('Wrench icon in debug mode opens debug actions sheet and shows all actions', (
    WidgetTester tester,
  ) async {
    final isar = Get.find<Isar>() as InMemoryDatabase;
    isar.records.clearSync();
    isar.activities.clearSync();

    final startTime = DateTime(2026, 11, 13, 10, 0, 0);
    final activity = Activity(
      id: 55,
      deviceName: "Schwinn IC4",
      deviceId: "AA:BB:CC:DD:EE:FF",
      hrmId: "test_hrm",
      start: startTime,
      end: startTime.add(const Duration(minutes: 5)),
      distance: 2000.0,
      elapsed: 300,
      movingTime: 300000,
      calories: 100,
      fourCC: schwinnICBikeFourCC,
      sport: ActivityType.ride,
      powerFactor: 1.0,
      calorieFactor: 1.0,
      hrCalorieFactor: 1.0,
      hrmCalorieFactor: 1.0,
      hrBasedCalories: false,
      timeZone: "America/Los_Angeles",
    );
    isar.activities.putSync(activity);

    final records = <Record>[
      for (int i = 0; i < 5; i++)
        Record(
          id: i + 1,
          activityId: activity.id,
          timeStamp: startTime.add(Duration(seconds: i)),
          elapsed: i,
          distance: i * 5.0,
          speed: 10.0 + i * 5.0,
          cadence: 60 + i * 10,
          power: 100 + i * 50,
          heartRate: 110 + i * 10,
          calories: i,
        ),
    ];
    isar.records.putAllSync(records);

    final prefService = Get.find<BasePrefService>();

    await tester.pumpWidget(
      PrefService(
        service: prefService,
        child: GetMaterialApp(
          home: Scaffold(
            body: ActivityDetailsScreen(activity: activity, size: const Size(400, 800)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify wrench icon exists in AppBar
    final buildButton = find.byIcon(Icons.build);
    expect(buildButton, findsOneWidget);

    final state = tester.state<ActivityDetailsScreenState>(find.byType(ActivityDetailsScreen));
    expect(state, isNotNull);

    // Call showDebugActionsMenu
    state.showDebugActionsMenu();
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Verify debug bottom sheet options are presented
    expect(find.text("Activity Debug Actions (#${activity.id})"), findsOneWidget);
    expect(find.text("Recalculate Activity"), findsOneWidget);
    expect(find.text("Finalize Activity"), findsOneWidget);
    expect(find.text("Clear Suunto Upload Flag"), findsOneWidget);
    expect(find.text("Offset Activity..."), findsOneWidget);
    expect(find.text("Split Activity..."), findsOneWidget);
    expect(find.text("Append Activity..."), findsOneWidget);

    // Test Clear Suunto Upload Flag action
    activity.suuntoUploadInitiated("upload_123", "blob_url");
    activity.markSuuntoUploaded("workout_url");
    expect(activity.suuntoUploaded, isTrue);

    await tester.tap(find.text("Clear Suunto Upload Flag"));
    await tester.pumpAndSettle();

    expect(activity.suuntoUploaded, isFalse);
    expect(activity.suuntoUploadIdentifier, isEmpty);

    // Test Offset Activity dialog
    state.showDebugActionsMenu();
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.text("Offset Activity..."));
    await tester.pumpAndSettle();
    expect(find.text("Offset Activity"), findsOneWidget);
    expect(find.text("Enter offset in minutes (can be negative):"), findsOneWidget);
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();

    // Test Split Activity dialog
    state.showDebugActionsMenu();
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.text("Split Activity..."));
    await tester.pumpAndSettle();
    expect(find.text("Split Activity"), findsOneWidget);
    expect(find.text("Split Point (Minutes from start)"), findsOneWidget);
    expect(find.text("Target Activity ID"), findsOneWidget);
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();

    // Test Append Activity dialog
    state.showDebugActionsMenu();
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.text("Append Activity..."));
    await tester.pumpAndSettle();
    expect(find.text("Append Activity"), findsOneWidget);
    expect(find.text("Later Activity ID to append"), findsOneWidget);
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();

    // Test Recalculate Activity confirmation prompt
    state.showDebugActionsMenu();
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.text("Recalculate Activity"));
    await tester.pumpAndSettle();
    expect(find.text("Warning!!!"), findsOneWidget);
    expect(find.text("Are you sure to recalculate?"), findsOneWidget);
    await tester.tap(find.text("No"));
    await tester.pumpAndSettle();
  });
}
