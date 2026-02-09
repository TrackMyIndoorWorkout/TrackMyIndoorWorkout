import 'package:flutter/foundation.dart' show debugPrint;

import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class LongMetricDescriptor extends MetricDescriptor {
  LongMetricDescriptor({required super.lsb, required super.msb, super.divider = 1.0});

  @override
  double? getMeasurementValue(List<int> data) {
    final dir = lsb < msb ? 1 : -1;
    final value =
        data[lsb] +
        maxUint8 * (data[lsb + dir] + maxUint8 * (data[msb - dir] + maxUint8 * data[msb]));
    // FTMS spec: 0xFFFFFFFF (4294967295) indicates "not available" for UINT32 fields
    if (value == maxUint32 - 1) {
      debugPrint(
        'FTMS Debug: LongMetricDescriptor received "not available" value (4294967295), returning null',
      );
      return null;
    }

    return value / divider;
  }
}
