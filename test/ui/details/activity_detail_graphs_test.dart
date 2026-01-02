import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:track_my_indoor_exercise/preferences/metric_spec.dart';
import 'package:track_my_indoor_exercise/preferences/palette_spec.dart';
import 'package:track_my_indoor_exercise/ui/details/activity_detail_graphs.dart';
import 'package:track_my_indoor_exercise/ui/models/tile_configuration.dart';
import 'package:track_my_indoor_exercise/ui/models/display_record.dart';
import 'package:track_my_indoor_exercise/ui/models/histogram_data.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';

class MockThemeManager extends Mock implements ThemeManager {}

class MockMetricSpec extends Mock implements MetricSpec {}

class MockPaletteSpec extends Mock implements PaletteSpec {}

class FakeMetricSpec extends Fake implements MetricSpec {}

void main() {
  late MockThemeManager mockThemeManager;
  late MockMetricSpec mockMetricSpec;
  late MockPaletteSpec mockPaletteSpec;

  setUpAll(() {
    registerFallbackValue(Icons.error);
    registerFallbackValue(FakeMetricSpec());
  });

  setUp(() {
    mockThemeManager = MockThemeManager();
    mockMetricSpec = MockMetricSpec();
    mockPaletteSpec = MockPaletteSpec();

    when(
      () => mockThemeManager.getBlueIcon(any(), any()),
    ).thenAnswer((invocation) => const Icon(Icons.check));
    when(() => mockMetricSpec.icon).thenReturn(Icons.speed);
    when(() => mockMetricSpec.multiLineUnit).thenReturn('km/h');
    when(() => mockMetricSpec.plotBands).thenReturn(<PlotBand>[]); // Return empty list

    when(() => mockPaletteSpec.getPiePalette(any(), any())).thenReturn([Colors.red, Colors.blue]);
  });

  testWidgets('ActivityDetailGraphs renders header and expands to show charts', (
    WidgetTester tester,
  ) async {
    final tileConfig = TileConfiguration(
      title: 'Speed',
      histogramTitle: 'Speed Zones',
      dataFn: () => <LineSeries<DisplayRecord, DateTime>>[],
      maxString: '30.0',
      avgString: '20.0',
      medianString: '25.0',
    );
    // Explicitly set histogramFn as it's passed to SfCircularChart
    tileConfig.histogramFn = () => <CircularSeries<HistogramData, String>>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SingleChildScrollView(
            child: ActivityDetailGraphs(
              item: 'speed',
              index: 0,
              size: const Size(400, 800),
              expandableThemeData: const ExpandableThemeData(),
              textStyle: const TextStyle(),
              measurementStyle: const TextStyle(),
              unitStyle: const TextStyle(),
              chartLabelStyle: const TextStyle(),
              chartTextColor: Colors.black,
              tileConfiguration: tileConfig,
              preferencesSpec: mockMetricSpec,
              si: true,
              sport: 'ride',
              isLight: true,
              sizeDefault: 24,
              paletteSpec: mockPaletteSpec,
              themeManager: mockThemeManager,
              displayMedian: true,
            ),
          ),
        ),
      ),
    );

    // Check Header Content
    // Check Header Content
    expect(find.text('MAX'), findsOneWidget);
    expect(find.text('AVG'), findsOneWidget);
    expect(find.text('MED'), findsOneWidget);

    // Title, Max, Avg, Med, SpeedUnit, SpeedZones are TextOneLine (Total 6)
    // Note: ExpandablePanel keeps content in tree even when collapsed
    expect(find.byType(TextOneLine), findsNWidgets(6));

    // Tap to expand (ensure interactivity works)
    await tester.tap(find.byType(ExpandablePanel));
    await tester.pumpAndSettle();

    // Check Expanded Content
    expect(find.byType(TextOneLine), findsNWidgets(6));
    expect(find.byType(SfCartesianChart), findsOneWidget);
    expect(find.byType(SfCircularChart), findsOneWidget);
  });
}
