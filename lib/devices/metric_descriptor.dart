import 'package:meta/meta.dart';

abstract class MetricDescriptor {
  final int lsb;
  final int msb;
  final double divider;
  final bool optional;

  MetricDescriptor({
    @required this.lsb,
    @required this.msb,
    @required this.divider,
    this.optional = false,
  })  : assert(lsb != null),
        assert(msb != null),
        assert(divider != null),
        assert(optional != null);

  double getMeasurementValue(List<int> data);
}
