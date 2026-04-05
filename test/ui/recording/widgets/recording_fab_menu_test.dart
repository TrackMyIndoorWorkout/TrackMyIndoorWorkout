import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/ui/recording/widgets/recording_fab_menu.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';

class MockThemeManager extends Mock implements ThemeManager {}

class MockFitnessEquipment extends Mock implements FitnessEquipment {}

void main() {
  late MockThemeManager mockThemeManager;
  late GlobalKey<FabCircularMenuPlusState> fabKey;

  setUpAll(() {
    registerFallbackValue(Icons.add);
    registerFallbackValue(Colors.red);
  });

  setUp(() {
    mockThemeManager = MockThemeManager();
    fabKey = GlobalKey<FabCircularMenuPlusState>();

    when(() => mockThemeManager.getAntagonistColor()).thenReturn(Colors.white);
    when(() => mockThemeManager.getBlueColor()).thenReturn(Colors.blue);
    when(() => mockThemeManager.getBlueColorInverse()).thenReturn(Colors.blueAccent);

    // Default mocks
    when(() => mockThemeManager.getBlueFab(any(), any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getGreenFab(any(), any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getTutorialFab(any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getGreenFabWKey(any(), any(), any())).thenReturn(const SizedBox());
  });

  testWidgets('RecordingFabMenu shows Start button when not measuring', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordingFabMenu(
            fabKey: fabKey,
            themeManager: mockThemeManager,
            isLocked: false,
            measuring: false,
            busy: false,
            circuitWorkout: false,
            heartRateMonitorWorkout: false,
            fitnessEquipment: null,
            instantOnStage: false,
            onStageStatisticsType: "none",
            onStartStop: () {},
            onUpload: () async {},
            onHrmPairing: () async {},
            onCadencePairing: () async {},
            onLock: () {},
            onUnlock: () {},
            onStage: () {},
            onTutorial: () {},
            unlockKeys: const [],
            unlockButtonIndex: 0,
          ),
        ),
      ),
    );

    verify(() => mockThemeManager.getBlueFab(Icons.play_arrow, any())).called(1);
    // Verify tutorial button is present
    verify(() => mockThemeManager.getTutorialFab(any())).called(1);
  });

  testWidgets('RecordingFabMenu shows Stop button when measuring', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordingFabMenu(
            fabKey: fabKey,
            themeManager: mockThemeManager,
            isLocked: false,
            measuring: true,
            busy: false,
            circuitWorkout: false,
            heartRateMonitorWorkout: false,
            fitnessEquipment: null,
            instantOnStage: false,
            onStageStatisticsType: "none",
            onStartStop: () {},
            onUpload: () async {},
            onHrmPairing: () async {},
            onCadencePairing: () async {},
            onLock: () {},
            onUnlock: () {},
            onStage: () {},
            onTutorial: () {},
            unlockKeys: const [],
            unlockButtonIndex: 0,
          ),
        ),
      ),
    );

    verify(() => mockThemeManager.getBlueFab(Icons.stop, any())).called(1);
  });

  testWidgets('RecordingFabMenu shows Lock when measuring', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordingFabMenu(
            fabKey: fabKey,
            themeManager: mockThemeManager,
            isLocked: false,
            measuring: true,
            busy: false,
            circuitWorkout: false,
            heartRateMonitorWorkout: false,
            fitnessEquipment: null,
            instantOnStage: true,
            onStageStatisticsType: "none",
            onStartStop: () {},
            onUpload: () async {},
            onHrmPairing: () async {},
            onCadencePairing: () async {},
            onLock: () {},
            onUnlock: () {},
            onStage: () {},
            onTutorial: () {},
            unlockKeys: const [],
            unlockButtonIndex: 0,
          ),
        ),
      ),
    );

    // Lock button (GreenFab) should be present
    verify(() => mockThemeManager.getGreenFab(Icons.lock_open, any())).called(1);

    // Stage button hidden because instantOnStage is true
    verifyNever(() => mockThemeManager.getBlueFab(Icons.sports_score, any()));
  });

  testWidgets('RecordingFabMenu shows Unlock Game when locked', (WidgetTester tester) async {
    final unlockKeys = List.generate(6, (index) => GlobalKey());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordingFabMenu(
            fabKey: fabKey,
            themeManager: mockThemeManager,
            isLocked: true,
            measuring: true,
            busy: false,
            circuitWorkout: false,
            heartRateMonitorWorkout: false,
            fitnessEquipment: null,
            instantOnStage: true,
            onStageStatisticsType: "none",
            onStartStop: () {},
            onUpload: () async {},
            onHrmPairing: () async {},
            onCadencePairing: () async {},
            onLock: () {},
            onUnlock: () {},
            onStage: () {},
            onTutorial: () {},
            unlockKeys: unlockKeys,
            unlockButtonIndex: 2,
            unlockChoices: 6,
          ),
        ),
      ),
    );

    // Should call getGreenFabWKey 6 times
    verify(() => mockThemeManager.getGreenFabWKey(Icons.lock_open, any(), any())).called(1);

    // Verify STRICT MODE: No other buttons should be present
    // Start/Stop button
    verifyNever(() => mockThemeManager.getBlueFab(Icons.stop, any()));
    verifyNever(() => mockThemeManager.getBlueFab(Icons.play_arrow, any()));
    // HRM Pairing
    verifyNever(() => mockThemeManager.getBlueFab(Icons.favorite, any()));
    // Cadence Pairing
    verifyNever(() => mockThemeManager.getBlueFab(Icons.sensors, any()));
  });

  testWidgets('RecordingFabMenu shows HRM button when appropriate', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordingFabMenu(
            fabKey: fabKey,
            themeManager: mockThemeManager,
            isLocked: false,
            measuring: false,
            busy: false,
            circuitWorkout: false,
            heartRateMonitorWorkout: false,
            fitnessEquipment: null,
            instantOnStage: false,
            onStageStatisticsType: "none",
            onStartStop: () {},
            onUpload: () async {},
            onHrmPairing: () async {},
            onCadencePairing: () async {},
            onLock: () {},
            onUnlock: () {},
            onStage: () {},
            onTutorial: () {},
            unlockKeys: const [],
            unlockButtonIndex: 0,
          ),
        ),
      ),
    );

    verify(() => mockThemeManager.getBlueFab(Icons.favorite, any())).called(1);
  });
}
