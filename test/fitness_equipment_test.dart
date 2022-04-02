import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:track_my_indoor_exercise/devices/device_map.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/fitness_equipment.dart';

import 'fitness_equipment_test.mocks.dart';
import 'utils.dart';

@GenerateMocks([BluetoothDevice, BluetoothService, BluetoothCharacteristic])
main() {
  setUpAll(() async {
    await initPrefServiceForTest();
  });
  group('discover', () {
    BluetoothService _mockBluetoothService(
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

    BluetoothService _mockFtmsService() => _mockBluetoothService(
        serviceUid: '00001826-0000-1000-8000-00805f9b34fb',
        characteristicUid: '00002ad2-0000-1000-8000-00805f9b34fb');

    BluetoothService _mockDeviceInfoService({required String manufacturerName}) =>
        _mockBluetoothService(
            serviceUid: '0000180a-0000-1000-8000-00805f9b34fb',
            characteristicUid: '00002a29-0000-1000-8000-00805f9b34fb',
            characteristicData: manufacturerName.codeUnits);

    test('ignores case in manufacturer check', () async {
      final mockDevice = MockBluetoothDevice();
      final mockFtmsService = _mockFtmsService();
      final mockDeviceInfoService = _mockDeviceInfoService(manufacturerName: 'FUJISAN YESOUL');
      when(mockDevice.discoverServices())
          .thenAnswer((_) async => [mockFtmsService, mockDeviceInfoService]);

      final deviceDescriptor = deviceMap[yesoulS3FourCC];
      final equipment = FitnessEquipment(descriptor: deviceDescriptor, device: mockDevice);
      equipment.connected = true;

      expect(await equipment.discover(), true);
      expect(equipment.manufacturerName, "FUJISAN YESOUL");
    });
  });
}
