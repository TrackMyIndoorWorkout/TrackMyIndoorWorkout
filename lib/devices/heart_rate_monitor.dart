import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import '../devices/gatt_constants.dart';
import 'byte_metric_descriptor.dart';
import 'short_metric_descriptor.dart';

typedef DisplayFn = Function(int heartRate);

class HeartRateMonitor {
  final BluetoothDevice device;
  BluetoothService _heartRateService;
  BluetoothCharacteristic _heartRateMeasurement;
  int _heartRateFlag;
  int heartRate;
  ByteMetricDescriptor _byteHeartRateMetric;
  ShortMetricDescriptor _shortHeartRateMetric;
  StreamSubscription _hrSubscription;

  HeartRateMonitor({
    this.device,
  }) : assert(device != null);

  Future<bool> connect() async {
    await device.connect();
    final services = await device.discoverServices();
    _heartRateService = services.firstWhere(
        (service) => service.uuid.toString().substring(4, 8).toLowerCase() == HEART_RATE_SERVICE_ID,
        orElse: () => null);

    if (_heartRateService != null) {
      _heartRateMeasurement = _heartRateService.characteristics.firstWhere(
          (ch) => ch.uuid.toString().substring(4, 8).toLowerCase() == HEART_RATE_MEASUREMENT_ID,
          orElse: () => null);
    }
    if (_heartRateMeasurement != null) {
      return true;
    }
    return false;
  }

  attach(DisplayFn displayFunction) async {
    await _heartRateMeasurement.setNotifyValue(true);
    _hrSubscription = _heartRateMeasurement.value.listen((data) async {
      if (data != null && data.length > 1) {
        heartRate = await _processHeartRateMeasurement(data);
        displayFunction(heartRate);
      }
    });
  }

  detach() async {
    await _heartRateMeasurement?.setNotifyValue(false);
    await _hrSubscription?.cancel();
  }

  disconnect() async {
    await detach();
    _heartRateMeasurement = null;
    _heartRateService = null;
    await device.disconnect();
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

  Future<int> _processHeartRateMeasurement(List<int> data) async {
    if (!_canHeartRateMeasurementProcessed(data)) return 0;

    if (_byteHeartRateMetric != null) {
      return _byteHeartRateMetric?.getMeasurementValue(data)?.toInt();
    }
    if (_shortHeartRateMetric != null) {
      return _shortHeartRateMetric?.getMeasurementValue(data)?.toInt();
    }

    return 0;
  }
}
