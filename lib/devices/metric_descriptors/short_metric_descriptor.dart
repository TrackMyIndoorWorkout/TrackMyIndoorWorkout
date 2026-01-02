import 'package:flutter/foundation.dart' show debugPrint;

import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class ShortMetricDescriptor extends MetricDescriptor {
  ShortMetricDescriptor({
    required super.lsb,
    required super.msb,
    super.divider = 1.0,
    super.optional = false,
  });

  @override
  double? getMeasurementValue(List<int> data) {
    final value = data[lsb] + maxUint8 * data[msb];
    // FTMS spec: 0xFFFF (65535) indicates "not available" for UINT16 fields
    if (value == maxUint16 - 1) {
      debugPrint(
        'FTMS Debug: ShortMetricDescriptor received "not available" value (65535) at indices [$lsb, $msb], returning null',
      );
      return null;
    }

    return value / divider;
  }
}
