import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:track_my_indoor_exercise/devices/company_registry.dart';
import 'package:track_my_indoor_exercise/devices/gatt/concept2.dart';
import 'package:track_my_indoor_exercise/devices/gatt/csc.dart';
import 'package:track_my_indoor_exercise/devices/gatt/ftms.dart';
import 'package:track_my_indoor_exercise/devices/gatt/hrm.dart';
import 'package:track_my_indoor_exercise/devices/gatt/kayak_first.dart';
import 'package:track_my_indoor_exercise/devices/gatt/power_meter.dart';
import 'package:track_my_indoor_exercise/devices/gatt/precor.dart';
import 'package:track_my_indoor_exercise/devices/gatt/schwinn_x70.dart';
import 'package:track_my_indoor_exercise/utils/address_names.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';
import 'package:track_my_indoor_exercise/utils/guid_ex.dart';
import 'package:track_my_indoor_exercise/utils/machine_type.dart';
import 'package:track_my_indoor_exercise/utils/scan_result_ex.dart';

import 'utils.dart';

class MockAdvertisementData extends Mock implements AdvertisementData {}

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

class MockDeviceIdentifier extends Mock implements DeviceIdentifier {}

class MockScanResult extends Mock implements ScanResult {}

class SportByteTestPair {
  final String sport;
  final int byte;

  const SportByteTestPair({required this.sport, required this.byte});
}

class ServiceDataTestPair {
  final List<int> serviceData;
  final int byte;

  const ServiceDataTestPair({required this.serviceData, required this.byte});
}

