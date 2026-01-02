import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/ui/find_devices/logic/find_devices_controller.dart';
import 'package:track_my_indoor_exercise/ui/find_devices/widgets/scanned_devices_list.dart';
import 'package:track_my_indoor_exercise/ui/parts/scan_result.dart'; // Tile
import 'package:track_my_indoor_exercise/utils/address_names.dart';
import 'package:track_my_indoor_exercise/devices/company_registry.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';

class MockFindDevicesController extends GetxController with Mock implements FindDevicesController {}

class MockScanResult extends Mock implements ScanResult {}

class MockCompanyRegistry extends Mock implements CompanyRegistry {}

class MockThemeManager extends Mock implements ThemeManager {}

class MockAddressNames extends Mock implements AddressNames {}

class MockAdvertisementData extends Mock implements AdvertisementData {}

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

class MockDeviceIdentifier extends Mock implements DeviceIdentifier {}

// Needed to mock scanStreamController property unless I mock the property getter
// But FindDevicesController has public field scanStreamController.
// Mocking fields requires `when(() => controller.field).thenReturn(...)`.

void main() {
  late MockFindDevicesController mockController;
  late StreamController<List<ScanResult>> scanStreamController;
  late MockScanResult mockScanResult;
  late MockBluetoothDevice mockDevice;
  late MockDeviceIdentifier mockDeviceId;
  late MockAdvertisementData mockAdvertisementData;
  late MockCompanyRegistry mockCompanyRegistry;
  late MockThemeManager mockThemeManager;
  late MockAddressNames mockAddressNames;

  setUpAll(() {
    registerFallbackValue(Icons.error);
    registerFallbackValue(MockScanResult());
    registerFallbackValue(Colors.red);
    registerFallbackValue(const TextStyle());
  });

  setUp(() {
    mockController = MockFindDevicesController();
    scanStreamController = StreamController<List<ScanResult>>.broadcast();

    mockDevice = MockBluetoothDevice();
    mockDeviceId = MockDeviceIdentifier();
    mockScanResult = MockScanResult();
    mockAdvertisementData = MockAdvertisementData();
    mockCompanyRegistry = MockCompanyRegistry();
    mockThemeManager = MockThemeManager();
    mockAddressNames = MockAddressNames();

    Get.put<CompanyRegistry>(mockCompanyRegistry);
    Get.put<ThemeManager>(mockThemeManager);
    Get.put<AddressNames>(mockAddressNames);

    when(() => mockDevice.remoteId).thenReturn(mockDeviceId);
    when(() => mockDeviceId.str).thenReturn("11:22:33:44:55:66");
    when(() => mockDevice.platformName).thenReturn("Gym Equipment");

    when(() => mockScanResult.device).thenReturn(mockDevice);
    when(() => mockScanResult.rssi).thenReturn(-50);
    when(() => mockScanResult.advertisementData).thenReturn(mockAdvertisementData);
    when(() => mockAdvertisementData.connectable).thenReturn(true);
    when(() => mockAdvertisementData.manufacturerData).thenReturn({});
    when(() => mockAdvertisementData.serviceUuids).thenReturn([]); // Empty service UUIDs
    // uuids is extension, relies on serviceUuids
    when(() => mockAdvertisementData.serviceData).thenReturn({}); // Empty service data
    when(() => mockAdvertisementData.advName).thenReturn("Adv Name");

    // CompanyRegistry mock
    when(() => mockCompanyRegistry.nameForId(any())).thenReturn("Test Company");

    // ThemeManager default mocks
    when(() => mockThemeManager.getProtagonistColor()).thenReturn(Colors.black);
    when(() => mockThemeManager.getAntagonistColor()).thenReturn(Colors.white);
    when(() => mockThemeManager.getGreyColor()).thenReturn(Colors.grey);
    when(() => mockThemeManager.getBlueColor()).thenReturn(Colors.blue);
    when(
      () => mockThemeManager.getGreenFab(any(), any()),
    ).thenReturn(const SizedBox(width: 40, height: 40));
    when(
      () => mockThemeManager.getIconFab(any(), any(), any()),
    ).thenReturn(const SizedBox(width: 40, height: 40));

    when(
      () => mockThemeManager.boldStyle(any(), fontSizeFactor: any(named: 'fontSizeFactor')),
    ).thenAnswer((invocation) => invocation.positionalArguments[0] as TextStyle);

    // Mimic ScanResult behavior: advertisementData needed for 'isWorthy'?
    // isWorthy checks name or UUIDs.
    // If name "Gym Equipment" is set, is it worthy?
    // filterDevices bool in controller determines strictness.

    when(() => mockController.scanStreamController).thenReturn(scanStreamController);
    when(() => mockController.filterDevices).thenReturn(false); // Accepting all
    when(() => mockController.deviceSport).thenReturn({});
    when(() => mockController.mediaSizeMin).thenReturn(300.0);
    when(() => mockController.onEquipmentTap(any())).thenAnswer((_) async {});
    when(() => mockController.onHrmTap(any())).thenAnswer((_) async {});

    Get.put<FindDevicesController>(mockController);
  });

  tearDown(() {
    scanStreamController.close();
    Get.reset();
  });

  testWidgets('ScannedDevicesList renders devices from stream', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: ScannedDevicesList(), // Uses GetView<FindDevicesController>
        ),
      ),
    );

    expect(find.byType(ScanResultTile), findsNothing);

    // Emit scan results
    scanStreamController.add([mockScanResult]);
    await tester.pumpAndSettle();

    expect(find.byType(ScanResultTile), findsOneWidget);
    // Check if tile displays name (via ScanResultTile logic)
    // ScanResultTile logic inside: uses result.device.name etc.
    // We mocked platformName "Gym Equipment".
    // ScanResultTile uses 'device.nonEmptyName' usually?
    // Actually ScanResultTile logic is complex (uses expansion).

    // Tap test
    await tester.tap(find.byType(ScanResultTile));
    // ScanResultTile usually expands on tap?
    // It has `onTap` which expands.
    // Logic for `onEquipmentTap` is passed to the tile.
    // ScanResultTile has CONNECT button inside?
    // Looking at `ScanResultTile` source:
    // It has "CONNECT" button (ElevatedButton) for equipment or HRM.
    // `ScannedDevicesList` passes `onEquipmentTap` and `onHrmTap`.
    // We should trigger one of them.

    // Find "CONNECT" text or button.
    // Wait, ScanResultTile displays "Open" or "Connect".
    // I should check `lib/ui/parts/scan_result.dart`.
  });
}
