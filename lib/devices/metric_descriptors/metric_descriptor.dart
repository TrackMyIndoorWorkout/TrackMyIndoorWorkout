abstract class MetricDescriptor {
  final int lsb;
  final int msb;
  final double divider;

  MetricDescriptor({required this.lsb, required this.msb, required this.divider});

  double? getMeasurementValue(List<int> data);
}
