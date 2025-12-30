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
            onStage: () {},
          ),
        ),
      ),
    );

    verify(() => mockThemeManager.getBlueFab(Icons.play_arrow, any())).called(1);
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
            onStage: () {},
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
            onStage: () {},
          ),
        ),
      ),
    );

    // Lock button (GreenFab) should be present
    verify(() => mockThemeManager.getGreenFab(Icons.lock_open, any())).called(1);

    // Stage button hidden because instantOnStage is true
    verifyNever(() => mockThemeManager.getBlueFab(Icons.sports_score, any()));
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
            onStage: () {},
          ),
        ),
      ),
    );

    verify(() => mockThemeManager.getBlueFab(Icons.favorite, any())).called(1);
  });
}
