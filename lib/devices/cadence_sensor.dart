import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';
import 'cadence_data.dart';
import 'device_base.dart';
import 'gatt_constants.dart';
import 'short_metric_descriptor.dart';

class CadenceSensor extends DeviceBase {
  static const int REVOLUTION_SLIDING_WINDOW = 10; // Seconds
  static const int EVENT_TIME_OVERFLOW = 64; // Overflows every 64 seconds
  static const int MAX_UINT16 = 65536;

  // Secondary (Crank cadence) metrics
  ShortMetricDescriptor revolutionsMetric;
  ShortMetricDescriptor revolutionTime;
  int cadenceFlag;
  ListQueue<CadenceData> cadenceData;

  int cadence;

  CadenceSensor(device)
      : super(
          serviceId: CADENCE_SERVICE_ID,
          characteristicsId: CADENCE_MEASUREMENT_ID,
          device: device,
        ) {
    cadenceFlag = 0;
    cadenceData = ListQueue<CadenceData>();
    cadence = 0;
  }

  Stream<int> get _listenToCadence async* {
    if (!attached) return;
    await for (var byteString in characteristic.value) {
      if (!canCadenceMeasurementProcessed(byteString)) continue;

      cadence = processCadenceMeasurement(byteString);
      yield cadence;
    }
  }

  Stream<int> get throttledCadence {
    return _listenToCadence.throttleTime(Duration(milliseconds: 500));
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.csc_measurement.xml
  bool canCadenceMeasurementProcessed(List<int> data) {
    if (data == null || data.length < 1) return false;

    var flag = data[0];
    // 16 bit revolution and 16 bit time
    if (cadenceFlag != flag && flag > 0) {
      var expectedLength = 1; // The flag itself
      // Has wheel revolution? (first bit)
      if (flag % 2 == 1) {
        // Skip it, we are not interested in wheel revolution
        expectedLength += 6; // 32 bit revolution and 16 bit time
      }
      flag ~/= 2;
      // Has crank revolution? (second bit)
      if (flag % 2 == 1) {
        expectedLength += 4; // 16 bit revolution and 16 bit time
      } else {
        return false;
      }
      revolutionsMetric = ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1);
      revolutionTime =
          ShortMetricDescriptor(lsb: expectedLength + 2, msb: expectedLength + 3, divider: 1024.0);
      cadenceFlag = flag;

      return data.length == expectedLength;
    }

    return flag > 0;
  }

  int processCadenceMeasurement(List<int> data) {
    if (!canCadenceMeasurementProcessed(data)) return 0;

    cadenceData.add(CadenceData(
      seconds: getRevolutionTime(data),
      revolutions: getRevolutions(data),
    ));

    var firstData = cadenceData.first;
    if (cadenceData.length == 1) {
      return firstData.revolutions ~/ firstData.seconds;
    }

    var lastData = cadenceData.last;
    var revDiff = lastData.revolutions - firstData.revolutions;
    // Check overflow
    if (revDiff < 0) {
      revDiff += MAX_UINT16;
    }
    var secondsDiff = lastData.seconds - firstData.seconds;
    // Check overflow
    if (secondsDiff < 0) {
      secondsDiff += EVENT_TIME_OVERFLOW;
    }

    while (secondsDiff > REVOLUTION_SLIDING_WINDOW && cadenceData.length > 2) {
      cadenceData.removeFirst();
      secondsDiff = cadenceData.last.seconds - cadenceData.first.seconds;
      // Check overflow
      if (secondsDiff < 0) {
        secondsDiff += EVENT_TIME_OVERFLOW;
      }
    }

    return revDiff ~/ secondsDiff;
  }

  int getRevolutions(List<int> data) {
    return revolutionsMetric?.getMeasurementValue(data)?.toInt();
  }

  double getRevolutionTime(List<int> data) {
    return revolutionTime?.getMeasurementValue(data);
  }

  clearMetrics() {
    revolutionsMetric = null;
    revolutionTime = null;
  }
}
