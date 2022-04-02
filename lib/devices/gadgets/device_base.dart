import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import '../../devices/gatt_maps.dart';
import '../../preferences/app_debug_mode.dart';
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
  bool uxDebug = appDebugModeDefault;

  DeviceBase({
    required this.serviceId,
    this.characteristicsId,
    this.device,
  }) {
    uxDebug = prefService.get<bool>(appDebugModeTag) ?? appDebugModeDefault;
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

    setCharacteristicById(characteristicsId);
    return characteristic != null;
  }

  void setCharacteristicById(String? newCharacteristicsId) {
    if (newCharacteristicsId != null &&
        newCharacteristicsId == characteristicsId &&
        characteristic != null) {
      return;
    }

    characteristicsId = newCharacteristicsId;
    if (characteristicsId != null) {
      characteristic = _service!.characteristics
          .firstWhereOrNull((ch) => ch.uuid.uuidString() == characteristicsId);
    } else {
      characteristic = _service!.characteristics
          .firstWhereOrNull((ch) => ftmsSportCharacteristics.contains(ch.uuid.uuidString()));
      characteristicsId = characteristic?.uuid.uuidString();
    }
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
      if (kDebugMode) {
        debugPrint("$e");
        debugPrintStack(stackTrace: stack, label: "trace:");
      }

      discovering = false;
      if (retry) return false;
      await discover(retry: true);
    }

    return discoverCore();
  }

  List<String> inferSportsFromCharacteristicsIds() {
    if (discovered) {
      return _service!.characteristics
          .where((char) => ftmsSportCharacteristics.contains(char.uuid.uuidString()))
          .map((char) => uuidToSport[char.uuid.uuidString()]!)
          .toSet()
          .toList(growable: false);
    }

    List<String> sports = [];
    if (characteristicsId == treadmillUuid ||
        characteristicsId == stepClimberUuid ||
        characteristicsId == stairClimberUuid) {
      sports.add(ActivityType.run);
    } else if (characteristicsId == precorMeasurementUuid || characteristicsId == indoorBikeUuid) {
      sports.add(ActivityType.ride);
    } else if (characteristicsId == rowerDeviceUuid) {
      sports.addAll(waterSports);
    } else if (characteristicsId == crossTrainerUuid) {
      sports.add(ActivityType.elliptical);
    }

    return sports;
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
        if (kDebugMode) {
          debugPrint("$e");
          debugPrintStack(stackTrace: stack, label: "trace:");
        }
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
