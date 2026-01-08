import 'package:flutter/foundation.dart' show debugPrint;

import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class ThreeByteMetricDescriptor extends MetricDescriptor {
  ThreeByteMetricDescriptor({
    required super.lsb,
    required super.msb,
    super.divider = 1.0,
  });

  @override
  double? getMeasurementValue(List<int> data) {
    final dir = lsb < msb ? 1 : -1;
    final value = data[lsb] + maxUint8 * (data[lsb + dir] + maxUint8 * data[msb]);
    // FTMS spec: 0xFFFFFF (16777215) indicates "not available" for UINT24 fields
    if (value == maxUint24 - 1) {
      debugPrint(
        'FTMS Debug: ThreeByteMetricDescriptor received "not available" value (16777215), returning null',
      );
      return null;
    }

    return value / divider;
  }
}
