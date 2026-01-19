import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/cross_trainer_device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/devices/gatt/ftms.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class FlagBytes {
  final int lsb;
  final int mid;
  final int msb;
  final String description;

  const FlagBytes({
    required this.lsb,
    required this.mid,
    required this.msb,
    required this.description,
  });
}

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Cross Trainer constructor tests', () async {
    final crossTrainer = CrossTrainerDeviceDescriptor(
      fourCC: genericFTMSCrossTrainerFourCC,
      vendorName: 'Test Vendor',
      modelName: 'Test Model',
      manufacturerNamePart: 'Test',
      manufacturerFitId: 0,
      model: '0',
    );

    expect(crossTrainer.sport, ActivityType.elliptical);
    expect(crossTrainer.fourCC, genericFTMSCrossTrainerFourCC);
    expect(crossTrainer.dataServiceId, fitnessMachineUuid);
    expect(crossTrainer.dataCharacteristicId, crossTrainerUuid);
  });

  group('Cross Trainer interprets FTMS Data flags properly', () {
    // Flags based on the extracted packets: [222, 47, 0]
    // 222 = 1101 1110
    // 47  = 0010 1111
    // 0   = 0000 0000
    test('Standard Packet Flags', () async {
      final crossTrainer = CrossTrainerDeviceDescriptor(
        fourCC: genericFTMSCrossTrainerFourCC,
        vendorName: 'Test',
        modelName: 'Test',
        manufacturerNamePart: 'Test',
        manufacturerFitId: 0,
        model: '0',
      );

      const lsb = 222;
      const mid = 47;
      const msb = 0;
      final flag = lsb + (mid << 8) + (msb << 16);

      crossTrainer.initFlag();
      crossTrainer.stopWorkout();
      crossTrainer.processFlag(flag, 34); // Data length 34 from log

      // Based on processFlag logic in CrossTrainerDeviceDescriptor:
      // flag = processSpeedFlag(flag); -> Bit 0 (0) -> Speed present (but logic might involve negation or specific bit check)
      // Actually CrossTrainerDeviceDescriptor:
      // // negated first bit!
      // flag = processSpeedFlag(flag);

      // Let's verify expectations based on what metrics were present in the log
      // Log had: distance, elapsed, calories, power, speed, cadence, heartRate, resistance, strokeCount

      expect(crossTrainer.speedMetric, isNotNull, reason: 'Speed Metric');
      expect(crossTrainer.distanceMetric, isNotNull, reason: 'Distance Metric');
      expect(crossTrainer.cadenceMetric, isNotNull, reason: 'Cadence (Step Rate) Metric');
      expect(crossTrainer.strokeCountMetric, isNotNull, reason: 'Stroke Count Metric');
      expect(crossTrainer.resistanceMetric, isNotNull, reason: 'Resistance Metric');
      expect(crossTrainer.powerMetric, isNotNull, reason: 'Power Metric');
      expect(crossTrainer.caloriesMetric, isNotNull, reason: 'Calories Metric');
      expect(crossTrainer.heartRateByteIndex, isNotNull, reason: 'Heart Rate');
      expect(crossTrainer.timeMetric, isNotNull, reason: 'Elapsed Time');
    });
  });

  group('Cross Trainer interprets FTMS Cross Trainer Data properly', () {
    for (final testPair in [
      // Packet 1
      // [222, 47, 0, 166, 4, 26, 0, 19, 2, 0, 128, 0, 128, 0, 172, 6, 0, 0, 0, 0, 10, 0, 22, 0, 0, 0, 12, 0, 255, 255, 255, 89, 172, 0]
      TestPair(
        data: [
          222,
          47,
          0,
          166,
          4,
          26,
          0,
          19,
          2,
          0,
          128,
          0,
          128,
          0,
          172,
          6,
          0,
          0,
          0,
          0,
          10,
          0,
          22,
          0,
          0,
          0,
          12,
          0,
          255,
          255,
          255,
          89,
          172,
          0,
        ],
        record: RecordWithSport(
          distance: 531.0, // Packet: 19 + 2*256 = 19 + 512 = 531. Correct.
          elapsed: 172,
          // The parsing uses elapsed time.
          // 47 -> 0010 1111.
          // flags...
          // processElapsedTimeFlag is called near the end.
          // Let's trust the data values in the packet:
          // 172 + 0*256 = 172.

          // Packet: 128, 0 -> 128 (0x80).
          // 128 / 2 = 64? No.
          // Log says 132...
          // Wait.
          // Packet: ... 26, 0, 19, 2, 0, 128, 0, 128, 0 ...
          // Let's map bytes:
          // Flags: 3 bytes [222, 47, 0]
          // Speed: 2 bytes [166, 4] -> 1190 -> 11.9
          // Distance: 3 bytes [26, 0, 19] ?? No. Distance usually 3 bytes.
          // 26, 0, 0? No.
          // 26, 0, 19? 19*65536? No.
          // Log distance 528.
          // 528 = 0x210.
          // Packet has 26, 0...
          // Wait. 26 reference.
          // Maybe `skipFlag(flag); // Average Speed`?
          // processFlag:
          // flag = processSpeedFlag(flag); (2 bytes)
          // flag = skipFlag(flag); // Average Speed (2 bytes?) usually.
          // flag = processTotalDistanceFlag(flag); (3 bytes)

          // Packet:
          // [0-2] Flags: 222, 47, 0
          // [3-4] Speed: 166, 4 (11.9)
          // [5-6] Avg Speed? 26, 0 -> 26? (0.26?)
          // [7-9] Total Distance: 19, 2, 0 -> 19 + 512 = 531?
          // Packet says 528.
          // 16, 2, 0 -> 16 + 512 = 528.
          // Extracted packet 1 has: 26, 0, 19, 2, 0...
          // Wait.
          // 166, 4 (Speed)
          // 26, 0 (Avg Speed?)
          // 19, 2, 0 (Distance?) -> 19 + 2*256 = 19 + 512 = 531.
          // Log says 528 for the *first* packet I looked at?
          // Wait. Log line 2 id ... distance 528.0
          // Log line 7 (Packet for line 7): [..., 19, 2, 0, ...]
          // Line 11 (result): distance 531.0
          // Ah! Line 2 result `528.0` matches PREVIOUS packet.
          // Line 7 is the NEW packet arrival.
          // Line 11 is the result of that packet: `distance 531.0`.
          // 19 + 512 = 531. Correct.

          // Cadence?
          // processStepMetricsFlag(flag).
          // Instant Step Rate (2 bytes) + Avg Step Rate (2 bytes)? Or just Instant?
          // FTMS Step Rate is usually 2 bytes?
          // Packet after distance: 128, 0, 128, 0...
          // 128 = 0x80.
          // Log says Cadence 128 (Line 11).
          // So byte [10-11] is 128, 0.

          // Stroke Count?
          // processStrideCountFlag(flag, divider: 10.0).
          // 172, 6 -> 172 + 6*256 = 172 + 1536 = 1708. /10 = 170.8.
          // Log says 170.8 (Line 11). Correct.

          // Resistance?
          // processResistanceFlag(flag, divider: 10.0).
          // skipped Elevation (4), Inclination (4).
          // Packet: ... 172, 6 (Stroke), 0,0,0,0 (Elev), 10,0,22,0 (Inc?)?
          // 10, 0, 22, 0
          // 10 = 0xA.
          // Resistance: 10? Log says Resistance 1.
          // 10 / 10 = 1. Correct.

          // Power?
          // processPowerFlag(flag) (2 bytes).
          // Packet: ... 22, 0 ...
          // 22. Log says 22. Correct.

          // Avg Power? skipped.
          // 0, 0.

          // Energy?
          // processExpandedEnergyFlag(flag).
          // Total (2), /h (2), /m (1).
          // Packet: 12, 0, 255, 255, 255.
          // Total: 12. Log says 12. Correct.
          // /h: 65535 (ignored/max).
          // /m: 255 (ignored).

          // Heart Rate?
          // processHeartRateFlag(flag) (1 byte).
          // Packet: 89. Log says 89. Correct.

          // Elapsed Time?
          // processElapsedTimeFlag(flag) (2 bytes?).
          // Packet: 172, 0. -> 172.
          // Log Line 11 matches this packet perfectly.

          // So for the test case, I should use the values derived from the packet I put in `data`.
          calories: 12,
          power: 22,
          speed: 11.9, // 166 + 4*256 = 1190 -> 11.9. Correct.
          cadence: 128, // Instant Cadence?
          heartRate: 89,
          sport: ActivityType.elliptical,
          strokeCount: 170.8,
          resistance: 1,
        ),
      ),

      // Packet 2 (Line 365)
      // [222, 47, 0, 246, 4, 26, 0, 125, 2, 0, 136, 0, 136, 0, 1, 8, 0, 0, 0, 0, 70, 0, 49, 0, 0, 0, 15, 0, 255, 255, 255, 86, 203, 0]
      TestPair(
        data: [
          222,
          47,
          0,
          246,
          4,
          26,
          0,
          125,
          2,
          0,
          136,
          0,
          136,
          0,
          1,
          8,
          0,
          0,
          0,
          0,
          70,
          0,
          49,
          0,
          0,
          0,
          15,
          0,
          255,
          255,
          255,
          86,
          203,
          0,
        ],
        record: RecordWithSport(
          distance: 637.0, // 125 + 2*256 = 125 + 512 = 637.
          elapsed: 203, // 203, 0
          calories: 15, // 15, 0
          power: 49, // 49, 0
          speed: 12.7, // 246 + 4*256 = 246 + 1024 = 1270 -> 12.7
          cadence: 136, // 136, 0
          heartRate: 86, // 86
          sport: ActivityType.elliptical,
          strokeCount: 204.9, // 1 + 8*256 = 2049 -> 204.9
          resistance: 7, // 70 / 10 = 7.
        ),
      ),
    ]) {
      test("Process Packet with Distance ${testPair.record.distance}", () async {
        final crossTrainer = CrossTrainerDeviceDescriptor(
          fourCC: genericFTMSCrossTrainerFourCC,
          vendorName: 'Test Vendor',
          modelName: 'Test Model',
          manufacturerNamePart: 'Test',
          manufacturerFitId: 0,
          model: '0',
        );

        crossTrainer.initFlag();
        // Flags are at the start of input
        final flagLsb = testPair.data[0];
        final flagMid = testPair.data[1];
        final flagMsb = testPair.data[2];
        final flag = flagLsb + (flagMid << 8) + (flagMsb << 16);

        crossTrainer.processFlag(flag, testPair.data.length);

        final record = crossTrainer.stubRecord(testPair.data)!;

        expect(record.distance, testPair.record.distance);
        expect(record.elapsed, testPair.record.elapsed);
        expect(record.calories, testPair.record.calories);
        expect(record.power, testPair.record.power);
        expect(record.speed, testPair.record.speed);
        expect(record.cadence, testPair.record.cadence);
        expect(record.heartRate, testPair.record.heartRate);
        expect(record.sport, testPair.record.sport);
        expect(record.strokeCount, testPair.record.strokeCount);
        expect(record.resistance, testPair.record.resistance);
      });
    }
  });
}
