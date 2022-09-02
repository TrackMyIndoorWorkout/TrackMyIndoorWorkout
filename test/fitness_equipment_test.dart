import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';
import 'package:track_my_indoor_exercise/utils/init_preferences.dart';

import 'fitness_equipment_test.mocks.dart';

@GenerateMocks([BluetoothDevice, BluetoothService, BluetoothCharacteristic])
main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });

  group('discover', () {
    BluetoothService createMockBluetoothService(
        {required String serviceUid,
        required String characteristicUid,
        List<int> characteristicData = const []}) {
      final serviceMock = MockBluetoothService();
      final mockCharacteristic = MockBluetoothCharacteristic();
      final mockServiceGuid = Guid(serviceUid);
      final mockCharacteristicGuid = Guid(characteristicUid);
      when(serviceMock.uuid).thenReturn(mockServiceGuid);
      when(serviceMock.characteristics).thenReturn([mockCharacteristic]);
      when(mockCharacteristic.uuid).thenReturn(mockCharacteristicGuid);
      when(mockCharacteristic.read()).thenAnswer((_) async => characteristicData);
      return serviceMock;
    }

    BluetoothService createMockFtmsService(
            {String serviceUid = '00001826-0000-1000-8000-00805f9b34fb',
            String characteristicUid = '00002ad2-0000-1000-8000-00805f9b34fb'}) =>
        createMockBluetoothService(serviceUid: serviceUid, characteristicUid: characteristicUid);

    BluetoothService createMockDeviceInfoService({required String manufacturerName}) =>
        createMockBluetoothService(
            serviceUid: '0000180a-0000-1000-8000-00805f9b34fb',
            characteristicUid: '00002a29-0000-1000-8000-00805f9b34fb',
            characteristicData: manufacturerName.codeUnits);

    test('ignores case in manufacturer check', () async {
      final mockDevice = MockBluetoothDevice();
      final mockFtmsService = createMockFtmsService();
      final mockDeviceInfoService = createMockDeviceInfoService(manufacturerName: 'FUJISAN YESOUL');
      when(mockDevice.discoverServices())
          .thenAnswer((_) async => [mockFtmsService, mockDeviceInfoService]);

      final deviceDescriptor = DeviceFactory.getYesoulS3();
      final equipment = FitnessEquipment(descriptor: deviceDescriptor, device: mockDevice);
      equipment.connected = true;

      expect(await equipment.discover(), true);
      expect(equipment.manufacturerName, "FUJISAN YESOUL");
    });

    test('handles manufacturer name being null in manufacturer check', () async {
      final mockDevice = MockBluetoothDevice();
      const anotherUid = '00000000-0000-1000-8000-00805f9b34fb';
      final mockFtmsService = createMockFtmsService(characteristicUid: anotherUid);
      final mockDeviceInfoService = createMockDeviceInfoService(manufacturerName: 'FUJISAN YESOUL');
      when(mockDevice.discoverServices())
          .thenAnswer((_) async => [mockFtmsService, mockDeviceInfoService]);

      final deviceDescriptor = DeviceFactory.getYesoulS3();
      final equipment = FitnessEquipment(descriptor: deviceDescriptor, device: mockDevice);
      equipment.connected = true;

      expect(await equipment.discover(), false);
    });

    test('handles descriptor being null in manufacturer check', () async {
      final mockDevice = MockBluetoothDevice();
      final mockFtmsService = createMockFtmsService();
      final mockDeviceInfoService = createMockDeviceInfoService(manufacturerName: 'FUJISAN YESOUL');
      when(mockDevice.discoverServices())
          .thenAnswer((_) async => [mockFtmsService, mockDeviceInfoService]);

      final equipment = FitnessEquipment(descriptor: null, device: mockDevice);
      equipment.connected = true;

      expect(await equipment.discover(), false);
    });
  });
}
