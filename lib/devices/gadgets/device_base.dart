import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:preferences/preferences.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../../utils/guid_ex.dart';
import '../gatt_constants.dart';

abstract class DeviceBase {
  final String serviceId;
  String characteristicsId;
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
    if (uxDebug || discovered) {
      discovered = true;
      return true;
    }

    if (discovering) return false;

    discovering = true;
    try {
      services = await device.discoverServices();
    } on PlatformException catch (e, stack) {
      debugPrint("$e");
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
      if (characteristicsId == null) {
        characteristic = _service.characteristics
            .firstWhere((ch) => ch.uuid.uuidString() == characteristicsId, orElse: () => null);
      } else {
        characteristic = _service.characteristics.firstWhere(
            (ch) => FTMS_SPORT_CHARACTERISTICS.contains(ch.uuid.uuidString()),
            orElse: () => null);
        characteristicsId = characteristic.uuid.uuidString();
      }
    } else {
      return false;
    }
    return characteristic != null;
  }

  String inferSportFromCharacteristicsId() {
    if (characteristicsId == TREADMILL_ID) {
      return ActivityType.Run;
    } else if (characteristicsId == PRECOR_MEASUREMENT_ID || characteristicsId == INDOOR_BIKE_ID) {
      return ActivityType.Ride;
    } else if (characteristicsId == ROWER_DEVICE_ID) {
      return ActivityType.Rowing;
    }

    return null;
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
      try {
        await characteristic?.setNotifyValue(false);
      } on PlatformException catch (e, stack) {
        debugPrint("$e");
        debugPrintStack(stackTrace: stack, label: "trace:");
      }
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
