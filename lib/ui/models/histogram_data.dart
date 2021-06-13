class HistogramData {
  final int index;
  final double upper;
  int count = 0;
  int percent = 0;

  HistogramData({
    required this.index,
    required this.upper,
  });

  void increment() {
    count++;
  }

  void calculatePercent(int total) {
    if (total > 0) {
      percent = count * 100 ~/ total;
    } else {
      percent = 0;
    }
  }
}
