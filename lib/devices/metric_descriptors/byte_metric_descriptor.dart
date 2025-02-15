import '../../utils/constants.dart';
import 'metric_descriptor.dart';

class ByteMetricDescriptor extends MetricDescriptor {
  ByteMetricDescriptor({required super.lsb, super.divider = 1.0, super.optional = false})
    : super(msb: 0);

  @override
  double? getMeasurementValue(List<int> data) {
    if (optional && data[lsb] == maxUint8 - 1) {
      return null;
    }

    return data[lsb] / divider;
  }
}
