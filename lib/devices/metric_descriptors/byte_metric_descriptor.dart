import 'package:flutter/foundation.dart' show debugPrint;

import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class ByteMetricDescriptor extends MetricDescriptor {
  ByteMetricDescriptor({required super.lsb, super.divider = 1.0}) : super(msb: 0);

  @override
  double? getMeasurementValue(List<int> data) {
    final rawValue = data[lsb];
    // FTMS spec: 0xFF (255) indicates "not available" for UINT8 fields
    if (rawValue == maxUint8 - 1) {
      debugPrint(
        'FTMS Debug: ByteMetricDescriptor received "not available" value (255) at index $lsb, returning null',
      );
      return null;
    }

    return rawValue / divider;
  }
}
