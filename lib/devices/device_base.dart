import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:preferences/preferences.dart';
import '../persistence/preferences.dart';
import '../utils/guid_ex.dart';

abstract class DeviceBase {
  final String serviceId;
  final String characteristicsId;
  BluetoothDevice device;
  BluetoothService _service;
  List<BluetoothService> services;
  BluetoothCharacteristic characteristic;
  StreamSubscription subscription;

  bool connecting;
  bool connected;
  bool attached;
  bool discovering;
  bool discovered;
  bool uxDebug;

  DeviceBase({
    this.serviceId,
    this.characteristicsId,
    this.device,
  })  : assert(serviceId != null),
        assert(characteristicsId != null),
        assert(device != null) {
    connecting = false;
    connected = false;
    attached = false;
    discovering = false;
    discovered = false;
    uxDebug = PrefService.getBool(APP_DEBUG_MODE_TAG);
  }

  Future<bool> connect() async {
    if (uxDebug) {
      connected = true;
      return true;
    }

    if (connected || connecting) return false;

    try {
      connecting = true;
      await device.connect();
    } catch (e) {
      if (e.code != 'already_connected') {
        throw e;
      }
    } finally {
      connecting = false;
      connected = true;
    }
    return connected;
  }

  Future<bool> discover({bool retry = false}) async {
    if (uxDebug) {
      discovered = true;
      return true;
    }

    if (discovering || discovered) return false;

    discovering = true;
    try {
      services = await device.discoverServices();
    } on PlatformException catch (e, stack) {
      debugPrint("${e.message}");
      debugPrintStack(stackTrace: stack, label: "trace:");
      discovering = false;
      if (retry) return false;
      await discover(retry: true);
    }

    discovering = false;
    discovered = true;
    _service = services.firstWhere((service) => service.uuid.uuidString() == serviceId,
        orElse: () => null);

    if (_service != null) {
      characteristic = _service.characteristics
          .firstWhere((ch) => ch.uuid.uuidString() == characteristicsId, orElse: () => null);
    }
    if (characteristic != null) {
      await attach();
    }
    return discovered;
  }

  Future<void> attach() async {
    if (uxDebug) {
      attached = true;
      return;
    }

    if (attached) return;

    await characteristic.setNotifyValue(true);
    attached = true;
  }

  Future<void> cancelSubscription() async {
    if (uxDebug) return;

    await subscription?.cancel();
    subscription = null;
  }

  Future<void> detach() async {
    if (uxDebug) {
      attached = false;
      return;
    }

    if (attached) {
      await characteristic?.setNotifyValue(false);
      attached = false;
    }
    await cancelSubscription();
  }

  Future<void> disconnect() async {
    if (!uxDebug) {
      await detach();
      characteristic = null;
      services = null;
      _service = null;
      await device.disconnect();
    }
    connected = false;
    connecting = false;
    discovering = false;
    discovered = false;
  }
}
