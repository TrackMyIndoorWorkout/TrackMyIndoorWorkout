import 'package:meta/meta.dart';

import 'metric_descriptor.dart';

class ByteMetricDescriptor extends MetricDescriptor {
  ByteMetricDescriptor({
    @required lsb,
    @required divider,
  }) : super(lsb: lsb, msb: 0, divider: divider);

  double getMeasurementValue(List<int> data) {
    return data[lsb] / divider;
  }
}
