import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import 'delays.dart';
import 'logging.dart';

Future<bool> isBluetoothOn() async {
  final blueOn = await FlutterBluePlus.instance.isOn
      .timeout(const Duration(milliseconds: spinDownThreshold), onTimeout: () => false);
  return blueOn;
}

Future<bool> isBluetoothOff() async {
  return !(await isBluetoothOn());
}

Future<bool> bluetoothCheck(bool silent, int logLevel) async {
  try {
    var blueOn = await FlutterBluePlus.instance.isOn;
    if (blueOn) {
      return true;
    }

    if (!await FlutterBluePlus.instance.isAvailable) {
      if (!silent) {
        await Get.defaultDialog(
          title: "Bluetooth Error",
          middleText: "Device doesn't seem to support Bluetooth",
          confirm: TextButton(
            child: const Text("Dismiss"),
            onPressed: () => Get.close(1),
          ),
        );
      }

      return false;
    }

    if (!silent) {
      final tryEnable = await Get.defaultDialog(
        title: "Bluetooth Needed",
        middleText: "Try enable Bluetooth?",
        confirm: TextButton(
          child: const Text("Yes"),
          onPressed: () => Get.back(result: true),
        ),
        cancel: TextButton(
          child: const Text("No"),
          onPressed: () => Get.back(result: false),
        ),
      );

      if (!tryEnable) {
        return false;
      }

      await BluetoothEnable.enableBluetooth;
      if (await isBluetoothOff()) {
        await FlutterBluePlus.instance.turnOn();
      }
    }

    return await isBluetoothOn();
  } on PlatformException catch (e, stack) {
    Logging.logException(logLevel, "BLUETOOTH", "bluetoothCheck", "${e.message}", e, stack);
    return false;
  }
}
