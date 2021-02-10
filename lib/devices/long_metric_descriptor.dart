import 'package:flutter/foundation.dart';
import 'metric_descriptor.dart';

class LongMetricDescriptor extends MetricDescriptor {
  LongMetricDescriptor({@required lsb, @required msb, @required divider})
      : super(lsb: lsb, msb: msb, divider: divider);

  double getMeasurementValue(List<int> data) {
    final dir = lsb < msb ? 1 : -1;
    return (data[lsb] +
            256.0 * data[lsb + dir] +
            65536.0 * data[msb - dir] +
            16777216.0 * data[msb]) /
        divider;
  }
}
