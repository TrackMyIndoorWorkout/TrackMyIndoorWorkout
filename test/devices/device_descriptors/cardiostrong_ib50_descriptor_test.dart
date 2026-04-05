import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/cardiostrong_ib50_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/devices/gatt/ftms.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('CardiostrongIB50Descriptor constructor defaults', () {
    final descriptor = CardiostrongIB50Descriptor();

    expect(descriptor.fourCC, cardiostrongIB50FourCC);
    expect(descriptor.vendorName, "CardioStrong");
    expect(descriptor.modelName, "IB50");
    expect(descriptor.sport, ActivityType.ride);
    expect(descriptor.dataServiceId, fitnessMachineUuid);
    expect(descriptor.dataCharacteristicId, indoorBikeUuid);
  });

  group('CardiostrongIB50Descriptor interprets FTMS Data properly', () {
    final testPair1 = TestPair(
      data: [
        84, 11, // Flags: 0x0B54
        55, 10, // Speed: 26.15 km/h
        146, 0, // Cadence: 73 rpm
        61, 128, 0, // Distance raw: 32829 -> 328290.0m CSIB scaling
        84, 0, // Power: 84 W
        8, 0, 255, 255, 255, // Energy: 8 kCal, invalid per hr/min
        0, // HR: 0 bpm
        90, 0, // Elapsed: 90 sec
      ],
      record: RecordWithSport(
        speed: 26.15,
        cadence: 73,
        distance: 328290.0,
        power: 84,
        calories: 8,
        heartRate: 0,
        elapsed: 90,
        sport: ActivityType.ride,
      ),
    );

    final testPair2 = TestPair(
      data: [
        84, 11, // Flags: 0x0B54
        24, 9, // Speed: 23.28 km/h
        130, 0, // Cadence: 65 rpm
        0, 128, 0, // Distance raw: 32768 -> 327680.0m CSIB scaling
        51, 0, // Power: 51 W
        0, 0, 255, 255, 255, // Energy: 0 kCal
        0, // HR: 0 bpm
        1, 0, // Elapsed: 1 sec
      ],
      record: RecordWithSport(
        speed: 23.28,
        cadence: 65,
        distance: 327680.0,
        power: 51,
        calories: 0,
        heartRate: 0,
        elapsed: 1,
        sport: ActivityType.ride,
      ),
    );

    void verifyPacket(TestPair testPair) {
      final descriptor = CardiostrongIB50Descriptor();

      descriptor.initFlag();
      final flagLsb = testPair.data[0];
      final flagMsb = testPair.data[1];
      final flag = flagLsb + (flagMsb << 8);

      descriptor.processFlag(flag, testPair.data.length);

      final record = descriptor.stubRecord(testPair.data)!;

      expect(record.speed, closeTo(testPair.record.speed!, 0.01));
      expect(record.cadence, testPair.record.cadence);
      expect(record.distance, testPair.record.distance);
      expect(record.power, testPair.record.power);
      expect(record.calories, testPair.record.calories);
      expect(record.heartRate, testPair.record.heartRate);
      expect(record.elapsed, testPair.record.elapsed);
      expect(record.sport, testPair.record.sport);
    }

    test("Process CardioStrong IB50 Packet 1", () {
      verifyPacket(testPair1);
    });

    test("Process CardioStrong IB50 Packet 2", () {
      verifyPacket(testPair2);
    });

    test("Reject Truncated Packet", () {
      final descriptor = CardiostrongIB50Descriptor();

      // Create a truncated packet (remove last 4 bytes)
      // Original length was 19. New length 15.
      // The flags require 19 bytes.
      final truncatedData = testPair1.data.sublist(0, testPair1.data.length - 4);

      descriptor.initFlag();
      final flagLsb = truncatedData[0];
      final flagMsb = truncatedData[1];
      final flag = flagLsb + (flagMsb << 8);
      descriptor.byteCounter = 2;

      descriptor.processFlag(flag, truncatedData.length);

      final isProcessable = descriptor.isDataProcessable(truncatedData);

      expect(isProcessable, false);
    });

    test('cardiostrong ib50 descriptor distance scaling (original)', () {
      final descriptor = CardiostrongIB50Descriptor();

      // Simulated FTMS payload
      // Flag: 0x0054 (Speed, Cadence, Total Distance, Power) = 84, 0
      final flagLsb = 84;
      final flagMsb = 0;

      // Speed (not used in this test but present in flag)
      final speedLsb = 11;
      final speedMsb = 55;

      // Cadence
      final cadLsb = 146;
      final cadMsb = 0;

      // Total distance (3 bytes)
      // From logs: distance 32829.0
      // 32829 in hex is 0x00803D -> LSB: 3D (61), Mid: 80 (128), MSB: 00 (0)
      final distLsb = 61;
      final distMid = 128;
      final distMsb = 0;

      // Power
      final pwrLsb = 84;
      final pwrMsb = 0;

      final data = [
        flagLsb,
        flagMsb,
        speedLsb,
        speedMsb,
        cadLsb,
        cadMsb,
        distLsb,
        distMid,
        distMsb,
        pwrLsb,
        pwrMsb,
      ];

      expect(descriptor.isDataProcessable(data), true);

      final record = descriptor.wrappedStubRecord(data);

      expect(record, isNotNull);

      // In standard parsing (divider 1.0), this would be 32829
      // But CSIB uses 10m units, so the descriptor divides by 0.1 (multiplies by 10)
      expect(record!.distance, 328290.0);
      expect(record.cadence, 73);
    });
  });
}
