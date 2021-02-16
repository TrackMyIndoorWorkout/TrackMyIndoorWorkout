import 'package:meta/meta.dart';

import 'metric_descriptor.dart';

class ByteMetricDescriptor extends MetricDescriptor {
  ByteMetricDescriptor({
    @required lsb,
    @required divider,
    optional = false,
  }) : super(lsb: lsb, msb: 0, divider: divider, optional: optional);

  double getMeasurementValue(List<int> data) {
    if (optional && data[lsb] == 255) {
      return null;
    }
    return data[lsb] / divider;
  }
}
