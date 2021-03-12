import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import '../utils/guid_ex.dart';

abstract class DeviceBase {
  final String serviceId;
  final String characteristicsId;
  BluetoothDevice device;
  BluetoothService _service;
  BluetoothCharacteristic characteristic;
  List<StreamSubscription> subscriptions;
  Stream broadcastStream;

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
    await characteristic.setNotifyValue(true);
    attached = true;
  }

  addSubscription(StreamSubscription subscription) {
    subscriptions.add(subscription);
  }

  Future<void> cancelSubscription(StreamSubscription subscription) async {
    await subscription?.cancel();
    subscriptions.remove(subscription);
  }

  Future<void> detach(bool cancelAll) async {
    await characteristic?.setNotifyValue(false);
    attached = false;
    if (cancelAll) {
      subscriptions.forEach((subscription) async {
        await subscription?.cancel();
      });
    }
  }

  Future<void> disconnect() async {
    await detach(true);
    characteristic = null;
    _service = null;
    await device.disconnect();
    connected = false;
  }
}
