import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heart_rate_flutter/heart_rate_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/heart_rate_monitor_internal.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

class MockHeartRateFlutter extends Mock implements HeartRateFlutter {}

class MockPermissionHandlerWrapper extends Mock implements PermissionHandlerWrapper {}

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

// Mock Isar record related classes if needed, but the test might just check the callback
// However, the callback usually inserts into DB, which we might want to mock or just verify the data passed to it.

void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  group('DeviceInternalHeartRate', () {
    late MockHeartRateFlutter mockHeartRateFlutter;
    late MockPermissionHandlerWrapper mockPermissionHandler;
    late DeviceInternalHeartRate device;
    late StreamController<double> streamController;

    setUp(() {
      mockHeartRateFlutter = MockHeartRateFlutter();
      mockPermissionHandler = MockPermissionHandlerWrapper();
      streamController = StreamController<double>.broadcast();

      when(() => mockHeartRateFlutter.heartBeatStream).thenAnswer((_) => streamController.stream);
      when(() => mockHeartRateFlutter.init()).thenAnswer((_) async => true);

      device = DeviceInternalHeartRate(
        heartRateFlutter: mockHeartRateFlutter,
        permissionHandler: mockPermissionHandler,
      );
    });

    tearDown(() {
      streamController.close();
    });

    test('initialization sets correct remoteId', () {
      expect(device.device!.remoteId.str, "INTERNAL_HRM");
    });

    test('connect() calls init on HeartRateFlutter', () async {
      await device.connect();
      verify(() => mockHeartRateFlutter.init()).called(1);
      expect(device.connected, true);
    });

    test('connect() handles init failure gracefully', () async {
      when(() => mockHeartRateFlutter.init()).thenThrow(Exception("Init failed"));
      await device.connect();
      verify(() => mockHeartRateFlutter.init()).called(1);
      expect(device.connected, true); // Still marks as connected as per implementation
    });

    test('discover() returns true immediately', () async {
      final result = await device.discover();
      expect(result, true);
      expect(device.discovered, true);
    });

    test('attach() requests permissions and sets attached=true if granted', () async {
      when(() => mockPermissionHandler.requestSensors()).thenAnswer((_) async => true);

      await device.attach();

      verify(() => mockPermissionHandler.requestSensors()).called(1);
      expect(device.attached, true);
    });

    test('attach() sets attached=false if permission denied', () async {
      when(() => mockPermissionHandler.requestSensors()).thenAnswer((_) async => false);

      await device.attach();

      verify(() => mockPermissionHandler.requestSensors()).called(1);
      expect(device.attached, false);
    });

    test('pumpData() streams data correctly when permission granted', () async {
      when(() => mockPermissionHandler.requestSensors()).thenAnswer((_) async => true);

      RecordWithSport? receivedRecord;
      void metricProcessor(dynamic record) {
        if (record is RecordWithSport) {
          receivedRecord = record;
        }
      }

      device.pumpData(metricProcessor);

      // Wait for attach future to complete inside pumpData
      await Future.delayed(Duration.zero);

      // Emit data
      streamController.add(75.0);
      await Future.delayed(Duration.zero);

      expect(receivedRecord, isNotNull);
      expect(receivedRecord!.heartRate, 75);
      expect(receivedRecord!.sport, ActivityType.workout);
    });

    test('pumpData() does not stream data if permission denied', () async {
      when(() => mockPermissionHandler.requestSensors()).thenAnswer((_) async => false);

      RecordWithSport? receivedRecord;
      void metricProcessor(dynamic record) {
        if (record is RecordWithSport) {
          receivedRecord = record;
        }
      }

      device.pumpData(metricProcessor);

      await Future.delayed(Duration.zero);
      streamController.add(80.0);
      await Future.delayed(Duration.zero);

      expect(receivedRecord, null);
    });
  });
}
