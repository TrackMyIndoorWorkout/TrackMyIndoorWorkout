import 'package:meta/meta.dart';
import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class ThreeByteMetricDescriptor extends MetricDescriptor {
  ThreeByteMetricDescriptor({@required lsb, @required msb, divider = 1.0, optional = false})
      : super(lsb: lsb, msb: msb, divider: divider, optional: optional);

  double getMeasurementValue(List<int> data) {
    final dir = lsb < msb ? 1 : -1;
    final value = data[lsb] + MAX_UINT8 * (data[lsb + dir] + MAX_UINT8 * data[msb]);
    if (optional && value == MAX_UINT24 - 1) {
      return null;
    }
    return value / divider;
  }
}
