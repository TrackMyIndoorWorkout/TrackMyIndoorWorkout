import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class ByteMetricDescriptor extends MetricDescriptor {
  ByteMetricDescriptor({
    required lsb,
    divider = 1.0,
    optional = false,
  }) : super(lsb: lsb, msb: 0, divider: divider, optional: optional);

  double? getMeasurementValue(List<int> data) {
    if (optional && data[lsb] == MAX_UINT8 - 1) {
      return null;
    }
    return data[lsb] / divider;
  }
}
