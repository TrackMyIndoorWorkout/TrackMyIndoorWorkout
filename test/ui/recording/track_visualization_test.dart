import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/track/calculator.dart';
import 'package:track_my_indoor_exercise/ui/recording/track_visualization.dart';

class MockTrackCalculator extends Mock implements TrackCalculator {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Size(0, 0));
  });

  testWidgets('TrackVisualization renders CustomPaint and markers', (WidgetTester tester) async {
    final mockCalculator = MockTrackCalculator();
    when(() => mockCalculator.calculateConstantsOnDemand(any())).thenReturn(null);
    when(() => mockCalculator.trackPath).thenReturn(Path());
    when(() => mockCalculator.trackStroke).thenReturn(Paint());

    final markers = <Widget>[
      const Positioned(left: 0, top: 0, child: Text('Marker 1')),
      const Center(child: Text('Marker 2')),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TrackVisualization(calculator: mockCalculator, markers: markers, width: 300),
        ),
      ),
    );

    expect(find.text('Marker 1'), findsOneWidget);
    expect(find.text('Marker 2'), findsOneWidget);

    // Find SizedBox wrapping the Stack
    final sizedBoxFinder = find.ancestor(of: find.byType(Stack), matching: find.byType(SizedBox));

    final SizedBox sizedBox = tester.widget(sizedBoxFinder.first);
    expect(sizedBox.width, 300.0);
    expect(sizedBox.height, 300.0 / 1.9);
  });
}
