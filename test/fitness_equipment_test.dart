import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

import 'utils.dart';

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

class MockBluetoothService extends Mock implements BluetoothService {}

class MockBluetoothCharacteristic extends Mock implements BluetoothCharacteristic {}

void main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  group('discover', () {
    BluetoothService createMockBluetoothService({
      required String serviceUid,
      required String characteristicUid,
      List<int> characteristicData = const [],
    }) {
      final serviceMock = MockBluetoothService();
      final mockCharacteristic = MockBluetoothCharacteristic();
      final mockServiceGuid = Guid(serviceUid);
      final mockCharacteristicGuid = Guid(characteristicUid);
      when(() => serviceMock.serviceUuid).thenReturn(mockServiceGuid);
      when(() => serviceMock.characteristics).thenReturn([mockCharacteristic]);
      when(() => mockCharacteristic.characteristicUuid).thenReturn(mockCharacteristicGuid);
      when(() => mockCharacteristic.read()).thenAnswer((_) async => characteristicData);
      return serviceMock;
    }

    BluetoothService createMockFtmsService({
      String serviceUid = '00001826-0000-1000-8000-00805f9b34fb',
      String characteristicUid = '00002ad2-0000-1000-8000-00805f9b34fb',
    }) => createMockBluetoothService(serviceUid: serviceUid, characteristicUid: characteristicUid);

    BluetoothService createMockDeviceInfoService({required String manufacturerName}) =>
        createMockBluetoothService(
          serviceUid: '0000180a-0000-1000-8000-00805f9b34fb',
          characteristicUid: '00002a29-0000-1000-8000-00805f9b34fb',
          characteristicData: manufacturerName.codeUnits,
        );

    test('ignores case in manufacturer check', () async {
      final mockDevice = MockBluetoothDevice();
      final mockFtmsService = createMockFtmsService();
      final mockDeviceInfoService = createMockDeviceInfoService(manufacturerName: 'FUJIAN YESOUL');
      when(
        () => mockDevice.discoverServices(subscribeToServicesChanged: false),
      ).thenAnswer((_) async => [mockFtmsService, mockDeviceInfoService]);

      final deviceDescriptor = DeviceFactory.getYesoulS3();
      final equipment = FitnessEquipment(descriptor: deviceDescriptor, device: mockDevice);
      equipment.blockManufacturerNameReading = false;
      equipment.connected = true;

      expect(await equipment.discover(), true);
      expect(equipment.manufacturerName, "FUJIAN YESOUL");
    });

    test('handles manufacturer name being null in manufacturer check', () async {
      final mockDevice = MockBluetoothDevice();
      const anotherUid = '00000000-0000-1000-8000-00805f9b34fb';
      final mockFtmsService = createMockFtmsService(characteristicUid: anotherUid);
      final mockDeviceInfoService = createMockDeviceInfoService(manufacturerName: 'FUJIAN YESOUL');
      when(
        () => mockDevice.discoverServices(subscribeToServicesChanged: false),
      ).thenAnswer((_) async => [mockFtmsService, mockDeviceInfoService]);

      final deviceDescriptor = DeviceFactory.getYesoulS3();
      final equipment = FitnessEquipment(descriptor: deviceDescriptor, device: mockDevice);
      equipment.blockManufacturerNameReading = false;
      equipment.connected = true;

      expect(await equipment.discover(), false);
    });

    test('handles descriptor being null in manufacturer check', () async {
      final mockDevice = MockBluetoothDevice();
      final mockFtmsService = createMockFtmsService();
      final mockDeviceInfoService = createMockDeviceInfoService(manufacturerName: 'FUJIAN YESOUL');
      when(
        () => mockDevice.discoverServices(subscribeToServicesChanged: false),
      ).thenAnswer((_) async => [mockFtmsService, mockDeviceInfoService]);

      final equipment = FitnessEquipment(descriptor: null, device: mockDevice);
      equipment.blockManufacturerNameReading = false;
      equipment.connected = true;

      expect(await equipment.discover(), false);
    });
  });

  group('keySelector handles 1 byte flags as expected', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 255, rnd).forEach((flag) {
      test('$flag', () async {
        final descriptor = DeviceFactory.getCSCBasedBike();
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());

        final selector = equipment.keySelector([flag]);

        expect(selector, flag);
      });
    });
  });

  group('keySelector handles 2 byte flags as expected', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 255, rnd).forEach((flagLsb) {
      final flagMsb = rnd.nextInt(255);
      test('[$flagLsb, $flagMsb]', () async {
        final descriptor = DeviceFactory.getPowerMeterBasedBike();
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());

        final selector = equipment.keySelector([flagLsb, flagMsb]);

        expect(selector, flagLsb + 256 * flagMsb);
      });
    });
  });

  group('keySelector handles 3 byte flags as expected', () {
    final rnd = Random();
    getRandomInts(smallRepetition, 255, rnd).forEach((flagLsb) {
      final flagMid = rnd.nextInt(255);
      final flagMsb = rnd.nextInt(255);
      test('[$flagLsb, $flagMid, $flagMsb]', () async {
        final descriptor = DeviceFactory.getGenericFTMSCrossTrainer();
        final equipment = FitnessEquipment(descriptor: descriptor, device: MockBluetoothDevice());

        final selector = equipment.keySelector([flagLsb, flagMid, flagMsb]);

        expect(selector, flagLsb + 256 * flagMid + 65536 * flagMsb);
      });
    });
  });
}
