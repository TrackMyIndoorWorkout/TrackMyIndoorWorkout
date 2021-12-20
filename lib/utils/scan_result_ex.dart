import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

import '../devices/company_registry.dart';
import '../devices/device_map.dart';
import '../devices/gatt_constants.dart';
import 'advertisement_data_ex.dart';
import 'constants.dart';
import 'machine_type.dart';
import 'string_ex.dart';

extension ScanResultEx on ScanResult {
  bool isWorthy(bool filterDevices) {
    if (!advertisementData.connectable) {
      return false;
    }

    if (device.name.isEmpty) {
      return false;
    }

    if (device.id.id.isEmpty) {
      return false;
    }

    if (!filterDevices) {
      return true;
    }

    for (var dev in deviceMap.values) {
      for (var prefix in dev.namePrefixes) {
        if (device.name.toLowerCase().startsWith(prefix.toLowerCase())) {
          return true;
        }
      }

      if (advertisementData.serviceUuids.isNotEmpty) {
        final serviceUuids = advertisementData.uuids;
        if (serviceUuids.contains(fitnessMachineUuid) ||
            serviceUuids.contains(precorServiceUuid) ||
            serviceUuids.contains(heartRateServiceUuid)) {
          return true;
        }
      }
    }

    return false;
  }

  List<String> get serviceUuids => advertisementData.uuids;

  bool hasService(String serviceId) {
    return serviceUuids.contains(serviceId);
  }

  bool get isHeartRateMonitor => hasService(heartRateServiceUuid);

  String manufacturerName() {
    final companyRegistry = Get.find<CompanyRegistry>();

    final companyIds = advertisementData.manufacturerData.keys;
    if (companyIds.isEmpty) {
      return notAvailable;
    }

    List<String> nameStrings = [];
    for (var companyId in companyIds) {
      nameStrings.add(companyRegistry.nameForId(companyId));
    }

    return nameStrings.join(', ');
  }

  MachineType getMachineType() {
    if (serviceUuids.contains(precorServiceUuid)) {
      return MachineType.indoorBike;
    }

    if (serviceUuids.contains(heartRateServiceUuid)) {
      return MachineType.heartRateMonitor;
    }

    if (!serviceUuids.contains(fitnessMachineUuid)) {
      return MachineType.notFitnessMachine;
    }

    for (MapEntry<String, List<int>> entry in advertisementData.serviceData.entries) {
      if (entry.key.uuidString() == fitnessMachineUuid) {
        final serviceData = entry.value;
        if (serviceData.length > 2 && serviceData[0] >= 1) {
          for (final machineType in MachineType.values) {
            if (serviceData[1] & machineType.bit >= 1) {
              return machineType;
            }
          }
        }
      }
    }

    return MachineType.notFitnessMachine;
  }

  IconData getEquipmentIcon() {
    final machineType = getMachineType();

    var icon = Icons.help;
    switch (machineType) {
      case MachineType.indoorBike:
        icon = Icons.directions_bike;
        break;
      case MachineType.treadmill:
        icon = Icons.directions_run;
        break;
      case MachineType.rower:
        icon = Icons.kayaking;
        break;
      case MachineType.heartRateMonitor:
        icon = Icons.favorite;
        break;
      case MachineType.crossTrainer:
        icon = Icons.downhill_skiing;
        break;
      case MachineType.stepClimber:
        icon = Icons.stairs;
        break;
      case MachineType.stairClimber:
        icon = Icons.stairs;
        break;
      default:
        icon = Icons.help;
    }

    return icon;
  }
}
