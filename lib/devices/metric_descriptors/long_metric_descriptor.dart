import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class LongMetricDescriptor extends MetricDescriptor {
  LongMetricDescriptor({
    required super.lsb,
    required super.msb,
    super.divider = 1.0,
    super.optional = false,
  });

  @override
  double? getMeasurementValue(List<int> data) {
    final dir = lsb < msb ? 1 : -1;
    final value =
        data[lsb] +
        maxUint8 * (data[lsb + dir] + maxUint8 * (data[msb - dir] + maxUint8 * data[msb]));
    if (optional && value == maxUint32 - 1) {
      return null;
    }

    return value / divider;
  }
}
