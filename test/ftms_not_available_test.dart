import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/byte_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/short_metric_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/metric_descriptors/three_byte_metric_descriptor.dart';

void main() {
  group('FTMS Not Available Values Test', () {
    test('Original bug: 255 should NOT be interpreted as 127.5 for stroke rate', () {
      // This test verifies the original bug is fixed:
      // Before fix: 255 / 2.0 = 127.5 (incorrect)
      // After fix: 255 should return null (correct)
      final desc = ByteMetricDescriptor(lsb: 0, divider: 2.0);
      final data = [255];

      final result = desc.getMeasurementValue(data);
      expect(result, isNull, reason: 'FTMS value 255 should be null, not 127.5');
    });

    test('ByteMetricDescriptor returns null for 255 (0xFF) - FTMS sentinel value', () {
      final desc = ByteMetricDescriptor(lsb: 0, divider: 2.0);

      // Test normal value
      var data = [30]; // 30 / 2.0 = 15.0
      expect(desc.getMeasurementValue(data), equals(15.0));

      // Test FTMS "not available" sentinel value
      data = [255]; // 0xFF
      expect(desc.getMeasurementValue(data), isNull);
    });

    test('ShortMetricDescriptor returns null for 65535 (0xFFFF) - FTMS sentinel value', () {
      final desc = ShortMetricDescriptor(lsb: 0, msb: 1);

      // Test normal value
      var data = [100, 0]; // 100
      expect(desc.getMeasurementValue(data), equals(100.0));

      // Test FTMS "not available" sentinel value
      data = [255, 255]; // 65535 (maxUint16 - 1)
      expect(desc.getMeasurementValue(data), isNull);
    });

    test('ThreeByteMetricDescriptor returns null for 16777215 (0xFFFFFF) - FTMS sentinel value', () {
      final desc = ThreeByteMetricDescriptor(lsb: 0, msb: 2);

      // Test normal value
      var data = [0, 100, 0]; // 25600
      expect(desc.getMeasurementValue(data), equals(25600.0));

      // Test FTMS "not available" sentinel value
      data = [255, 255, 255]; // 16777215 (maxUint24 - 1)
      expect(desc.getMeasurementValue(data), isNull);
    });
  });
}
