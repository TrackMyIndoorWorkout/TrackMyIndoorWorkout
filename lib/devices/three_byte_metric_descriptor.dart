import 'package:meta/meta.dart';

import 'metric_descriptor.dart';

class ThreeByteMetricDescriptor extends MetricDescriptor {
  ThreeByteMetricDescriptor({@required lsb, @required msb, @required divider})
      : super(lsb: lsb, msb: msb, divider: divider);

  double getMeasurementValue(List<int> data) {
    final dir = lsb < msb ? 1 : -1;
    return (data[lsb] + 256.0 * data[lsb + dir] + 65536.0 * data[msb]) / divider;
  }
}
