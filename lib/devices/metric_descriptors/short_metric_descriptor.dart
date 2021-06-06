import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class ShortMetricDescriptor extends MetricDescriptor {
  ShortMetricDescriptor({
    required lsb,
    required msb,
    divider = 1.0,
    optional = false,
  }) : super(lsb: lsb, msb: msb, divider: divider, optional: optional);

  double? getMeasurementValue(List<int> data) {
    final value = data[lsb] + MAX_UINT8 * data[msb];
    if (optional && value == MAX_UINT16 - 1) {
      return null;
    }
    return value / divider;
  }
}
