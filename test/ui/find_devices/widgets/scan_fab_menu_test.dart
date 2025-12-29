import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/ui/find_devices/logic/find_devices_controller.dart';
import 'package:track_my_indoor_exercise/ui/find_devices/widgets/scan_fab_menu.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';

class MockFindDevicesController extends GetxController with Mock implements FindDevicesController {}

class MockThemeManager extends Mock implements ThemeManager {}

void main() {
  late MockFindDevicesController mockController;
  late MockThemeManager mockThemeManager;

  setUpAll(() {
    registerFallbackValue(Icons.add);
    registerFallbackValue(Colors.red);
  });

  setUp(() {
    mockController = MockFindDevicesController();
    mockThemeManager = MockThemeManager();

    // Setup dependency injection for GetView
    Get.put<FindDevicesController>(mockController);

    // Setup ThemeManager mock in Controller
    when(() => mockController.themeManager).thenReturn(mockThemeManager);

    // Default mocks for ThemeManager colors and icons
    when(() => mockThemeManager.getAntagonistColor()).thenReturn(Colors.white);
    when(() => mockThemeManager.getBlueColor()).thenReturn(Colors.blue);
    when(() => mockThemeManager.getBlueColorInverse()).thenReturn(Colors.blueAccent);

    // Default mocks for FAB builders
    when(() => mockThemeManager.getTutorialFab(any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getAboutFab()).thenReturn(const SizedBox());
    when(() => mockThemeManager.getBlueFab(any(), any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getGreenFab(any(), any())).thenReturn(const SizedBox());
  });

  tearDown(() {
    Get.delete<FindDevicesController>();
  });

  testWidgets('ScanFabMenu renders FabCircularMenuPlus', (WidgetTester tester) async {
    when(() => mockController.isScanning).thenReturn(false);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ScanFabMenu())));

    expect(find.byType(FabCircularMenuPlus), findsOneWidget);
  });

  testWidgets('ScanFabMenu shows Stop button when scanning', (WidgetTester tester) async {
    when(() => mockController.isScanning).thenReturn(true);
    // Mock getBlueFab specifically to verify call
    when(() => mockThemeManager.getBlueFab(Icons.stop, any())).thenReturn(const Text('Stop Scan'));

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ScanFabMenu())));

    // Since FabCircularMenuPlus might not render children immediately or might hide them,
    // we largely verify that the correct builder method was called on ThemeManager.
    // However, the children are passed to FabCircularMenuPlus constructor, so they are built.
    verify(() => mockThemeManager.getBlueFab(Icons.stop, any())).called(1);
  });

  testWidgets('ScanFabMenu shows Search button when not scanning', (WidgetTester tester) async {
    when(() => mockController.isScanning).thenReturn(false);
    when(
      () => mockThemeManager.getGreenFab(Icons.search, any()),
    ).thenReturn(const Text('Start Scan'));

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ScanFabMenu())));

    verify(() => mockThemeManager.getGreenFab(Icons.search, any())).called(1);
  });
}
