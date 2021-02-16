import 'package:meta/meta.dart';

import 'metric_descriptor.dart';

class ShortMetricDescriptor extends MetricDescriptor {
  ShortMetricDescriptor({
    @required lsb,
    @required msb,
    @required divider,
    optional = false,
  }) : super(lsb: lsb, msb: msb, divider: divider, optional: optional);

  double getMeasurementValue(List<int> data) {
    final value = data[lsb] + 256 * data[msb];
    if (optional && value == 255 + 256 * 255) {
      return null;
    }
    return value / divider;
  }
}
