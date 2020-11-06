class ShortMetricDescriptor {
  final int lsb;
  final int msb;
  final double divider;

  ShortMetricDescriptor({this.lsb, this.msb, this.divider});

  double getMeasurementValue(List<int> data) {
    return (data[lsb] + 256.0 * data[msb]) / divider;
  }
}
