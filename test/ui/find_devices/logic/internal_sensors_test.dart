import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/internal_sensor_manager.dart';
import 'package:track_my_indoor_exercise/ui/find_devices/logic/find_devices_controller.dart';
import 'package:track_my_indoor_exercise/utils/bluetooth_adapter.dart';
import 'package:track_my_indoor_exercise/ui/models/advertisement_cache.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';
import 'package:track_my_indoor_exercise/utils/address_names.dart';
import 'package:track_my_indoor_exercise/persistence/db_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:track_my_indoor_exercise/preferences/stationary_workout.dart';
import 'package:track_my_indoor_exercise/utils/sound.dart';
import 'package:isar_community/isar.dart';
import 'package:track_my_indoor_exercise/persistence/log_entry.dart';

// Mocks
class MockBluetoothAdapter extends Mock implements BluetoothAdapter {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockAdvertisementCache extends Mock implements AdvertisementCache {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockThemeManager extends Mock implements ThemeManager {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockAddressNames extends Mock implements AddressNames {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockDbUtils extends Mock implements DbUtils {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockBasePrefService extends Mock implements BasePrefService {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockPackageInfo extends Mock implements PackageInfo {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockIsar extends Mock implements Isar {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockSoundService extends Mock implements SoundService {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockInternalSensorManager extends Mock implements InternalSensorManager {}

void main() {
  late FindDevicesController controller;
  late MockBluetoothAdapter mockBluetoothAdapter;
  late MockBasePrefService mockPrefService;
  late MockAdvertisementCache mockAdvertisementCache;
  late MockThemeManager mockThemeManager;
  late MockAddressNames mockAddressNames;
  late MockDbUtils mockDbUtils;
  late MockPackageInfo mockPackageInfo;
  late MockIsar mockIsar;
  late MockSoundService mockSoundService;
  late MockInternalSensorManager mockInternalSensorManager;

  setUpAll(() {
    registerFallbackValue(BluetoothConnectionState.disconnected);
    registerFallbackValue(MockAddressNames());
    registerFallbackValue("fallback_string");
    registerFallbackValue(
      LogEntry(timeStamp: DateTime.now(), level: "", tag: "", subTag: "", message: ""),
    );
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    mockBluetoothAdapter = MockBluetoothAdapter();
    mockPrefService = MockBasePrefService();

    Get.put<BluetoothAdapter>(mockBluetoothAdapter, permanent: true);
    Get.put<BasePrefService>(mockPrefService, permanent: true);
    mockAdvertisementCache = MockAdvertisementCache();
    mockThemeManager = MockThemeManager();
    mockAddressNames = MockAddressNames();
    mockDbUtils = MockDbUtils();
    mockPackageInfo = MockPackageInfo();
    mockIsar = MockIsar();
    mockSoundService = MockSoundService();
    mockInternalSensorManager = MockInternalSensorManager();

    Get.put<BluetoothAdapter>(mockBluetoothAdapter, permanent: true);
    Get.put<BasePrefService>(mockPrefService, permanent: true);
    Get.put<AdvertisementCache>(mockAdvertisementCache, permanent: true);
    Get.put<ThemeManager>(mockThemeManager, permanent: true);
    Get.put<AddressNames>(mockAddressNames, permanent: true);
    Get.put<DbUtils>(mockDbUtils, permanent: true);
    Get.put<PackageInfo>(mockPackageInfo, permanent: true);
    Get.put<Isar>(mockIsar, permanent: true);
    Get.put<SoundService>(mockSoundService, permanent: true);
    Get.put<InternalSensorManager>(mockInternalSensorManager, permanent: true);

    // Default mocks
    when(() => mockBluetoothAdapter.scanResults).thenAnswer((_) => Stream.value([]));
    when(() => mockBluetoothAdapter.isSupported).thenAnswer((_) async => true);
    when(() => mockBluetoothAdapter.checkBluetooth(any(), any())).thenAnswer((_) async => true);
    when(
      () => mockBluetoothAdapter.startScan(timeout: any(named: 'timeout')),
    ).thenAnswer((_) async {});
    when(() => mockBluetoothAdapter.stopScan()).thenAnswer((_) async {});
    when(
      () => mockBluetoothAdapter.adapterState,
    ).thenAnswer((_) => Stream.value(BluetoothAdapterState.on));
    when(() => mockBluetoothAdapter.turnOn()).thenAnswer((_) async {});

    // Prefs defaults
    when(() => mockPrefService.get<bool>(any())).thenReturn(false);
    when(() => mockPrefService.get<int>(any())).thenReturn(0);
    when(() => mockPrefService.get<String>(any())).thenReturn("");
    when(() => mockPrefService.get<bool>(stationaryWorkoutTag)).thenReturn(false);

    // DbUtils mocks
    when(() => mockDbUtils.getAddressNameDictionary(any())).thenAnswer((_) async {});
    when(() => mockDbUtils.getAddressNameDictionary(any())).thenAnswer((_) async {});
    when(() => mockDbUtils.getDeviceUsage(any())).thenAnswer((_) async => null);
    when(() => mockDbUtils.getDeviceSportDictionary()).thenAnswer((_) async => {});

    // PackageInfo
    when(() => mockPackageInfo.appName).thenReturn("TestApp");
    when(() => mockPackageInfo.version).thenReturn("1.0.0");
    when(() => mockPackageInfo.buildNumber).thenReturn("1");

    // ThemeManager
    when(() => mockThemeManager.isDark()).thenReturn(false);
    when(() => mockThemeManager.getProtagonistColor()).thenReturn(Colors.white);

    // AddressNames
    when(() => mockAddressNames.getAddressName(any(), any())).thenReturn("Test Device");

    // Internal Sensor Manager
    when(() => mockInternalSensorManager.hasInternalHeartRate()).thenAnswer((_) async => true);
    when(() => mockInternalSensorManager.hasInternalMotionSensors()).thenAnswer((_) async => true);
  });

  tearDown(() {
    Get.reset();
  });

  test('Internal devices should be listed when scanning', () async {
    controller = FindDevicesController();
    Get.put(controller);

    // Simulate start scan
    await controller.startScan(false);

    // Check if internal devices are in scannedDevices
    // Currently this is expected to FAIL because we haven't implemented it yet
    final hasInternalHrm = controller.scannedDevices.any((d) => d.remoteId.str == "INTERNAL_HRM");
    final hasInternalMotion = controller.scannedDevices.any(
      (d) => d.remoteId.str == "INTERNAL_MOTION",
    );

    expect(hasInternalHrm, isTrue, reason: "Internal HRM should be listed");
    expect(hasInternalMotion, isTrue, reason: "Internal Motion should be listed");
  });

  test('Internal devices should NOT be listed if capability missing', () async {
    when(() => mockInternalSensorManager.hasInternalHeartRate()).thenAnswer((_) async => false);
    when(() => mockInternalSensorManager.hasInternalMotionSensors()).thenAnswer((_) async => false);

    controller = FindDevicesController();
    Get.put(controller);

    await controller.startScan(false);

    final hasInternalHrm = controller.scannedDevices.any((d) => d.remoteId.str == "INTERNAL_HRM");
    final hasInternalMotion = controller.scannedDevices.any(
      (d) => d.remoteId.str == "INTERNAL_MOTION",
    );

    expect(hasInternalHrm, isFalse, reason: "Internal HRM should NOT be listed");
    expect(hasInternalMotion, isFalse, reason: "Internal Motion should NOT be listed");
  });
}
