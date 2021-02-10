import 'package:flutter_test/flutter_test.dart';
import '../lib/devices/short_metric_descriptor.dart';

void main() {
  test('ShortMetricDescriptor calculates measurement as expected', () async {
    final desc = ShortMetricDescriptor(lsb: 0, msb: 1, divider: 2.0);
    expect(desc.getMeasurementValue([4, 1]), 130.0);
  });
}