import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_crc.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_header.dart';

class TestData {
  final int protocolVersion;
  final int profileVersion;
  final int dataSize;
  final int crc;

  TestData({this.protocolVersion, this.profileVersion, this.dataSize, this.crc});
}

void main() {
  group('FIT CRC low level test', () {
    [
      TestData(protocolVersion: 0x20, profileVersion: 0x0823, dataSize: 0x56F1, crc: 0xADF2),
      TestData(protocolVersion: 0x10, profileVersion: 0x05E9, dataSize: 0x00B1, crc: 0x1442),
      TestData(protocolVersion: 0x10, profileVersion: 0x065E, dataSize: 0x0817, crc: 0xBBE3),
      TestData(protocolVersion: 0x10, profileVersion: 0x05E9, dataSize: 0x00C5, crc: 0xC344),
      TestData(protocolVersion: 0x20, profileVersion: 0x0668, dataSize: 0x00A2, crc: 0xD0BE),
      TestData(protocolVersion: 0x10, profileVersion: 0x065E, dataSize: 0x0086, crc: 0xDBA2),
      TestData(protocolVersion: 0x10, profileVersion: 0x05E9, dataSize: 0x009F, crc: 0x80C1),
      TestData(protocolVersion: 0x20, profileVersion: 0x0812, dataSize: 0x03AB98, crc: 0x2949),
      TestData(protocolVersion: 0x20, profileVersion: 0x0812, dataSize: 0x012D33, crc: 0xC8E4),
      TestData(protocolVersion: 0x20, profileVersion: 0x0812, dataSize: 0x014DAC, crc: 0xE2CD),
      TestData(protocolVersion: 0x20, profileVersion: 0x0812, dataSize: 0x005E3E, crc: 0x4766),
      TestData(protocolVersion: 0x20, profileVersion: 0x0812, dataSize: 0x012D33, crc: 0xC8E4),
    ].forEach((testData) {
      test(
          "${testData.protocolVersion} ${testData.profileVersion} ${testData.dataSize} ${testData.crc}",
          () async {
        final header = FitHeader(
            protocolVersion: testData.protocolVersion, profileVersion: testData.profileVersion);
        header.dataSize = testData.dataSize;

        final output = header.binarySerialize();

        List<int> expected = [header.headerSize, header.profileVersion];
        var temp = FitHeader();
        temp.addInteger(header.profileVersion);
        expected.addAll(temp.output);
        temp.output = [];
        temp.addLong(header.dataSize);
        expected.addAll(temp.output);
        temp.output = [];
        expected.addAll(header.dataType);
        temp.output = [];
        final crc = crcData(expected);
        temp.addInteger(crc);
        expected.addAll(temp.output);

        expect(listEquals(output, expected), true);
      });
    });
  });
}
