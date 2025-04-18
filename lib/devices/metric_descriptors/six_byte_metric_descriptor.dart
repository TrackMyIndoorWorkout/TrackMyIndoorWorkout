import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class SixByteMetricDescriptor extends MetricDescriptor {
  SixByteMetricDescriptor({
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
        maxUint8 *
            (data[lsb + dir] +
                maxUint8 *
                    (data[lsb + 2 * dir] +
                        maxUint8 *
                            (data[msb - 2 * dir] +
                                maxUint8 * (data[msb - dir] + maxUint8 * data[msb]))));
    if (optional && value == maxUint48 - 1) {
      return null;
    }

    return value / divider;
  }
}
