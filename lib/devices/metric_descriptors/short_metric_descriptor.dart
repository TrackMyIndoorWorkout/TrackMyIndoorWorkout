import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class ShortMetricDescriptor extends MetricDescriptor {
  ShortMetricDescriptor({
    required super.lsb,
    required super.msb,
    super.divider = 1.0,
    super.optional = false,
  });

  @override
  double? getMeasurementValue(List<int> data) {
    final value = data[lsb] + maxUint8 * data[msb];
    if (optional && value == maxUint16 - 1) {
      return null;
    }

    return value / divider;
  }
}
