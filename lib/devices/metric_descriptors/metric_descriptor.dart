abstract class MetricDescriptor {
  final int lsb;
  final int msb;
  final double divider;
  final bool optional;

  MetricDescriptor({
    required this.lsb,
    required this.msb,
    required this.divider,
    this.optional = false,
  });

  double? getMeasurementValue(List<int> data);
}
