import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/ui/details/activity_detail_card_header_row.dart';
import 'package:track_my_indoor_exercise/ui/details/activity_detail_header_text_row.dart';
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

  testWidgets('ActivityDetailHeaderTextRow renders icon and text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ActivityDetailHeaderTextRow(
            themeManager: mockThemeManager,
            icon: Icons.title,
            iconSize: 24,
            text: 'Header Text',
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );

    expect(find.byType(FitHorizontally), findsOneWidget);
    expect(find.byIcon(Icons.title), findsOneWidget);
    expect(find.text('Header Text'), findsOneWidget);
  });

  testWidgets('ActivityDetailCardHeaderRow renders items correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ActivityDetailCardHeaderRow(
            themeManager: mockThemeManager,
            icon: Icons.analytics,
            iconSize: 24,
            statName: 'Statistic',
            text: '100',
            textStyle: const TextStyle(fontSize: 20),
            unitText: 'km',
            unitStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );

    expect(find.byType(FitHorizontally), findsOneWidget);
    expect(find.byIcon(Icons.analytics), findsOneWidget);
    expect(find.text('Statistic'), findsOneWidget);
    expect(find.byType(TextOneLine), findsOneWidget);
    expect(find.text('km'), findsOneWidget);
  });
}
