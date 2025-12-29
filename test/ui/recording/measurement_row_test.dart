import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/ui/recording/measurement_row.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';

class MockThemeManager extends Mock implements ThemeManager {}

void main() {
  late MockThemeManager mockThemeManager;

  setUpAll(() {
    registerFallbackValue(Icons.error);
  });

  setUp(() {
    mockThemeManager = MockThemeManager();
    when(() => mockThemeManager.getBlueColor()).thenReturn(Colors.blue);
    when(() => mockThemeManager.getBlueIcon(any(), any())).thenAnswer(
      (invocation) => Icon(
        invocation.positionalArguments[0] as IconData,
        size: invocation.positionalArguments[1] as double,
        color: Colors.blue,
      ),
    );
  });

  testWidgets('MeasurementRow divider layout renders Divider', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeasurementRow(
            themeManager: mockThemeManager,
            layout: MeasurementRowLayout.divider,
            icon: Icons.abc,
            iconSize: 24,
            value: '',
            unit: '',
            measurementStyle: const TextStyle(),
            unitStyle: const TextStyle(),
            fullUnitStyle: const TextStyle(),
            expandable: false,
          ),
        ),
      ),
    );

    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('MeasurementRow standard layout renders value and unit', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeasurementRow(
            themeManager: mockThemeManager,
            layout: MeasurementRowLayout.standard,
            icon: Icons.flash_on,
            iconSize: 24,
            value: '100',
            unit: 'W',
            measurementStyle: const TextStyle(),
            unitStyle: const TextStyle(),
            fullUnitStyle: const TextStyle(),
            expandable: false,
          ),
        ),
      ),
    );

    expect(find.text('100'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);
    expect(find.byIcon(Icons.flash_on), findsOneWidget);
    // Should use default blue icon since no valid color was passed?
    // MeasurementRow uses iconColor for icon.
    // In standard layout:
    // Icon(icon, color: effectiveIconColor, size: iconSize)
    // effectiveIconColor = iconColor ?? themeManager.getBlueColor()
    // We didn't pass iconColor, so it uses blue.
    final icon = tester.widget<Icon>(find.byIcon(Icons.flash_on));
    expect(icon.color, Colors.blue);
  });

  testWidgets('MeasurementRow split layout renders value, unit, and statistic', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeasurementRow(
            themeManager: mockThemeManager,
            layout: MeasurementRowLayout.split,
            icon: Icons.speed,
            iconSize: 24,
            value: '25',
            unit: 'km',
            statistic: '20',
            measurementStyle: const TextStyle(),
            unitStyle: const TextStyle(),
            fullUnitStyle: const TextStyle(),
            expandable: false,
          ),
        ),
      ),
    );

    expect(find.text('25'), findsOneWidget);
    expect(find.text('km'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.byIcon(Icons.speed), findsOneWidget);
  });

  testWidgets('MeasurementRow applies iconColor', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeasurementRow(
            themeManager: mockThemeManager,
            layout: MeasurementRowLayout.standard,
            icon: Icons.favorite,
            iconColor: Colors.red,
            iconSize: 24,
            value: '150',
            unit: 'bpm',
            measurementStyle: const TextStyle(),
            unitStyle: const TextStyle(color: Colors.black), // base unit style
            fullUnitStyle: const TextStyle(color: Colors.black),
            expandable: false,
          ),
        ),
      ),
    );

    // Icon should be red
    final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
    expect(icon.color, Colors.red);

    // Unit text style should have overridden color (red)
    final unitText = tester.widget<Text>(find.text('bpm'));
    expect(unitText.style?.color, Colors.red);
  });
}
