import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'byte_metric_descriptor.dart';
import 'device_base.dart';
import 'gatt_constants.dart';
import 'short_metric_descriptor.dart';

typedef DisplayFn = Function(int heartRate);

class HeartRateMonitor extends DeviceBase {
  int _heartRateFlag;
  int heartRate;
  ByteMetricDescriptor _byteHeartRateMetric;
  ShortMetricDescriptor _shortHeartRateMetric;
  bool connected;
  bool attached;

  HeartRateMonitor(device)
      : super(
          serviceId: HEART_RATE_SERVICE_ID,
          characteristicsId: HEART_RATE_MEASUREMENT_ID,
          device: device,
        ) {
    heartRate = 0;
  }

  Stream<int> get _listenToYourHeart async* {
    if (!attached) return;
    await for (var byteString in characteristic.value) {
      heartRate = _processHeartRateMeasurement(byteString);
      yield heartRate;
    }
  }

  Stream<int> get throttledHeartRate {
    return _listenToYourHeart.throttleTime(Duration(milliseconds: 500));
  }

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.heart_rate_measurement.xml
  bool _canHeartRateMeasurementProcessed(List<int> data) {
    if (data == null || data.length < 1) return false;

    var flag = data[0];
    // 16 bit revolution and 16 bit time
    if (_heartRateFlag != flag && flag > 0) {
      var expectedLength = 1; // The flag
      // Has wheel revolution? (first bit)
      if (flag % 2 == 0) {
        _byteHeartRateMetric = ByteMetricDescriptor(lsb: expectedLength);
        expectedLength += 1; // 8 bit HR
      } else {
        _shortHeartRateMetric = ShortMetricDescriptor(lsb: expectedLength, msb: expectedLength + 1);
        expectedLength += 2; // 16 bit HR
      }
      flag ~/= 2;
      // Sensor Contact Status Bit Pair
      flag ~/= 4;
      // Energy Expanded Status
      if (flag % 2 == 1) {
        expectedLength += 2; // 16 bit, kJ
      }
      flag ~/= 2;
      // RR Interval bit
      if (flag % 2 == 1) {
        expectedLength += 2; // 1/1024 sec
      }
      _heartRateFlag = flag;

      return data.length == expectedLength;
    }

    return flag > 0;
  }

  int _processHeartRateMeasurement(List<int> data) {
    if (_canHeartRateMeasurementProcessed(data)) {
      if (_byteHeartRateMetric != null) {
        final newHeartRate = _byteHeartRateMetric.getMeasurementValue(data)?.toInt();
        if (newHeartRate != null && newHeartRate > 0) {
          heartRate = newHeartRate;
        }
      } else if (_shortHeartRateMetric != null) {
        final newHeartRate = _shortHeartRateMetric.getMeasurementValue(data)?.toInt();
        if (newHeartRate != null && newHeartRate > 0) {
          heartRate = newHeartRate;
        }
      }
    }

    return heartRate;
  }
}
