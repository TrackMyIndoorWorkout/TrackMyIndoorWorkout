import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../../utils/guid_ex.dart';
import '../gatt_constants.dart';

abstract class DeviceBase {
  final String serviceId;
  String? characteristicsId;
  BluetoothDevice? device;
  BluetoothService? _service;
  List<BluetoothService> services = [];
  BluetoothCharacteristic? characteristic;
  StreamSubscription? subscription;

  bool connecting = false;
  bool connected = false;
  bool attached = false;
  bool discovering = false;
  bool discovered = false;

  final prefService = Get.find<BasePrefService>();
  bool uxDebug = APP_DEBUG_MODE_DEFAULT;

  DeviceBase({
    required this.serviceId,
    this.characteristicsId,
    this.device,
  }) {
    uxDebug = prefService.get<bool>(APP_DEBUG_MODE_TAG) ?? APP_DEBUG_MODE_DEFAULT;
  }

  Future<bool> connect() async {
    if (uxDebug) {
      connected = true;
      return true;
    }

    if (connected || connecting) return false;

    try {
      connecting = true;
      await device?.connect();
    } on Exception catch (e) {
      if (e is PlatformException && e.code != 'already_connected') {
        rethrow;
      }
    } finally {
      connecting = false;
      connected = true;
    }
    return connected;
  }

  bool discoverCore() {
    discovering = false;
    discovered = true;
    _service = services.firstWhereOrNull((service) => service.uuid.uuidString() == serviceId);

    if (_service == null) {
      characteristic = null;
      return false;
    }

    if (characteristicsId != null) {
      characteristic = _service!.characteristics
          .firstWhereOrNull((ch) => ch.uuid.uuidString() == characteristicsId);
    } else {
      characteristic = _service!.characteristics
          .firstWhereOrNull((ch) => ftmsSportCharacteristics.contains(ch.uuid.uuidString()));
      characteristicsId = characteristic?.uuid.uuidString();
    }

    return characteristic != null;
  }

  Future<bool> discover({bool retry = false}) async {
    if (!connected) {
      return false;
    }

    if (uxDebug || discovered) {
      discovered = true;
      return true;
    }

    if (discovering || device == null) return false;

    discovering = true;
    try {
      services = await device!.discoverServices();
    } on PlatformException catch (e, stack) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
      discovering = false;
      if (retry) return false;
      await discover(retry: true);
    }

    return discoverCore();
  }

  String? inferSportFromCharacteristicsId() {
    if (characteristicsId == treadmillUuid) {
      return ActivityType.run;
    } else if (characteristicsId == precorMeasurementUuid || characteristicsId == indoorBikeUuid) {
      return ActivityType.ride;
    } else if (characteristicsId == rowerDeviceUuid) {
      return ActivityType.rowing;
    } else if (characteristicsId == crossTrainerUuid) {
      return ActivityType.elliptical;
    }

    return null;
  }

  Future<void> attach() async {
    if (uxDebug) {
      attached = true;
      return;
    }

    if (attached) return;

    await characteristic?.setNotifyValue(true);
    attached = true;
  }

  void cancelSubscription() {
    if (uxDebug) return;

    subscription?.cancel();
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
    cancelSubscription();
  }

  Future<void> disconnect() async {
    if (!uxDebug) {
      await detach();
      await device?.disconnect();
      characteristic = null;
      services = [];
      _service = null;
    }
    connected = false;
    connecting = false;
    discovering = false;
    discovered = false;
  }
}
