class HistogramData {
  final int index;
  final double upper;
  late int count;
  late int percent;

  HistogramData({
    required this.index,
    required this.upper,
  }) {
    count = 0;
    percent = 0;
  }

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
