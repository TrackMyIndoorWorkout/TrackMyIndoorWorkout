import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import '../utils/guid_ex.dart';

abstract class DeviceBase {
  final String serviceId;
  final String characteristicsId;
  BluetoothDevice device;
  BluetoothService _service;
  BluetoothCharacteristic characteristic;
  StreamSubscription subscription;

  bool connected;
  bool attached;

  DeviceBase({
    this.serviceId,
    this.characteristicsId,
    this.device,
  })  : assert(serviceId != null),
        assert(characteristicsId != null),
        assert(device != null) {
    connected = false;
    attached = false;
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
      _service = services.firstWhere((service) => service.uuid.uuidString() == serviceId,
          orElse: () => null);

      if (_service != null) {
        characteristic = _service.characteristics
            .firstWhere((ch) => ch.uuid.uuidString() == characteristicsId, orElse: () => null);
      }
      if (characteristic != null) {
        await attach();
        ret = true;
      }
    }
    return ret;
  }

  Future<void> attach() async {
    if (attached) return;
    await characteristic.setNotifyValue(true);
    attached = true;
  }

  Future<void> cancelSubscription() async {
    await subscription?.cancel();
    subscription = null;
  }

  Future<void> detach() async {
    if (!attached) {
      await characteristic?.setNotifyValue(false);
      attached = false;
    }
    await cancelSubscription();
  }

  Future<void> disconnect() async {
    await detach();
    characteristic = null;
    _service = null;
    await device.disconnect();
    connected = false;
  }
}
