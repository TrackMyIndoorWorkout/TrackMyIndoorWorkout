import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/preferences/small_screen.dart';
import 'package:track_my_indoor_exercise/utils/display.dart';

class MockBasePrefService extends Mock implements BasePrefService {
  final Map<String, dynamic> _data = {};

  @override
  T? get<T>(String key) => _data[key] as T?;

  @override
  Future<bool> set<T>(String key, T val) async {
    _data[key] = val;
    return true;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

void main() {
  late MockBasePrefService mockPrefs;

  setUp(() {
    mockPrefs = MockBasePrefService();
    // Default values matching production defaults
    mockPrefs.set(smallScreenThresholdTag, smallScreenThresholdDefault);
    mockPrefs.set(smallScreenPaddingTopTag, smallScreenPaddingTopDefault);
    mockPrefs.set(smallScreenPaddingBottomTag, smallScreenPaddingBottomDefault);
    mockPrefs.set(smallScreenPaddingHorizontalTag, smallScreenPaddingHorizontalDefault);
  });

  Widget createSubject() {
    return PrefService(
      service: mockPrefs,
      child: Builder(
        builder: (context) {
          return Center(
            child: SizedBox(
              key: const Key('subject'),
              width: isSmallScreen(context) ? 100 : 200, // 100 on small, 200 on big
              height: smallScreenPaddingTop(context), // Reflects padding pref
            ),
          );
        },
      ),
    );
  }

  testWidgets('isSmallScreen logic with defaults', (tester) async {
    // Watch size 300x300 (Logical)
    tester.view.physicalSize = const Size(300, 300);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createSubject());
    // isSmallScreen should be true -> width 100
    // padding top should be default 40
    expect(find.byKey(const Key('subject')), findsOneWidget);
    final size = tester.getSize(find.byKey(const Key('subject')));
    expect(size.width, 100.0);
    expect(size.height, 40.0);

    // Phone size 360x640 (Logical)
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createSubject());
    // isSmallScreen should be false -> width 200
    final sizePhone = tester.getSize(find.byKey(const Key('subject')));
    expect(sizePhone.width, 200.0);
  });

  testWidgets('isSmallScreen respects custom threshold', (tester) async {
    // Phone size 360x640 (Logical) - normally NOT small
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    // Set high threshold so phone acts as "small screen"
    await mockPrefs.set(smallScreenThresholdTag, 700.0);

    await tester.pumpWidget(createSubject());

    final size = tester.getSize(find.byKey(const Key('subject')));
    expect(size.width, 100.0); // Should be "small" now
  });

  testWidgets('isSmallScreen supports square watches (like 531px)', (tester) async {
    // Square watch size 531x531 (Logical)
    // Threshold is default (480), but square logic allows up to 800 (default) or configurable
    tester.view.physicalSize = const Size(531, 531);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createSubject());

    // isSmallScreen should be true because it's square (531 < 800)
    final size = tester.getSize(find.byKey(const Key('subject')));
    expect(size.width, 100.0);

    // Now verify it respects the specific square threshold
    await mockPrefs.set(smallScreenSquareThresholdTag, 500.0); // Reduce square threshold
    await tester.pumpWidget(createSubject());

    // isSmallScreen should be false now (531 > 500)
    final sizeRejected = tester.getSize(find.byKey(const Key('subject')));
    expect(sizeRejected.width, 200.0);
  });

  testWidgets('Padding preferences are reflected', (tester) async {
    await mockPrefs.set(smallScreenPaddingTopTag, 88.0);

    // We don't care about screen size for this check since layout builder handles it,
    // but the widget reads the pref directly.
    tester.view.physicalSize = const Size(300, 300);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createSubject());

    final size = tester.getSize(find.byKey(const Key('subject')));
    expect(size.height, 88.0); // Height matches mocked padding top
  });

  testWidgets('Horizontal Padding preferences are reflected', (tester) async {
    await mockPrefs.set(smallScreenPaddingHorizontalTag, 20.0);

    // We create a widget that uses horizontal padding
    await tester.pumpWidget(
      PrefService(
        service: mockPrefs,
        child: Builder(
          builder: (context) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: smallScreenPaddingHorizontal(context)),
                child: const SizedBox(key: Key('subject'), width: 50, height: 50),
              ),
            );
          },
        ),
      ),
    );

    // Check if padding is applied.
    // The Padding widget should have padding 20.0 on left and right.
    final paddingWidget = tester.widget<Padding>(find.byType(Padding));
    expect((paddingWidget.padding as EdgeInsets).left, 20.0);
    expect((paddingWidget.padding as EdgeInsets).right, 20.0);
  });
}
