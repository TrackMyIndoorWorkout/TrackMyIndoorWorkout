import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/rower_device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/byte_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/short_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/three_byte_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

void main() {
  group('FTMS Not Available Values Test', () {
    test('ByteMetricDescriptor always returns null for 255 (0xFF) - FTMS sentinel value', () {
      // Sentinel values should be checked regardless of optional parameter
      final desc1 = ByteMetricDescriptor(lsb: 0, divider: 2.0, optional: false);
      final desc2 = ByteMetricDescriptor(lsb: 0, divider: 2.0, optional: true);

      // Test normal value
      var data = [30]; // 30 / 2.0 = 15.0
      expect(desc1.getMeasurementValue(data), equals(15.0));
      expect(desc2.getMeasurementValue(data), equals(15.0));

      // Test FTMS "not available" sentinel value - should return null regardless of optional parameter
      data = [255]; // 0xFF
      expect(
        desc1.getMeasurementValue(data),
        isNull,
        reason: 'Sentinel value 255 should return null even when optional=false',
      );
      expect(
        desc2.getMeasurementValue(data),
        isNull,
        reason: 'Sentinel value 255 should return null when optional=true',
      );
    });

    test('ShortMetricDescriptor always returns null for 65535 (0xFFFF) - FTMS sentinel value', () {
      // Sentinel values should be checked regardless of optional parameter
      final desc1 = ShortMetricDescriptor(lsb: 0, msb: 1, optional: false);
      final desc2 = ShortMetricDescriptor(lsb: 0, msb: 1, optional: true);

      // Test normal value
      var data = [100, 0]; // 100
      expect(desc1.getMeasurementValue(data), equals(100.0));
      expect(desc2.getMeasurementValue(data), equals(100.0));

      // Test FTMS "not available" sentinel value (0xFFFF)
      data = [255, 255]; // 65535
      expect(
        desc1.getMeasurementValue(data),
        isNull,
        reason: 'Sentinel value 65535 should return null even when optional=false',
      );
      expect(
        desc2.getMeasurementValue(data),
        isNull,
        reason: 'Sentinel value 65535 should return null when optional=true',
      );
    });

    test(
      'ThreeByteMetricDescriptor always returns null for 16777215 (0xFFFFFF) - FTMS sentinel value',
      () {
        // Sentinel values should be checked regardless of optional parameter
        final desc1 = ThreeByteMetricDescriptor(lsb: 0, msb: 2, optional: false);
        final desc2 = ThreeByteMetricDescriptor(lsb: 0, msb: 2, optional: true);

        // Test normal value
        var data = [100, 0, 0]; // 100
        expect(desc1.getMeasurementValue(data), equals(100.0));
        expect(desc2.getMeasurementValue(data), equals(100.0));

        // Test FTMS "not available" sentinel value (0xFFFFFF)
        data = [255, 255, 255]; // 16777215
        expect(
          desc1.getMeasurementValue(data),
          isNull,
          reason: 'Sentinel value 16777215 should return null even when optional=false',
        );
        expect(
          desc2.getMeasurementValue(data),
          isNull,
          reason: 'Sentinel value 16777215 should return null when optional=true',
        );
      },
    );

    test('RowerDeviceDescriptor handles stroke rate 255 correctly', () {
      final descriptor = RowerDeviceDescriptor(
        sport: ActivityType.rowing,
        fourCC: '',
        vendorName: 'Test',
        modelName: 'Test Rower',
        manufacturerNamePart: 'Test',
        manufacturerFitId: '',
        model: '',
      );

      // Simulate FTMS data with stroke rate flag set
      descriptor.processFlag(1, 3); // Only stroke rate flag

      // Create data with stroke rate = 255 (not available)
      final data = [0, 255, 0, 0]; // [flags, strokeRate, strokeCountLSB, strokeCountMSB]

      final strokeRate = descriptor.getStrokeRate(data);
      expect(strokeRate, isNull, reason: 'Stroke rate should be null when FTMS sends 255');
    });

    test('RowerDeviceDescriptor handles pace 65535 correctly', () {
      final descriptor = RowerDeviceDescriptor(
        sport: ActivityType.rowing,
        fourCC: '',
        vendorName: 'Test',
        modelName: 'Test Rower',
        manufacturerNamePart: 'Test',
        manufacturerFitId: '',
        model: '',
      );

      // Simulate FTMS data with pace flag set
      descriptor.processFlag(4, 4); // Only pace flag

      // Create data with pace = 65535 (not available)
      final data = [0, 0, 255, 255]; // [flags, reserved, paceLSB, paceMSB]

      final pace = descriptor.getPace(data);
      expect(pace, isNull, reason: 'Pace should be null when FTMS sends 65535');
    });

    test('RowerDeviceDescriptor stubRecord handles null stroke rate correctly', () {
      final descriptor = RowerDeviceDescriptor(
        sport: ActivityType.rowing,
        fourCC: '',
        vendorName: 'Test',
        modelName: 'Test Rower',
        manufacturerNamePart: 'Test',
        manufacturerFitId: '',
        model: '',
      );

      // Simulate FTMS data with stroke rate and pace flags set
      descriptor.processFlag(5, 6); // Stroke rate and pace flags

      // Create data with stroke rate = 255 (not available) and normal pace
      final data = [0, 255, 0, 0, 120, 0]; // [flags, strokeRate, strokeCount, paceLSB, paceMSB]

      final record = descriptor.stubRecord(data);
      expect(
        record?.cadence,
        isNull,
        reason: 'Cadence should be null when stroke rate is not available',
      );
      expect(
        record?.preciseCadence,
        isNull,
        reason: 'Precise cadence should be null when stroke rate is not available',
      );
      expect(record?.pace, equals(120.0), reason: 'Pace should be processed normally');
    });
  });
}
