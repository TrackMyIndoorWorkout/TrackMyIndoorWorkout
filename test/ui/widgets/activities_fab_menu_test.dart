import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/ui/widgets/activities_fab_menu.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';

class MockThemeManager extends Mock implements ThemeManager {}

void main() {
  late MockThemeManager mockThemeManager;

  setUpAll(() {
    registerFallbackValue(Icons.add);
    registerFallbackValue(Colors.red);
  });

  setUp(() {
    mockThemeManager = MockThemeManager();

    when(() => mockThemeManager.getAntagonistColor()).thenReturn(Colors.white);
    when(() => mockThemeManager.getBlueColor()).thenReturn(Colors.blue);
    when(() => mockThemeManager.getBlueColorInverse()).thenReturn(Colors.blueAccent);

    when(() => mockThemeManager.getTutorialFab(any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getAboutFab()).thenReturn(const SizedBox());
    when(() => mockThemeManager.getBlueFab(any(), any())).thenReturn(const SizedBox());
  });

  testWidgets('ActivitiesFabMenu renders basic options', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivitiesFabMenu(
            themeManager: mockThemeManager,
            leaderboardFeature: false,
            hasLeaderboardData: false,
            onTutorial: () {},
            onImport: () async {},
            onDeviceUsages: () async {},
            onPowerTunes: () async {},
            onCalorieTunes: () async {},
            onLeaderboard: () async {},
          ),
        ),
      ),
    );

    verify(() => mockThemeManager.getTutorialFab(any())).called(1);
    verify(() => mockThemeManager.getAboutFab()).called(1);
    verify(() => mockThemeManager.getBlueFab(Icons.file_upload, any())).called(1);
    verify(() => mockThemeManager.getBlueFab(Icons.collections_bookmark, any())).called(1);
    verify(() => mockThemeManager.getBlueFab(Icons.bolt, any())).called(1);
    verify(() => mockThemeManager.getBlueFab(Icons.whatshot, any())).called(1);

    // Leaderboard not active
    verifyNever(() => mockThemeManager.getBlueFab(Icons.leaderboard, any()));
  });

  testWidgets('ActivitiesFabMenu shows Leaderboard option when active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivitiesFabMenu(
            themeManager: mockThemeManager,
            leaderboardFeature: true,
            hasLeaderboardData: true,
            onTutorial: () {},
            onImport: () async {},
            onDeviceUsages: () async {},
            onPowerTunes: () async {},
            onCalorieTunes: () async {},
            onLeaderboard: () async {},
          ),
        ),
      ),
    );

    // Leaderboard active
    verify(() => mockThemeManager.getBlueFab(Icons.leaderboard, any())).called(1);
  });
}
