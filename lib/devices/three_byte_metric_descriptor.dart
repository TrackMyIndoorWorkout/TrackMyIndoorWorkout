class ThreeByteMetricDescriptor {
  final int lsb;
  final int msb;
  final double divider;

  ThreeByteMetricDescriptor({this.lsb, this.msb, this.divider});

  double getMeasurementValue(List<int> data) {
    final dir = lsb < msb ? 1 : -1;
    return (data[lsb] + 256.0 * data[lsb + dir] + 65536.0 * data[msb]) /
        divider;
  }
}
