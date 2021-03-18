import 'package:meta/meta.dart';

import 'metric_descriptor.dart';

class ThreeByteMetricDescriptor extends MetricDescriptor {
  ThreeByteMetricDescriptor({@required lsb, @required msb, divider = 1.0, optional = false})
      : super(lsb: lsb, msb: msb, divider: divider, optional: optional);

  double getMeasurementValue(List<int> data) {
    final dir = lsb < msb ? 1 : -1;
    final value = data[lsb] + 256 * (data[lsb + dir] + 256 * data[msb]);
    if (optional && value == 255 + 256 * (255 + 256 * 255)) {
      return null;
    }
    return value / divider;
  }
}
