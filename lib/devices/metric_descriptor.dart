import 'package:meta/meta.dart';

abstract class MetricDescriptor {
  final int lsb;
  final int msb;
  final double divider;

  MetricDescriptor({
    @required this.lsb,
    @required this.msb,
    @required this.divider,
  })  : assert(lsb != null),
        assert(msb != null),
        assert(divider != null);

  double getMeasurementValue(List<int> data);
}
