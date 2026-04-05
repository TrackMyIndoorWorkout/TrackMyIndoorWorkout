import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/treadmill_device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/devices/gatt/ftms.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_manufacturer.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Treadmill constructor tests', () async {
    final treadmill = DeviceFactory.getGenericFTMSTreadmill();

    expect(treadmill.sport, ActivityType.run);
    expect(treadmill.dataServiceId, fitnessMachineUuid);
    expect(treadmill.dataCharacteristicId, treadmillUuid);
  });

  group('True Treadmill interprets FTMS Data properly', () {
    final testPair = TestPair(
      data: [
        254,
        23,
        99,
        1,
        224,
        1,
        20,
        0,
        0,
        30,
        0,
        255,
        127,
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        255,
        255,
        255,
        0,
        35,
        15,
        0,
        255,
        127,
        0,
        0,
      ],
      record: RecordWithSport(
        speed: 3.55,
        distance: 20.0,
        calories: 1,
        heartRate: 0,
        elapsed: 15,
        power: 0,
        sport: ActivityType.run,
        pace: 0.0,
      ),
    );

    test("Process True Treadmill Packet", () async {
      final treadmill = DeviceFactory.getGenericFTMSTreadmill();

      treadmill.initFlag();
      // Flags are at the start of input
      final flagLsb = testPair.data[0];
      final flagMsb = testPair.data[1];
      final flag = flagLsb + (flagMsb << 8);

      treadmill.processFlag(flag, testPair.data.length);

      final record = treadmill.stubRecord(testPair.data)!;

      expect(record.speed, closeTo(testPair.record.speed!, 0.01));
      expect(record.distance, testPair.record.distance);
      expect(record.calories, testPair.record.calories);
      expect(record.elapsed, testPair.record.elapsed);
      expect(record.heartRate, testPair.record.heartRate);
    });
  });

  group('Treadmill interprets FTMS Data properly', () {
    final testPair = TestPair(
      data: [
        254,
        23,
        99,
        1,
        224,
        1,
        20,
        0,
        0,
        30,
        0,
        255,
        127,
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        255,
        255,
        255,
        0,
        35,
        15,
        0,
        255,
        127,
        0,
        0,
      ],
      record: RecordWithSport(
        speed: 3.55,
        distance: 20.0,
        calories: 1,
        heartRate: 0,
        elapsed: 15,
        power: 0,
        sport: ActivityType.run,
        pace: 0.0,
      ),
    );

    test("Process True Treadmill Packet", () async {
      final treadmill = TreadmillDeviceDescriptor(
        fourCC: genericFTMSTreadmillFourCC,
        vendorName: "Unknown",
        modelName: "Generic Treadmill",
        manufacturerNamePart: "Unknown",
        manufacturerFitId: stravaFitId,
        model: "Generic Treadmill",
      );

      treadmill.initFlag();
      // Flags are at the start of input
      final flagLsb = testPair.data[0];
      final flagMsb = testPair.data[1];
      final flag = flagLsb + (flagMsb << 8);

      treadmill.processFlag(flag, testPair.data.length);

      final record = treadmill.stubRecord(testPair.data)!;

      expect(record.speed, closeTo(testPair.record.speed!, 0.01));
      expect(record.distance, testPair.record.distance);
      expect(record.calories, testPair.record.calories);
      expect(record.elapsed, testPair.record.elapsed);
      expect(record.heartRate, testPair.record.heartRate);
    });

    test("Reject Truncated Packet", () {
      final treadmill = TreadmillDeviceDescriptor(
        fourCC: genericFTMSTreadmillFourCC,
        vendorName: "Unknown",
        modelName: "Generic Treadmill",
        manufacturerNamePart: "Unknown",
        manufacturerFitId: stravaFitId,
        model: "Generic Treadmill",
      );

      // Create a truncated packet (remove last 4 bytes)
      // Original length was 32. New length 28.
      // The flags require 32 bytes.
      final truncatedData = testPair.data.sublist(0, testPair.data.length - 4);

      // We must manually init/process flags to update byteCounter because isDataProcessable checks byteCounter
      treadmill.initFlag();
      // Flags are 2 bytes
      final flagLsb = truncatedData[0];
      final flagMsb = truncatedData[1];
      final flag = flagLsb + (flagMsb << 8);
      treadmill.byteCounter = 2;

      // processFlag updates byteCounter based on what flags are set
      // It DOES NOT throw if data is short, it just counts what is needed.
      treadmill.processFlag(flag, truncatedData.length);

      // Now check if it's processable
      final isProcessable = treadmill.isDataProcessable(truncatedData);

      // Should be false because required (byteCounter) > actual (data.length)
      expect(isProcessable, false);
    });
  });
}
