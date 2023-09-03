import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import 'delays.dart';
import 'logging.dart';

Future<bool> isBluetoothOn() async {
  final blueState = await FlutterBluePlus.adapterState.first.timeout(
      const Duration(milliseconds: dataMapExpiry),
      onTimeout: () => BluetoothAdapterState.off);
  return blueState == BluetoothAdapterState.on;
}

Future<bool> bluetoothCheck(bool silent, int logLevel) async {
  try {
    var blueOn = await isBluetoothOn();
    if (blueOn) {
      return true;
    }

    if (!await FlutterBluePlus.isAvailable) {
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

      if (!(await isBluetoothOn())) {
        await FlutterBluePlus.turnOn();
      }
    }

    return await isBluetoothOn();
  } on Exception catch (e, stack) {
    Logging()
        .logException(logLevel, "BLUETOOTH", "bluetoothCheck", "turd in the punchbowl", e, stack);
    return false;
  }
}
