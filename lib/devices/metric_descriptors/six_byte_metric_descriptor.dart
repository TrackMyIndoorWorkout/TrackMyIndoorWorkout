import 'package:flutter/foundation.dart' show debugPrint;

import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class SixByteMetricDescriptor extends MetricDescriptor {
  SixByteMetricDescriptor({required super.lsb, required super.msb, super.divider = 1.0});

  @override
  double? getMeasurementValue(List<int> data) {
    final dir = lsb < msb ? 1 : -1;
    final value =
        data[lsb] +
        maxUint8 *
            (data[lsb + dir] +
                maxUint8 *
                    (data[lsb + 2 * dir] +
                        maxUint8 *
                            (data[msb - 2 * dir] +
                                maxUint8 * (data[msb - dir] + maxUint8 * data[msb]))));
    // FTMS spec: 0xFFFFFFFFFFFF (281474976710655) indicates "not available" for UINT48 fields
    if (value == maxUint48 - 1) {
      debugPrint(
        'FTMS Debug: SixByteMetricDescriptor received "not available" value, returning null',
      );
      return null;
    }

    return value / divider;
  }
}
