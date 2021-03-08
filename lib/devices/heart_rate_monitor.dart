import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import '../devices/gatt_constants.dart';
import '../utils/guid_ex.dart';
import 'byte_metric_descriptor.dart';
import 'short_metric_descriptor.dart';

typedef DisplayFn = Function(int heartRate);

class HeartRateMonitor {
  BluetoothDevice device;
  BluetoothService _heartRateService;
  BluetoothCharacteristic _heartRateMeasurement;
  int _heartRateFlag;
  int heartRate;
  ByteMetricDescriptor _byteHeartRateMetric;
  ShortMetricDescriptor _shortHeartRateMetric;
  StreamSubscription _hrSubscription;
  bool connected;
  bool attached;

  HeartRateMonitor({
    this.device,
  }) : assert(device != null) {
    connected = false;
    attached = false;
    heartRate = 0;
  }

  Future<bool> connect() async {
    var ret = false;
    try {
      await device.connect();
    } catch (e) {
      if (e.code != 'already_connected') {
        throw e;
      }
    } finally {
      connected = true;
      final services = await device.discoverServices();
      _heartRateService = services.firstWhere(
          (service) => service.uuid.uuidString() == HEART_RATE_SERVICE_ID,
          orElse: () => null);

      if (_heartRateService != null) {
        _heartRateMeasurement = _heartRateService.characteristics.firstWhere(
            (ch) => ch.uuid.uuidString() == HEART_RATE_MEASUREMENT_ID,
            orElse: () => null);
      }
      if (_heartRateMeasurement != null) {
        await attach();
        ret = true;
      }
    }
    return ret;
  }

  Stream<int> get listenForYourHeart async* {
    if (!attached) return;
    await for (var byteString in _heartRateMeasurement.value) {
      heartRate = _processHeartRateMeasurement(byteString);
      yield heartRate;
    }
  }

  Future<void> attach() async {
    await _heartRateMeasurement.setNotifyValue(true);
    attached = true;
  }

  Future<void> detach() async {
    await _heartRateMeasurement?.setNotifyValue(false);
    attached = false;
    await _hrSubscription?.cancel();
  }

  Future<void> disconnect() async {
    await detach();
    _heartRateMeasurement = null;
    _heartRateService = null;
    await device.disconnect();
    connected = false;
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
