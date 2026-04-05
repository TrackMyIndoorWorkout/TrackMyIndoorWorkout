import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pref/pref.dart';
import 'package:track_my_indoor_exercise/devices/gadgets/cycling_speed_and_cadence_sensor.dart';
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
    when(() => mockPrefService.get<bool>(appDebugModeTag)).thenReturn(false);
    when(() => mockPrefService.get<int>(logLevelTag)).thenReturn(logLevelDefault);
    Get.put<BasePrefService>(mockPrefService);
  });

  group('CSC Sensor interprets data properly', () {
    // Flag: 3 (Wheel + Crank)
    // 3 = 0000 0011 -> Bit 0 (Wheel) = 1, Bit 1 (Crank) = 1.
    // Expected: Flag(1) + Wheel(4+2) + Crank(2+2) = 11 bytes.
    // We will provide 15 bytes.
    final testPair = TestPair(
      data: [
        3, // Flag: Wheel Present, Crank Present
        100, 0, 0, 0, // Wheel Rev (100)
        200, 0, // Wheel Time (200)
        50, 0, // Crank Rev (50)
        100, 0, // Crank Time (100)
        0, 0, 0, 0, // Extra bytes
      ],
      record: RecordWithSport(sport: ActivityType.ride, strokeCount: 50.0),
    );

    test("Process CSC Packet with extra bytes", () async {
      final mockDevice = MockBluetoothDevice();
      when(() => mockDevice.remoteId).thenReturn(const DeviceIdentifier("CSC_ID"));
      final sensor = CyclingSpeedAndCadenceSensor(mockDevice);

      final canProcess = sensor.canMeasurementProcessed(testPair.data);
      expect(canProcess, true);

      final record = sensor.processMeasurement(testPair.data);
      expect(record.strokeCount, testPair.record.strokeCount);
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
