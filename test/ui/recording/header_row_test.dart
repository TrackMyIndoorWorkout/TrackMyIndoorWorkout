import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';
import 'package:track_my_indoor_exercise/preferences/palette_spec.dart';
import 'package:track_my_indoor_exercise/preferences/stage_mode.dart';
import 'package:track_my_indoor_exercise/preferences/time_display_mode.dart';
import 'package:track_my_indoor_exercise/ui/recording/header_row.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';

class MockThemeManager extends Mock implements ThemeManager {}

void main() {
  late MockThemeManager mockThemeManager;
  late PaletteSpec paletteSpec;

  setUpAll(() {
    registerFallbackValue(Icons.timer);
  });

  setUp(() {
    mockThemeManager = MockThemeManager();
    when(() => mockThemeManager.getBlueIcon(any(), any())).thenAnswer(
      (invocation) => Icon(
        invocation.positionalArguments[0] as IconData,
        size: invocation.positionalArguments[1] as double,
        color: Colors.blue,
      ),
    );
    when(() => mockThemeManager.getRedIcon(any(), any())).thenAnswer(
      (invocation) => Icon(
        invocation.positionalArguments[0] as IconData,
        size: invocation.positionalArguments[1] as double,
        color: Colors.red,
      ),
    );

    paletteSpec = PaletteSpec();
    // Populate palette for size 5 (used in HIIT logic)
    paletteSpec.lightFgPalette[5] = [
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.red,
    ];
  });

  testWidgets('displays single time in standard mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: RecordingHeaderRow(
            themeManager: mockThemeManager,
            onStageStatisticsType: onStageStatisticsTypeNone,
            movingTimeDisplay: '',
            elapsedTimeDisplay: '',
            singleTimeDisplay: '12:34',
            timeDisplayMode: timeDisplayModeMoving,
            workoutState: WorkoutState.moving,
            paletteSpec: paletteSpec,
            baseTimeStyle: const TextStyle(fontSize: 20, color: Colors.black),
            measurementStyle: const TextStyle(fontSize: 18, color: Colors.grey),
            iconSize: 24,
          ),
        ),
      ),
    );

    expect(find.text('12:34'), findsOneWidget);
    expect(find.byIcon(Icons.timer), findsOneWidget);
    final icon = tester.widget<Icon>(find.byIcon(Icons.timer));
    expect(icon.color, Colors.blue); // Standard icon
  });

  testWidgets('displays moving and elapsed time in split mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: RecordingHeaderRow(
            themeManager: mockThemeManager,
            onStageStatisticsType: onStageStatisticsTypeAverage,
            movingTimeDisplay: '10:00',
            elapsedTimeDisplay: '12:00',
            singleTimeDisplay: '',
            timeDisplayMode: timeDisplayModeMoving,
            workoutState: WorkoutState.moving,
            paletteSpec: paletteSpec,
            baseTimeStyle: const TextStyle(fontSize: 20, color: Colors.black),
            measurementStyle: const TextStyle(fontSize: 18, color: Colors.grey),
            iconSize: 24,
          ),
        ),
      ),
    );

    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('12:00'), findsOneWidget);
    expect(find.byIcon(Icons.timer), findsOneWidget);
  });

  testWidgets('displays HIIT styling when active', (WidgetTester tester) async {
    // Palette index 4 is Red in our mock setup.
    // Logic: [WorkoutState.justPaused, WorkoutState.paused] uses index 0.
    // others use index 4.
    // And icon uses getRedIcon.

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: RecordingHeaderRow(
            themeManager: mockThemeManager,
            onStageStatisticsType: onStageStatisticsTypeNone,
            movingTimeDisplay: '',
            elapsedTimeDisplay: '',
            singleTimeDisplay: '12:34',
            timeDisplayMode: timeDisplayModeHIITMoving,
            workoutState: WorkoutState.moving,
            paletteSpec: paletteSpec,
            baseTimeStyle: const TextStyle(fontSize: 20, color: Colors.black),
            measurementStyle: const TextStyle(fontSize: 18, color: Colors.grey),
            iconSize: 24,
          ),
        ),
      ),
    );

    expect(find.text('12:34'), findsOneWidget);

    // Check text style color
    // It should use paletteSpec.lightFgPalette[5][4] => Colors.red
    final textWidget = tester.widget<Text>(find.text('12:34'));
    expect(textWidget.style?.color, Colors.red);

    // Check icon color
    // Should be from getRedIcon => Colors.red
    final icon = tester.widget<Icon>(find.byIcon(Icons.timer));
    expect(icon.color, Colors.red);
  });

  testWidgets('reverts to normal styling when HIIT mode is inactive or waiting', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: RecordingHeaderRow(
            themeManager: mockThemeManager,
            onStageStatisticsType: onStageStatisticsTypeNone,
            movingTimeDisplay: '',
            elapsedTimeDisplay: '',
            singleTimeDisplay: '12:34',
            timeDisplayMode: timeDisplayModeHIITMoving,
            workoutState: WorkoutState.waitingForFirstMove, // Inactive state for styling
            paletteSpec: paletteSpec,
            baseTimeStyle: const TextStyle(fontSize: 20, color: Colors.black),
            measurementStyle: const TextStyle(fontSize: 18, color: Colors.grey),
            iconSize: 24,
          ),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.text('12:34'));
    expect(textWidget.style?.color, Colors.black); // Base style

    final icon = tester.widget<Icon>(find.byIcon(Icons.timer));
    expect(icon.color, Colors.blue); // Base blue icon
  });
}
