import 'package:meta/meta.dart';

import 'metric_descriptor.dart';

class ShortMetricDescriptor extends MetricDescriptor {
  ShortMetricDescriptor({
    @required lsb,
    @required msb,
    @required divider,
  }) : super(lsb: lsb, msb: msb, divider: divider);

  double getMeasurementValue(List<int> data) {
    return (data[lsb] + 256.0 * data[msb]) / divider;
  }
}
