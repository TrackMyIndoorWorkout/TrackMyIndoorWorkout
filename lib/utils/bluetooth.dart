import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'bluetooth_adapter.dart';
import 'delays.dart';
import 'logging.dart';

Future<bool> isBluetoothOn() async {
  final adapter = Get.isRegistered<BluetoothAdapter>()
      ? Get.find<BluetoothAdapter>()
      : BluetoothAdapter();

  var blueState = adapter.adapterStateNow;
  if (blueState == BluetoothAdapterState.unknown) {
    blueState = await adapter.adapterState.first.timeout(
      const Duration(milliseconds: dataMapExpiry),
      onTimeout: () => BluetoothAdapterState.off,
    );
  }

  return blueState == BluetoothAdapterState.on;
}

Future<bool> bluetoothCheck(bool silent, int logLevel) async {
  try {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 30) {
        var status = await Permission.location.status;
        if (!status.isGranted) {
          status = await Permission.location.request();
          if (!status.isGranted) {
            return false;
          }
        }

        if (!await Permission.location.serviceStatus.isEnabled) {
          final enableLocation = await Get.defaultDialog(
            title: "Location Services Needed",
            middleText:
                "You have granted Location permission, but the system Location Service (GPS) is currently turned OFF.\n\nPlease turn it ON in the system settings.",
            confirm: TextButton(
              child: const Text("System Settings"),
              onPressed: () => Get.back(result: true),
            ),
            cancel: TextButton(
              child: const Text("Cancel"),
              onPressed: () => Get.back(result: false),
            ),
          );
          if (enableLocation == true) {
            await openAppSettings();
            return false;
          } else {
            return false;
          }
        }
      }
    }

    if (await isBluetoothOn()) {
      return true;
    }

    final adapter = Get.isRegistered<BluetoothAdapter>()
        ? Get.find<BluetoothAdapter>()
        : BluetoothAdapter();

    if (!await adapter.isSupported) {
      if (!silent) {
        await Get.defaultDialog(
          title: "Bluetooth Error",
          middleText: "Device doesn't seem to support Bluetooth",
          confirm: TextButton(child: const Text("Dismiss"), onPressed: () => Get.close(1)),
        );
      }

      return false;
    }

    if (!silent) {
      final tryEnable = await Get.defaultDialog(
        title: "Bluetooth Needed",
        middleText: "Try enable Bluetooth?",
        confirm: TextButton(child: const Text("Yes"), onPressed: () => Get.back(result: true)),
        cancel: TextButton(child: const Text("No"), onPressed: () => Get.back(result: false)),
      );

      if (!tryEnable) {
        return false;
      }

      if (!(await isBluetoothOn())) {
        final adapter = Get.isRegistered<BluetoothAdapter>()
            ? Get.find<BluetoothAdapter>()
            : BluetoothAdapter();
        await adapter.turnOn();
      }
    }

    return await isBluetoothOn();
  } on Exception catch (e, stack) {
    Logging().logException(
      logLevel,
      "BLUETOOTH",
      "bluetoothCheck",
      "turd in the punchbowl",
      e,
      stack,
    );
    return false;
  }
}
