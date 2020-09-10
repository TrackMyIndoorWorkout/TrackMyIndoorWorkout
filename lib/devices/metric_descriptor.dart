class MetricDescriptor {
  final int lsb;
  final int msb;
  final int divider;

  MetricDescriptor({this.lsb, this.msb, this.divider});

  double getMeasurementValue(List<int> data) {
    return (data[lsb] + 256.0 * data[msb]) / divider;
  }
}
