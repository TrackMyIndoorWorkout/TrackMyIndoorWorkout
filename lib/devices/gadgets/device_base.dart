import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';
import 'package:rxdart/rxdart.dart';
import '../../devices/device_descriptors/device_descriptor.dart';
import '../../devices/gatt_maps.dart';
import '../../preferences/app_debug_mode.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/delays.dart';
import '../../utils/guid_ex.dart';
import '../../utils/logging.dart';
import '../gatt/battery.dart';
import '../gatt/csc.dart';
import '../gatt/concept2.dart';
import '../gatt/ftms.dart';
import '../gatt/kayak_first.dart';
import '../gatt/precor.dart';
import '../gatt/power_meter.dart';
import '../gatt/schwinn_x70.dart';
import '../bluetooth_device_ex.dart';

typedef StringMetricProcessingFunction = Function(String measurement);

abstract class DeviceBase {
  final String serviceId;
  String characteristicId;
  BluetoothDevice? device;
  List<BluetoothService> services = [];
  BluetoothService? service;
  BluetoothCharacteristic? characteristic;
  StreamSubscription? subscription;

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
    this.controlCharacteristicId = "",
    this.listenOnControl = true,
    this.statusCharacteristicId = "",
  }) {
    readConfiguration();
  }

  void readConfiguration() {
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

  Future<bool> connectAndDiscover({retry = false}) async {
    await connect();

    return await discover(retry: retry);
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

  Future<void> connectToControlPoint(bool obtainControl) async {
    if (controlCharacteristicId.isEmpty) {
      return;
    }

    if (controlPoint == null && controlCharacteristicId.isNotEmpty) {
      controlPoint = service!.characteristics
          .firstWhereOrNull((ch) => ch.uuid.uuidString() == controlCharacteristicId);
    }

    if (status == null && statusCharacteristicId.isNotEmpty) {
      status = service!.characteristics
          .firstWhereOrNull((ch) => ch.uuid.uuidString() == statusCharacteristicId);
    }

    if (listenOnControl && !controlNotification && controlPoint != null) {
      try {
        controlNotification = await controlPoint?.setNotifyValue(true) ?? false;
      } on PlatformException catch (e, stack) {
        Logging.logException(
          logLevel,
          "DEVICE_BASE",
          "connectToControlPoint",
          "${e.message}",
          e,
          stack,
        );
      }

      controlPointSubscription = controlPoint?.value
          .throttleTime(
        const Duration(milliseconds: ftmsStatusThreshold),
        leading: false,
        trailing: true,
      )
          .listen((controlResponse) async {
        if (logLevel >= logLevelInfo) {
          Logging().log(
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
          Logging().log(
            logLevel,
            logLevelInfo,
            "FITNESS_EQUIPMENT",
            "connectToControlPoint controlPointSubscription",
            logMessage,
          );
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
      Logging.logException(
        logLevel,
        "DEVICE_BASE",
        "discover",
        "${e.message}",
        e,
        stack,
      );

      discovering = false;
      if (retry) {
        return false;
      }

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
    } else if (characteristicId == c2RowingGeneralStatusUuid) {
      sports.add(ActivityType.rowing);
    } else if (characteristicId == rowerDeviceUuid) {
      sports.addAll(waterSports);
    } else if (characteristicId == precorMeasurementUuid ||
        characteristicId == schwinnX70MeasurementUuid ||
        characteristicId == indoorBikeUuid ||
        characteristicId == cyclingCadenceMeasurementUuid ||
        characteristicId == cyclingPowerMeasurementUuid) {
      sports.add(ActivityType.ride);
    } else if (characteristicId == crossTrainerUuid) {
      sports.add(ActivityType.elliptical);
    } else if (characteristicId == kayakFirstAllAroundUuid) {
      sports.addAll([ActivityType.kayaking, ActivityType.canoeing]);
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
        Logging.logException(
          logLevel,
          "DEVICE_BASE",
          "detach",
          "${e.message}",
          e,
          stack,
        );
      }

      attached = false;
    }

    cancelSubscription();
  }

  Future<void> disconnect() async {
    if (!uxDebug) {
      await detach();
      try {
        await device?.disconnect();
      } on PlatformException catch (e, stack) {
        Logging.logException(
          logLevel,
          "DEVICE_BASE",
          "discover",
          "Could not disconnect",
          e,
          stack,
        );
      }

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
      Logging().log(
        logLevel,
        logLevelInfo,
        tag,
        "_listenToData",
        data.toString(),
      );
    }
  }

  Future<int> _readBatteryLevelCore() async {
    final batteryService = BluetoothDeviceEx.filterService(services, batteryServiceUuid);
    if (batteryService == null) {
      return -1;
    }

    final batteryLevel =
        BluetoothDeviceEx.filterCharacteristic(batteryService.characteristics, batteryLevelUuid);
    if (batteryLevel == null) {
      return -1;
    }

    final batteryLevelData = await batteryLevel.read();
    return batteryLevelData[0];
  }

  Future<int> readBatteryLevel() async {
    if (!connected) {
      await connect();
    }

    if (!connected) return -1;

    if (!discovered) {
      await discover();
    }

    if (!discovered) return -1;

    try {
      return await _readBatteryLevelCore();
    } on PlatformException catch (e, stack) {
      Logging.logException(
        logLevel,
        "DEVICE_BASE",
        "discover",
        "Could not disconnect",
        e,
        stack,
      );
      return -1;
    }
  }

  Future<DeviceCategory> _cscSensorTypeCore() async {
    final powerService = BluetoothDeviceEx.filterService(services, cyclingPowerServiceUuid);
    if (powerService != null) {
      return DeviceCategory.primarySensor;
    }

    final cscService = BluetoothDeviceEx.filterService(services, cyclingCadenceServiceUuid);
    if (cscService == null) {
      return DeviceCategory.smartDevice;
    }

    final cscFeatures = BluetoothDeviceEx.filterCharacteristic(
        cscService.characteristics, cyclingCadenceFeaturesUuid);
    if (cscFeatures == null) {
      return DeviceCategory.smartDevice;
    }

    final cscFeaturesData = await cscFeatures.read();
    return cscFeaturesData[0] % 2 == 1
        ? DeviceCategory.primarySensor
        : DeviceCategory.secondarySensor;
  }

  Future<DeviceCategory> cscSensorType() async {
    if (!connected) {
      await connect();
    }

    if (!connected) return DeviceCategory.smartDevice;

    if (!discovered) {
      await discover();
    }

    if (!discovered) return DeviceCategory.smartDevice;

    try {
      return await _cscSensorTypeCore();
    } on PlatformException catch (e, stack) {
      Logging.logException(
        logLevel,
        "DEVICE_BASE",
        "cscSensorType",
        "_cscSensorTypeCore call catch",
        e,
        stack,
      );
      return DeviceCategory.smartDevice;
    }
  }

  Future<void> listenToKayakFirst(StringMetricProcessingFunction? metricProcessingFunction) async {
    if (characteristic == null || uxDebug) return;

    if (!connected) {
      await connect();
    }

    if (!connected) return;

    if (!discovered) {
      await discover();
    }

    if (!discovered || characteristic == null) return;

    if (!attached) {
      await attach();
    }

    controlPointSubscription = characteristic?.value.listen((byteList) {
      if (metricProcessingFunction != null) {
        metricProcessingFunction(utf8.decode(byteList));
      }
    });
  }

  Future<int> sendKayakFirstCommand(String command) async {
    if (!connected || uxDebug) {
      await connect();
    }

    if (!connected) return -1;

    if (!discovered) {
      await discover();
    }

    if (!discovered || characteristic == null) return -1;

    try {
      final commandCrLf = command.contains("\n") ? command : "$command\r\n";
      await characteristic?.write(utf8.encode(commandCrLf));
    } on PlatformException catch (e, stack) {
      Logging.logException(
        logLevel,
        "DEVICE_BASE",
        "sendKayakFirstCommand",
        "characteristic.write",
        e,
        stack,
      );
      return -1;
    }

    return 0;
  }

  Future<void> unListenKayakFirst() async {
    if (characteristic == null || uxDebug || !connected || !discovered || !attached) return;

    controlPointSubscription?.cancel();
    controlPointSubscription = null;
  }
}
