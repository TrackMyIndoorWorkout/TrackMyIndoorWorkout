import 'package:collection/collection.dart';

class StreamingMedianCalculator<T extends num> {
  T? median;
  late PriorityQueue<T> medianLow;
  late PriorityQueue<T> medianHigh;

  StreamingMedianCalculator() {
    medianLow = HeapPriorityQueue<T>();
    medianHigh = HeapPriorityQueue<T>();
  }

  void processElement(T element) {
    if (median == null || element < median!) {
      medianLow.add(-element as T);
    } else {
      medianHigh.add(element);
    }

    if (medianLow.length > medianHigh.length + 1) {
      final highestLow = medianLow.removeFirst();
      medianHigh.add(-highestLow as T);
    } else if (medianHigh.length > medianLow.length + 1) {
      final lowestHigh = medianHigh.removeFirst();
      medianLow.add(-lowestHigh as T);
    }

    if (medianLow.length == medianHigh.length) {
      median = medianHigh.first; // We deviate here a little from traditional median
    } else {
      median = medianLow.length > medianHigh.length ? -medianLow.first as T : medianHigh.first;
    }
  }
}
