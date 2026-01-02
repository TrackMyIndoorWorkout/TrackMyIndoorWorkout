import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/ui/details/activity_detail_row.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';

class MockThemeManager extends Mock implements ThemeManager {}

void main() {
  late MockThemeManager mockThemeManager;

  setUpAll(() {
    registerFallbackValue(Icons.error);
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
  });

  testWidgets('ActivityDetailRow renders text and icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityDetailRow(
            themeManager: mockThemeManager,
            icon: Icons.run_circle,
            iconSize: 24,
            text: '10:00',
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );

    expect(find.text('10:00'), findsOneWidget);
    expect(find.byIcon(Icons.run_circle), findsOneWidget);
    // Verify theme manager was called
    verify(() => mockThemeManager.getBlueIcon(Icons.run_circle, 24)).called(1);
  });
}
