import 'package:meta/meta.dart';

class HistogramData {
  final int index;
  final double upper;
  int count;
  int percent;

  HistogramData({
    @required this.index,
    @required this.upper,
  })  : assert(index != null),
        assert(upper != null) {
    count = 0;
    percent = 0;
  }

  increment() {
    count++;
  }

  calculatePercent(int total) {
    if (total > 0) {
      percent = count * 100 ~/ total;
    } else {
      percent = 0;
    }
  }
}
