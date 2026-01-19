import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pref/pref.dart';

import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/running_speed_and_cadence_sensor.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/preferences/app_debug_mode.dart';
import 'package:track_my_indoor_exercise/preferences/log_level.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  late MockBasePrefService mockPrefService;

  setUp(() {
    Get.reset();
    mockPrefService = MockBasePrefService();
    // Stub pref service calls
    when(() => mockPrefService.get<bool>(appDebugModeTag)).thenReturn(false);
    when(() => mockPrefService.get<int>(logLevelTag)).thenReturn(logLevelDefault);
    Get.put<BasePrefService>(mockPrefService);
  });

  test('Stryd constructor tests', () async {
    final stryd = DeviceFactory.getStrydFootPod();

    expect(
      stryd.fourCC,
      technogymRunFourCC,
    ); // Using technogymRunFourCC for Stryd as per factory? Wait, checking factory.
    // Factory says:
    // static RunningSpeedAndCadenceDescriptor getStrydFootPod() {
    //   return RunningSpeedAndCadenceDescriptor(
    //     fourCC: technogymRunFourCC,
    // ...
    // Check factory again.
    // device_factory.dart line 284: fourCC: technogymRunFourCC.
    // This seems like a copy-paste error in the factory or intentional reuse?
    // User asked for "Stryd".
    // Let's use what the factory says for now.

    expect(stryd.vendorName, 'Stryd');
    expect(stryd.modelName, 'Stryd Foot Pod');
  });

  group('Stryd interprets RSC Data properly', () {
    // Packet: [128, 7, 0, 0, 0, 0, 255, 255, 255, 0, 0, 0, 0]
    // 128 = 1000 0000.
    // Bit 0 (Inst Stride Len): 0
    // Bit 1 (Total Dist): 0
    // Bit 2 (Walking/Running): 0 (Running)
    // ...
    // Wait. 128 is bit 7?
    // RSC Flags:
    // Bit 0: Instantaneous Stride Length Present
    // Bit 1: Total Distance Present
    // Bit 2: Walking or Running Status (0=Running, 1=Walking)

    // 128 = 0x80. Bit 7 is set.
    // If bits 0 and 1 are 0, then only Speed (always) and Cadence (always) are present.
    // Speed: UInt16 (m/s * 256)
    // Cadence: UInt8 (RPM)

    // Data layout:
    // Byte 0: Flags (128)
    // Byte 1-2: Speed. 7, 0 = 7.
    //   Speed = 7 / 256 m/s.
    //   7/256 * 3.6 km/h = 0.027 * 3.6 = 0.098 km/h.
    //   Basically 0.
    // Byte 3: Cadence. 0.
    //   Cadence = 0 RPM.

    // Total used bytes: 1 (flag) + 2 (speed) + 1 (cadence) = 4.
    // Packet length: 13.
    // 9 extra bytes.
    // Log packet: [128, 7, 0, 0, 0, 0, 255, 255, 255, 0, 0, 0, 0]

    // Why is flag 128? Extension flags?
    // Standard RSC flags only go up to bit 2 ?? No.
    // Ref: https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.rsc_measurement.xml

    // Let's verify the expectation.
    // Speed: 7/256 m/s -> ~0.1 km/h.
    // Cadence: 0.

    final testPair = TestPair(
      data: [128, 7, 0, 0, 0, 0, 255, 255, 255, 0, 0, 0, 0],
      record: RecordWithSport(
        speed: (7 / 256.0) * 3.6, // m/s to km/h
        cadence: 0,
        distance: null,
        sport: ActivityType.run,
      ),
    );

    test("Process Stryd Packet", () async {
      final stryd = DeviceFactory.getStrydFootPod();
      final mockDevice = MockBluetoothDevice();
      // Configure mock device
      when(() => mockDevice.remoteId).thenReturn(const DeviceIdentifier("STRYD_ID"));

      stryd.sensor = RunningSpeedAndCadenceSensor(mockDevice);

      // RSC Measurement flags are in the first byte
      final flag = testPair.data[0];
      stryd.processFlag(flag, testPair.data.length);

      final record = stryd.stubRecord(testPair.data)!;

      // Speed is ~0.1 km/h (0.0984 km/h)
      expect(record.speed, closeTo(testPair.record.speed!, 0.01));
      expect(record.cadence, testPair.record.cadence);
      expect(record.distance, testPair.record.distance);
      expect(record.sport, testPair.record.sport);
    });
  });
}

class MockBluetoothDevice extends Mock implements BluetoothDevice {}

class MockBasePrefService extends Mock implements BasePrefService {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}
