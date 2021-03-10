import 'dart:async';
import 'dart:collection';

import 'package:flutter_blue/flutter_blue.dart';
import '../devices/cadence_data.dart';
import '../devices/gatt_constants.dart';
import '../utils/guid_ex.dart';
import 'short_metric_descriptor.dart';

class CadenceSensor {
  static const int REVOLUTION_SLIDING_WINDOW = 15; // Seconds
  static const int EVENT_TIME_OVERFLOW = 64; // Overflows every 64 seconds
  static const int MAX_UINT16 = 65536;

  // Secondary (Crank cadence) metrics
  ShortMetricDescriptor revolutionsMetric;
  ShortMetricDescriptor revolutionTime;
  int cadenceFlag;
  ListQueue<CadenceData> cadenceData;

  BluetoothDevice device;
  BluetoothService _cadenceService;
  BluetoothCharacteristic _cadenceMeasurements;
  StreamSubscription _cadenceSubscription;

  int cadence;
  bool connected;
  bool attached;

  CadenceSensor({this.device}) : assert(device != null) {
    cadenceFlag = 0;
    cadenceData = ListQueue<CadenceData>();
    connected = false;
    attached = false;
    cadence = 0;
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
      _cadenceService = services.firstWhere(
          (service) => service.uuid.uuidString() == CADENCE_SERVICE_ID,
          orElse: () => null);

      if (_cadenceService != null) {
        _cadenceMeasurements = _cadenceService.characteristics
            .firstWhere((ch) => ch.uuid.uuidString() == CADENCE_MEASUREMENT_ID, orElse: () => null);
      }
      if (_cadenceMeasurements != null) {
        await attach();
        ret = true;
      }
    }
    return ret;
  }

  Stream<int> get listenToCadence async* {
    if (!attached) return;
    await for (var byteString in _cadenceMeasurements.value) {
      if (!canCadenceMeasurementProcessed(byteString)) continue;

      cadence = processCadenceMeasurement(byteString);
      yield cadence;
    }
  }

  Future<void> attach() async {
    await _cadenceMeasurements.setNotifyValue(true);
    attached = true;
  }

  Future<void> detach() async {
    await _cadenceMeasurements?.setNotifyValue(false);
    attached = false;
    await _cadenceSubscription?.cancel();
  }

  Future<void> disconnect() async {
    await detach();
    _cadenceMeasurements = null;
    _cadenceService = null;
    await device.disconnect();
    connected = false;
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