void main() {
  group('Connectability is the most important decision of worthy-ness', () {
    for (var connectable in [false, true]) {
      test("connectable: $connectable", () async {
        final scanResult = MockScanResult();
        final deviceId = MockDeviceIdentifier();
        when(() => deviceId.str).thenReturn("Brah");
        final bluetoothDevice = MockBluetoothDevice();
        when(() => bluetoothDevice.remoteId).thenReturn(deviceId);
        when(() => scanResult.device).thenReturn(bluetoothDevice);
        final advertisementData = MockAdvertisementData();
        when(() => advertisementData.connectable).thenReturn(connectable);
        when(() => scanResult.advertisementData).thenReturn(advertisementData);

        expect(scanResult.isWorthy(false), connectable);
      });
    }
  });

  group('Device Id string emptiness is the second most important decision of worthy-ness', () {
    for (var deviceIdEmpty in [false, true]) {
      test("deviceIdEmpty: $deviceIdEmpty", () async {
        final scanResult = MockScanResult();
        final deviceId = MockDeviceIdentifier();
        when(() => deviceId.str).thenReturn(deviceIdEmpty ? "" : "Brah");
        final bluetoothDevice = MockBluetoothDevice();
        when(() => bluetoothDevice.remoteId).thenReturn(deviceId);
        when(() => scanResult.device).thenReturn(bluetoothDevice);
        final advertisementData = MockAdvertisementData();
        when(() => advertisementData.connectable).thenReturn(true);
        when(() => scanResult.advertisementData).thenReturn(advertisementData);

        expect(scanResult.isWorthy(false), !deviceIdEmpty);
      });
    }
  });

  group('Filtering is the third most important decision of worthy-ness', () {
    final companyRegistry = CompanyRegistry();
    Get.put<CompanyRegistry>(companyRegistry);
    for (var filtering in [false, true]) {
      test("filtering: $filtering", () async {
        final scanResult = MockScanResult();
        when(() => scanResult.manufacturerNames()).thenAnswer((_) => []);
        final deviceId = MockDeviceIdentifier();
        when(() => deviceId.str).thenReturn("Brah");
        final bluetoothDevice = MockBluetoothDevice();
        when(() => bluetoothDevice.remoteId).thenReturn(deviceId);
        when(() => bluetoothDevice.platformName).thenReturn("Dude");
        when(() => scanResult.device).thenReturn(bluetoothDevice);
        final advertisementData = MockAdvertisementData();
        when(() => advertisementData.connectable).thenReturn(true);
        when(() => advertisementData.serviceUuids).thenReturn([]);
        when(() => advertisementData.manufacturerData).thenReturn({});
        when(() => scanResult.advertisementData).thenReturn(advertisementData);

        expect(scanResult.isWorthy(filtering), !filtering);
      });
    }
  });

  group('Specific service UUIDs grant worthy-ness', () {
    final companyRegistry = CompanyRegistry();
    Get.put<CompanyRegistry>(companyRegistry);
    for (var serviceUuid in [
      "0000",
      fitnessMachineUuid,
      precorServiceUuid,
      schwinnX70ServiceUuid,
      cyclingPowerServiceUuid,
      cyclingCadenceServiceUuid,
      c2ErgPrimaryServiceUuid,
      kayakFirstServiceUuid,
      heartRateServiceUuid,
    ]) {
      test("serviceUuid: $serviceUuid", () async {
        final scanResult = MockScanResult();
        when(() => scanResult.manufacturerNames()).thenAnswer((_) => []);
        final deviceId = MockDeviceIdentifier();
        when(() => deviceId.str).thenReturn("Brah");
        final bluetoothDevice = MockBluetoothDevice();
        when(() => bluetoothDevice.remoteId).thenReturn(deviceId);
        when(() => bluetoothDevice.platformName).thenReturn("Dude");
        when(() => scanResult.device).thenReturn(bluetoothDevice);
        final advertisementData = MockAdvertisementData();
        when(() => advertisementData.connectable).thenReturn(true);
        when(() => advertisementData.serviceUuids).thenReturn([Guid(serviceUuid)]);
        when(() => advertisementData.manufacturerData).thenReturn({});
        when(() => scanResult.advertisementData).thenReturn(advertisementData);

        expect(scanResult.isWorthy(true), serviceUuid != "0000");
      });
    }
  });

  group('Service UUID is shorthand for serviceUUIDs', () {
    final rnd = Random();
    for (var numUuids in getRandomInts(smallRepetition, 3, rnd)) {
      numUuids += 1;
      test("numUuids: $numUuids", () async {
        final scanResult = MockScanResult();
        final advertisementData = MockAdvertisementData();
        final bytes = getRandomInts(2, 254, rnd);
        bytes[0] += 1;
        bytes[1] += 1;
        final guids = List.generate(numUuids, (index) => Guid.fromBytes(bytes));
        when(() => advertisementData.serviceUuids).thenReturn(guids);
        when(() => scanResult.advertisementData).thenReturn(advertisementData);

        final uuids = scanResult.serviceUuids;

        expect(uuids.length, numUuids);
        var i = 0;
        for (final uuid in uuids) {
          expect(uuid, guids[i].uuidString());
          i++;
        }
      });
    }
  });

  test("NoneEmptyName returns platformName if not empty", () async {
    final scanResult = MockScanResult();
    when(() => scanResult.manufacturerNames()).thenAnswer((_) => []);
    final deviceId = MockDeviceIdentifier();
    const remoteId = "Brah0";
    when(() => deviceId.str).thenReturn(remoteId);
    final bluetoothDevice = MockBluetoothDevice();
    when(() => bluetoothDevice.remoteId).thenReturn(deviceId);
    when(() => bluetoothDevice.platformName).thenReturn("Dude");
    when(() => scanResult.device).thenReturn(bluetoothDevice);
    final advertisementData = MockAdvertisementData();
    when(() => advertisementData.advName).thenReturn("Brah1");
    when(() => scanResult.advertisementData).thenReturn(advertisementData);
    final addressName = AddressNames();
    addressName.addAddressName(remoteId, "Brah3");
    Get.put<AddressNames>(addressName);

    expect(scanResult.nonEmptyName, "Dude");
  });

  test("NoneEmptyName returns advName if platformName is empty", () async {
    final scanResult = MockScanResult();
    when(() => scanResult.manufacturerNames()).thenAnswer((_) => []);
    final deviceId = MockDeviceIdentifier();
    const remoteId = "Brah0";
    when(() => deviceId.str).thenReturn(remoteId);
    final bluetoothDevice = MockBluetoothDevice();
    when(() => bluetoothDevice.remoteId).thenReturn(deviceId);
    when(() => bluetoothDevice.platformName).thenReturn("");
    when(() => scanResult.device).thenReturn(bluetoothDevice);
    final advertisementData = MockAdvertisementData();
    when(() => advertisementData.advName).thenReturn("Brah1");
    when(() => scanResult.advertisementData).thenReturn(advertisementData);
    final addressName = AddressNames();
    addressName.addAddressName(remoteId, "Brah3");
    Get.put<AddressNames>(addressName);

    expect(scanResult.nonEmptyName, "Brah1");
  });

  test("NoneEmptyName returns addressName if platformName and advName is empty", () async {
    final scanResult = MockScanResult();
    when(() => scanResult.manufacturerNames()).thenAnswer((_) => []);
    final deviceId = MockDeviceIdentifier();
    const remoteId = "Brah0";
    when(() => deviceId.str).thenReturn(remoteId);
    final bluetoothDevice = MockBluetoothDevice();
    when(() => bluetoothDevice.remoteId).thenReturn(deviceId);
    when(() => bluetoothDevice.platformName).thenReturn("");
    when(() => scanResult.device).thenReturn(bluetoothDevice);
    final advertisementData = MockAdvertisementData();
    when(() => advertisementData.advName).thenReturn("");
    when(() => scanResult.advertisementData).thenReturn(advertisementData);
    final addressName = AddressNames();
    addressName.addAddressName(remoteId, "Brah3");
    Get.put<AddressNames>(addressName);

    expect(scanResult.nonEmptyName, "Brah3");
  });

  group('hasService reports properly if UUID is in serviceUUIDs', () {
    final rnd = Random();
    for (var numUuids in getRandomInts(smallRepetition, 3, rnd)) {
      numUuids += 2;
      test("numUuids: $numUuids", () async {
        final scanResult = MockScanResult();
        final advertisementData = MockAdvertisementData();
        final guidInts = <int>[];
        final guids = <Guid>[];
        var extraGuid = Guid("");
        for (var i = 0; i < numUuids; i++) {
          var unique = false;
          while (!unique) {
            final bytes = getRandomInts(2, 254, rnd);
            bytes[0] += 1;
            bytes[1] += 1;
            final guidInt = bytes[0] * 256 + bytes[1];
            if (!guidInts.contains(guidInt)) {
              unique = true;
              if (i < numUuids - 1) {
                guidInts.add(guidInt);
                guids.add(Guid.fromBytes(bytes));
              } else {
                extraGuid = Guid.fromBytes(bytes);
              }
            }
          }
        }

        when(() => advertisementData.serviceUuids).thenReturn(guids);
        when(() => scanResult.advertisementData).thenReturn(advertisementData);

        expect(scanResult.hasService(extraGuid.uuidString()), false);
        for (final guid in guids) {
          expect(scanResult.hasService(guid.uuidString()), true);
        }
      });
    }
  });

  test("getFtmsServiceDataMachineByte 0 without serviceData or deviceSport", () async {
    final scanResult = MockScanResult();
    final advertisementData = MockAdvertisementData();
    when(() => advertisementData.serviceData).thenReturn({});
    when(() => scanResult.advertisementData).thenReturn(advertisementData);

    expect(scanResult.getFtmsServiceDataMachineByte(""), 0);
  });

  group('getFtmsServiceDataMachineByte return sport based byte without serviceData', () {
    for (var sportBytePair in [
      SportByteTestPair(sport: ActivityType.ride, byte: MachineType.indoorBike.bit),
      SportByteTestPair(sport: ActivityType.run, byte: MachineType.treadmill.bit),
      SportByteTestPair(sport: ActivityType.elliptical, byte: MachineType.crossTrainer.bit),
      SportByteTestPair(sport: ActivityType.rowing, byte: MachineType.rower.bit),
      SportByteTestPair(sport: ActivityType.kayaking, byte: MachineType.rower.bit),
      SportByteTestPair(sport: ActivityType.canoeing, byte: MachineType.rower.bit),
      SportByteTestPair(sport: ActivityType.swim, byte: MachineType.rower.bit),
      SportByteTestPair(sport: ActivityType.rockClimbing, byte: MachineType.stairClimber.bit),
      SportByteTestPair(sport: ActivityType.stairStepper, byte: MachineType.stepClimber.bit),
      SportByteTestPair(sport: ActivityType.nordicSki, byte: MachineType.notFitnessMachine.bit),
    ]) {
      test("sport: ${sportBytePair.sport}, byte: ${sportBytePair.byte}", () async {
        final scanResult = MockScanResult();
        final advertisementData = MockAdvertisementData();
        when(() => advertisementData.serviceData).thenReturn({});
        when(() => scanResult.advertisementData).thenReturn(advertisementData);

        expect(scanResult.getFtmsServiceDataMachineByte(sportBytePair.sport), sportBytePair.byte);
      });
    }
  });

  group("getFtmsServiceDataMachineByte 0 when serviceData does not indicate FTMS", () {
    for (var serviceDataPair in [
      ServiceDataTestPair(serviceData: [], byte: MachineType.notFitnessMachine.bit),
      ServiceDataTestPair(serviceData: [1], byte: MachineType.notFitnessMachine.bit),
      ServiceDataTestPair(serviceData: [1, 1], byte: MachineType.notFitnessMachine.bit),
      ServiceDataTestPair(serviceData: [1, 0, 0], byte: MachineType.notFitnessMachine.bit),
      ServiceDataTestPair(serviceData: [64, 0, 0], byte: MachineType.notFitnessMachine.bit),
      ServiceDataTestPair(serviceData: [1, 32, 0], byte: MachineType.indoorBike.bit),
      ServiceDataTestPair(serviceData: [1, 1, 0], byte: MachineType.treadmill.bit),
      ServiceDataTestPair(serviceData: [1, 2, 0], byte: MachineType.crossTrainer.bit),
      ServiceDataTestPair(serviceData: [1, 4, 0], byte: MachineType.stepClimber.bit),
      ServiceDataTestPair(serviceData: [1, 8, 0], byte: MachineType.stairClimber.bit),
      ServiceDataTestPair(serviceData: [1, 16, 0], byte: MachineType.rower.bit),
      const ServiceDataTestPair(serviceData: [1, 64, 0], byte: 64),
      const ServiceDataTestPair(serviceData: [1, 128, 0], byte: 128),
      ServiceDataTestPair(serviceData: [1, 0, 32], byte: MachineType.indoorBike.bit),
      ServiceDataTestPair(serviceData: [1, 0, 1], byte: MachineType.treadmill.bit),
      ServiceDataTestPair(serviceData: [1, 0, 2], byte: MachineType.crossTrainer.bit),
      ServiceDataTestPair(serviceData: [1, 0, 4], byte: MachineType.stepClimber.bit),
      ServiceDataTestPair(serviceData: [1, 0, 8], byte: MachineType.stairClimber.bit),
      ServiceDataTestPair(serviceData: [1, 0, 16], byte: MachineType.rower.bit),
      const ServiceDataTestPair(serviceData: [1, 0, 64], byte: 64),
      const ServiceDataTestPair(serviceData: [1, 0, 128], byte: 128),
    ]) {
      test("serviceData: ${serviceDataPair.serviceData}, byte: ${serviceDataPair.byte}", () async {
        final scanResult = MockScanResult();
        final advertisementData = MockAdvertisementData();
        when(
          () => advertisementData.serviceData,
        ).thenReturn({Guid(fitnessMachineUuid): serviceDataPair.serviceData});
        when(() => scanResult.advertisementData).thenReturn(advertisementData);

        expect(scanResult.getFtmsServiceDataMachineByte(""), serviceDataPair.byte);
      });
    }
  });
}
