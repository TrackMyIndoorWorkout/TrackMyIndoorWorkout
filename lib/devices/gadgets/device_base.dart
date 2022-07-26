import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:rxdart/rxdart.dart';
import '../../devices/gatt_maps.dart';
import '../../preferences/app_debug_mode.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/delays.dart';
import '../../utils/guid_ex.dart';
import '../../utils/logging.dart';
import '../gatt_constants.dart';

abstract class DeviceBase {
  final String serviceId;
  String characteristicId;
  BluetoothDevice? device;
  List<BluetoothService> services = [];
  BluetoothService? service;
  BluetoothCharacteristic? characteristic;
  StreamSubscription? subscription;

  String extraCharacteristicId;
  String controlCharacteristicId;
  bool listenOnControl;
  BluetoothCharacteristic? controlPoint;
  StreamSubscription? controlPointSubscription;
  bool controlNotification = false;
  bool gotControl = false;

  String statusCharacteristicId;
  BluetoothCharacteristic? status;
  StreamSubscription? statusSubscription;

  bool connecting = false;
  bool connected = false;
  bool attached = false;
  bool discovering = false;
  bool discovered = false;

  final prefService = Get.find<BasePrefService>();
  bool uxDebug = appDebugModeDefault;
  int logLevel = logLevelDefault;

  DeviceBase({
    required this.serviceId,
    required this.characteristicId,
    required this.device,
    this.extraCharacteristicId = "",
    this.controlCharacteristicId = "",
    this.listenOnControl = true,
    this.statusCharacteristicId = "",
  }) {
    readConfiguration();
  }

  void readConfiguration() {
    final prefService = Get.find<BasePrefService>();
    uxDebug = prefService.get<bool>(appDebugModeTag) ?? appDebugModeDefault;
    logLevel = prefService.get<int>(logLevelTag) ?? logLevelDefault;
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

  Future<bool> discoverCore() async {
    discovering = false;
    discovered = true;
    service = services.firstWhereOrNull((service) => service.uuid.uuidString() == serviceId);

    if (service == null) {
      characteristic = null;
      return false;
    }

    await setCharacteristicById(characteristicId);

    return characteristic != null;
  }

  Future<void> setCharacteristicById(String newCharacteristicId) async {
    if (newCharacteristicId.isNotEmpty &&
        newCharacteristicId == characteristicId &&
        characteristic != null) {
      return;
    }

    characteristicId = newCharacteristicId;
    if (characteristicId.isNotEmpty) {
      characteristic = service!.characteristics
          .firstWhereOrNull((ch) => ch.uuid.uuidString() == characteristicId);
    } else {
      characteristic = service!.characteristics
          .firstWhereOrNull((ch) => ftmsSportCharacteristics.contains(ch.uuid.uuidString()));
      characteristicId = characteristic?.uuid.uuidString() ?? "";
    }

    await connectToControlPoint(true);
  }

  Future<void> connectToControlPoint(obtainControl) async {
    if (controlCharacteristicId.isEmpty) {
      return;
    }

    if (controlPoint == null && controlCharacteristicId.isNotEmpty) {
      controlPoint = service!.characteristics
          .firstWhereOrNull((ch) => ch.uuid.uuidString() == controlCharacteristicId);
    }

    if (status != null && statusCharacteristicId.isNotEmpty) {
      status = service!.characteristics
          .firstWhereOrNull((ch) => ch.uuid.uuidString() == statusCharacteristicId);
    }

    if (listenOnControl && !controlNotification && controlPoint != null) {
      try {
        controlNotification = await controlPoint?.setNotifyValue(true) ?? false;
      } on PlatformException catch (e, stack) {
        debugPrint("$e");
        debugPrintStack(stackTrace: stack, label: "trace:");
      }

      controlPointSubscription = controlPoint?.value
          .throttleTime(
        const Duration(milliseconds: ftmsStatusThreshold),
        leading: false,
        trailing: true,
      )
          .listen((controlResponse) async {
        if (logLevel >= logLevelInfo) {
          Logging.log(
            logLevel,
            logLevelInfo,
            "FITNESS_EQUIPMENT",
            "connectToControlPoint controlPointSubscription",
            controlResponse.toString(),
          );
        }

        if (controlResponse.length >= 3 &&
            controlResponse[0] == controlOpcode &&
            controlResponse[2] == successResponse) {
          String logMessage = "Unknown success";
          switch (controlResponse[1]) {
            case requestControl:
              gotControl = true;
              logMessage = "Got control!";
              break;
            case startOrResumeControl:
              logMessage = "Started!";
              break;
            case stopOrPauseControl:
              logMessage = "Stopped!";
              break;
          }
          if (logLevel >= logLevelInfo) {
            Logging.log(
              logLevel,
              logLevelInfo,
              "FITNESS_EQUIPMENT",
              "connectToControlPoint controlPointSubscription",
              logMessage,
            );
          }
        }
      });
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

    final success = await discoverCore();

    return success;
  }

  List<String> inferSportsFromCharacteristicIds() {
    if (discovered) {
      return service!.characteristics
          .where((char) => ftmsSportCharacteristics.contains(char.uuid.uuidString()))
          .map((char) => uuidToSport[char.uuid.uuidString()]!)
          .toSet()
          .toList(growable: false);
    }

    List<String> sports = [];
    if (characteristicId == treadmillUuid ||
        characteristicId == stepClimberUuid ||
        characteristicId == stairClimberUuid) {
      sports.add(ActivityType.run);
    } else if (characteristicId == precorMeasurementUuid || characteristicId == indoorBikeUuid) {
      sports.add(ActivityType.ride);
    } else if (characteristicId == rowerDeviceUuid) {
      sports.addAll(waterSports);
    } else if (characteristicId == crossTrainerUuid) {
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
      service = null;
    }

    connected = false;
    connecting = false;
    discovering = false;
    discovered = false;
  }

  void logData(List<int> data, String tag) {
    if (logLevel >= logLevelInfo) {
      Logging.log(
        logLevel,
        logLevelInfo,
        "DeviceBase",
        "$tag logData",
        data.toString(),
      );
    }
  }
}
