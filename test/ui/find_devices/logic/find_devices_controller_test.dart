import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/cadence_monitor_internal.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/heart_rate_monitor.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/heart_rate_monitor_internal.dart';
import 'package:track_my_indoor_exercise/persistence/db_utils.dart';
import 'package:track_my_indoor_exercise/persistence/device_usage.dart';
import 'package:track_my_indoor_exercise/persistence/log_entry.dart';
import 'package:track_my_indoor_exercise/persistence/power_tune.dart';
import 'package:track_my_indoor_exercise/preferences/instant_scan.dart';
import 'package:track_my_indoor_exercise/preferences/stationary_workout.dart';
import 'package:track_my_indoor_exercise/ui/find_devices/logic/find_devices_controller.dart';
import 'package:track_my_indoor_exercise/ui/models/advertisement_cache.dart';
import 'package:track_my_indoor_exercise/ui/recording/recording_screen.dart';
import 'package:track_my_indoor_exercise/utils/address_names.dart';
import 'package:track_my_indoor_exercise/utils/bluetooth_adapter.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/theme_manager.dart';
import 'package:track_my_indoor_exercise/preferences/log_level.dart';
import 'package:tuple/tuple.dart';

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

class MockHeartRateMonitor extends Mock implements HeartRateMonitor {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockDeviceInternalHeartRate extends Mock implements DeviceInternalHeartRate {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockFitnessEquipment extends Mock implements FitnessEquipment {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockDeviceInternalMotion extends Mock implements DeviceInternalMotion {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockBluetoothDevice extends Mock implements BluetoothDevice {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockPackageInfo extends Mock implements PackageInfo {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockDeviceDescriptor extends Mock implements DeviceDescriptor {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class FakeRoute extends Fake implements Route {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockBluetoothAdapter extends Mock implements BluetoothAdapter {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

class MockIsar extends Mock implements Isar {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => super.toString();
}

void main() {
  late FindDevicesController controller;
  late MockAdvertisementCache mockAdvertisementCache;
  late MockThemeManager mockThemeManager;
  late MockAddressNames mockAddressNames;
  late MockDbUtils mockDbUtils;
  late MockBasePrefService mockPrefService;
  late MockNavigatorObserver mockObserver;
  late MockPackageInfo mockPackageInfo;
  late MockBluetoothAdapter mockBluetoothAdapter;
  late MockIsar mockIsar;

  setUpAll(() {
    registerFallbackValue(BluetoothConnectionState.disconnected);
    registerFallbackValue(FakeRoute());
    registerFallbackValue(true);
    registerFallbackValue(MockBluetoothDevice());
    registerFallbackValue(MockDeviceDescriptor());
    registerFallbackValue("fallback_string");
    registerFallbackValue(MockAddressNames());
    registerFallbackValue(
      LogEntry(timeStamp: DateTime.now(), level: "", tag: "", subTag: "", message: ""),
    );
    registerFallbackValue(const TextStyle());
    registerFallbackValue(Colors.white);
    registerFallbackValue(Icons.add);
    registerFallbackValue(1.0);
    registerFallbackValue(GlobalKey());
    registerFallbackValue(() {});
    registerFallbackValue(Duration.zero);
    registerFallbackValue(License.values.first);
    registerFallbackValue(PowerTune(mac: "fallback_mac", powerFactor: 1.0, time: DateTime.now()));
    registerFallbackValue(
      DeviceUsage(
        sport: ActivityType.ride,
        mac: "",
        name: "",
        manufacturer: "",
        time: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockAdvertisementCache = MockAdvertisementCache();
    mockThemeManager = MockThemeManager();
    mockAddressNames = MockAddressNames();
    mockDbUtils = MockDbUtils();
    mockPrefService = MockBasePrefService();
    mockObserver = MockNavigatorObserver();
    mockPackageInfo = MockPackageInfo();
    mockBluetoothAdapter = MockBluetoothAdapter();
    mockIsar = MockIsar();

    Get.put<AdvertisementCache>(mockAdvertisementCache, permanent: true);
    Get.put<ThemeManager>(mockThemeManager, permanent: true);
    Get.put<AddressNames>(mockAddressNames, permanent: true);
    Get.put<DbUtils>(mockDbUtils, permanent: true);
    Get.put<BluetoothAdapter>(mockBluetoothAdapter, permanent: true);
    Get.put<BasePrefService>(mockPrefService, permanent: true);
    Get.put<PackageInfo>(mockPackageInfo, permanent: true);
    Get.put<Isar>(mockIsar, permanent: true);

    // Mock PackageInfo
    when(() => mockPackageInfo.appName).thenReturn("TestApp");
    when(() => mockPackageInfo.version).thenReturn("1.0.0");
    when(() => mockPackageInfo.buildNumber).thenReturn("1");

    // Mock ThemeManager
    when(() => mockThemeManager.isDark()).thenReturn(false);
    when(() => mockThemeManager.getBlueColorInverse()).thenReturn(Colors.blue);
    when(() => mockThemeManager.getBlueIcon(any(), any())).thenReturn(const Icon(Icons.add));
    when(() => mockThemeManager.getIconFab(any(), any(), any())).thenReturn(const Icon(Icons.abc));
    when(() => mockThemeManager.getBlueColor()).thenReturn(Colors.blue);
    when(() => mockThemeManager.getGreenColor()).thenReturn(Colors.green);
    when(() => mockThemeManager.getRedColor()).thenReturn(Colors.red);
    when(() => mockThemeManager.getGreyColor()).thenReturn(Colors.grey);
    when(() => mockThemeManager.getAntagonistColor()).thenReturn(Colors.black);
    when(() => mockThemeManager.getProtagonistColor()).thenReturn(Colors.white);
    when(() => mockThemeManager.getAverageChartColor()).thenReturn(Colors.orange);
    when(() => mockThemeManager.getMaximumChartColor()).thenReturn(Colors.red);
    when(() => mockThemeManager.getHeaderColor()).thenReturn(Colors.blue);
    when(
      () => mockThemeManager.boldStyle(any(), fontSizeFactor: any(named: 'fontSizeFactor')),
    ).thenAnswer((invocation) => invocation.positionalArguments[0] as TextStyle);
    when(() => mockThemeManager.getIconFab(any(), any(), any())).thenReturn(const SizedBox());
    when(
      () => mockThemeManager.getIconFabWKey(any(), any(), any(), any()),
    ).thenReturn(const SizedBox());
    when(() => mockThemeManager.getBlueFab(any(), any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getGreenFab(any(), any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getBlueFabWKey(any(), any(), any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getGreenFabWKey(any(), any(), any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getGreyFab(any(), any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getRankIcon(any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getHelpFab(any(), any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getAboutFab()).thenReturn(const SizedBox());
    when(() => mockThemeManager.getTutorialFab(any())).thenReturn(const SizedBox());
    when(() => mockThemeManager.getBlueTextStyle(any())).thenReturn(const TextStyle());

    // Mock Prefs defaults
    when(() => mockPrefService.get<bool>(any())).thenReturn(false);
    when(() => mockPrefService.get<int>(any())).thenReturn(0);
    // Explicitly set log level to none (0) to avoid Logging using Isar
    when(() => mockPrefService.get<int>(logLevelTag)).thenReturn(0);
    when(() => mockPrefService.get<String>(any())).thenReturn("FFFFFFFF");
    when(() => mockPrefService.set<bool>(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefService.set<int>(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefService.set<String>(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefService.get<bool>(instantScanTag)).thenReturn(false);

    // Mock DbUtils methods
    when(() => mockDbUtils.getAddressNameDictionary(any())).thenAnswer((_) async {});
    when(() => mockDbUtils.getFactors(any())).thenAnswer((_) async => const Tuple3(1.0, 1.0, 1.0));
    when(() => mockDbUtils.calorieFactorValue(any(), any())).thenAnswer((_) async => 1.0);
    when(() => mockDbUtils.unfinishedActivities()).thenAnswer((_) async => []);
    when(() => mockDbUtils.unfinishedDeviceActivities(any())).thenAnswer((_) async => []);
    when(() => mockDbUtils.getDeviceSportDictionary()).thenAnswer((_) async => {});
    when(() => mockDbUtils.getDeviceUsage(any())).thenAnswer((_) async => null);
    when(() => mockDbUtils.saveDeviceUsage(any())).thenAnswer((_) async {});

    // Mock Bluetooth Adapter
    when(() => mockBluetoothAdapter.scanResults).thenAnswer((_) => Stream.value([]));
    when(() => mockBluetoothAdapter.stopScan()).thenAnswer((_) async {});
    when(
      () => mockBluetoothAdapter.startScan(timeout: any(named: 'timeout')),
    ).thenAnswer((_) async {});
    when(() => mockBluetoothAdapter.checkBluetooth(any(), any())).thenAnswer((_) async => true);
    when(
      () => mockBluetoothAdapter.adapterState,
    ).thenAnswer((_) => Stream.value(BluetoothAdapterState.on));
    when(() => mockBluetoothAdapter.adapterStateNow).thenReturn(BluetoothAdapterState.on);
    when(() => mockBluetoothAdapter.isSupported).thenAnswer((_) async => true);
    when(() => mockBluetoothAdapter.turnOn()).thenAnswer((_) async {});

    controller = FindDevicesController();
    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('onConnectedHrmTap starts workout if hrmWorkout is true', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: SizedBox()),
        navigatorObservers: [mockObserver],
      ),
    );

    final mockHrm = MockDeviceInternalHeartRate();
    final mockDevice = MockBluetoothDevice();

    when(() => mockHrm.device).thenReturn(mockDevice);
    when(
      () => mockDevice.connectionState,
    ).thenAnswer((_) => Stream.value(BluetoothConnectionState.connected));
    when(() => mockDevice.remoteId).thenReturn(const DeviceIdentifier("INTERNAL_HRM"));
    when(() => mockDevice.platformName).thenReturn("Internal HRM");
    when(() => mockHrm.sport).thenReturn(ActivityType.ride);
    when(
      () => mockDevice.connect(
        timeout: any(named: 'timeout'),
        mtu: any(named: 'mtu'),
        autoConnect: any(named: 'autoConnect'),
        license: any(named: 'license'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockDevice.disconnect()).thenAnswer((_) async {});
    when(
      () => mockDevice.discoverServices(
        subscribeToServicesChanged: any(named: 'subscribeToServicesChanged'),
      ),
    ).thenAnswer((_) async => []);

    controller.heartRateMonitor = mockHrm;
    controller.heartRateMonitorWorkout = true;

    controller.onConnectedHrmTap();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(RecordingScreen), findsOneWidget);
  });

  testWidgets('onConnectedHrmTap starts workout implicitly if fitnessEquipment is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: SizedBox()),
        navigatorObservers: [mockObserver],
      ),
    );

    final mockHrm = MockDeviceInternalHeartRate();
    final mockDevice = MockBluetoothDevice();

    when(() => mockHrm.device).thenReturn(mockDevice);
    when(
      () => mockDevice.connectionState,
    ).thenAnswer((_) => Stream.value(BluetoothConnectionState.connected));
    when(() => mockDevice.remoteId).thenReturn(const DeviceIdentifier("INTERNAL_HRM"));
    when(() => mockDevice.platformName).thenReturn("Internal HRM");
    when(() => mockHrm.sport).thenReturn(ActivityType.run);
    when(
      () => mockDevice.connect(
        timeout: any(named: 'timeout'),
        mtu: any(named: 'mtu'),
        autoConnect: any(named: 'autoConnect'),
        license: any(named: 'license'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockDevice.disconnect()).thenAnswer((_) async {});
    when(
      () => mockDevice.discoverServices(
        subscribeToServicesChanged: any(named: 'subscribeToServicesChanged'),
      ),
    ).thenAnswer((_) async => []);

    controller.heartRateMonitor = mockHrm;
    controller.heartRateMonitorWorkout = false;
    controller.fitnessEquipment = null;

    controller.onConnectedHrmTap();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(RecordingScreen), findsOneWidget);
  });

  testWidgets('onConnectedMotionTap starts workout if stationaryWorkout is true', (tester) async {
    Get.delete<FindDevicesController>();
    when(() => mockPrefService.get<bool>(stationaryWorkoutTag)).thenReturn(true);
    controller = FindDevicesController();
    Get.put(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: SizedBox()),
        navigatorObservers: [mockObserver],
      ),
    );

    final mockMotion = MockDeviceInternalMotion();
    final mockDevice = MockBluetoothDevice();

    when(() => mockMotion.device).thenReturn(mockDevice);
    when(() => mockDevice.remoteId).thenReturn(const DeviceIdentifier("INTERNAL_MOTION"));
    when(() => mockDevice.platformName).thenReturn("Internal Motion");
    when(
      () => mockDevice.connect(
        timeout: any(named: 'timeout'),
        mtu: any(named: 'mtu'),
        autoConnect: any(named: 'autoConnect'),
        license: any(named: 'license'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockDevice.disconnect()).thenAnswer((_) async {});
    when(
      () => mockDevice.discoverServices(
        subscribeToServicesChanged: any(named: 'subscribeToServicesChanged'),
      ),
    ).thenAnswer((_) async => []);
    when(() => mockMotion.targetSport).thenReturn(ActivityType.ride);
    when(() => mockMotion.connect()).thenAnswer((_) async => true);
    when(() => mockMotion.discover()).thenAnswer((_) async => true);
    when(() => mockMotion.attach()).thenAnswer((_) async {});
    when(() => mockMotion.disconnect()).thenAnswer((_) async {});

    Get.put<DeviceInternalMotion>(mockMotion);

    controller.onConnectedMotionTap();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(RecordingScreen), findsOneWidget);
    final screen = tester.widget<RecordingScreen>(find.byType(RecordingScreen));
    expect(screen.sport, ActivityType.ride);
    expect(screen.descriptor.deviceCategory, DeviceCategory.primarySensor);
  });

  testWidgets('onConnectedMotionTap does NOT start workout if stationaryWorkout is false', (
    tester,
  ) async {
    Get.delete<FindDevicesController>();
    when(() => mockPrefService.get<bool>(stationaryWorkoutTag)).thenReturn(false);
    controller = FindDevicesController();
    Get.put(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        home: const Scaffold(body: SizedBox()),
        navigatorObservers: [mockObserver],
      ),
    );

    final mockMotion = MockDeviceInternalMotion();
    final mockDevice = MockBluetoothDevice();
    when(() => mockMotion.device).thenReturn(mockDevice);
    when(() => mockDevice.remoteId).thenReturn(const DeviceIdentifier("INTERNAL_MOTION"));
    when(
      () => mockDevice.connect(
        timeout: any(named: 'timeout'),
        mtu: any(named: 'mtu'),
        autoConnect: any(named: 'autoConnect'),
        license: any(named: 'license'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockDevice.disconnect()).thenAnswer((_) async {});
    when(() => mockDevice.discoverServices()).thenAnswer((_) async => []);
    when(() => mockMotion.targetSport).thenReturn(ActivityType.ride);
    when(() => mockMotion.connect()).thenAnswer((_) async => true);
    when(() => mockMotion.discover()).thenAnswer((_) async => true);
    when(() => mockMotion.attach()).thenAnswer((_) async {});
    when(() => mockMotion.disconnect()).thenAnswer((_) async {});

    Get.put<DeviceInternalMotion>(mockMotion);

    await controller.onConnectedMotionTap();
    await tester.pump();
    expect(find.textContaining("Internal Motion Sensor Connected"), findsOneWidget);
    expect(find.byType(RecordingScreen), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
  });
}
