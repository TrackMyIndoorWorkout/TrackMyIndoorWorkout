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
      return NOT_AVAILABLE;
    }

    List<String> nameStrings = [];
    for (var companyId in companyIds) {
      nameStrings.add(companyRegistry.nameForId(companyId));
    }

    return nameStrings.join(', ');
  }

  MachineType getMachineType() {
    if (serviceUuids.contains(precorServiceUuid)) {
      return MachineType.IndoorBike;
    }

    if (serviceUuids.contains(heartRateServiceUuid)) {
      return MachineType.HeartRateMonitor;
    }

    if (!serviceUuids.contains(fitnessMachineUuid)) {
      return MachineType.NotFitnessMachine;
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

    return MachineType.NotFitnessMachine;
  }

  IconData getEquipmentIcon() {
    final machineType = getMachineType();

    var icon = Icons.help;
    switch (machineType) {
      case MachineType.IndoorBike:
        icon = Icons.directions_bike;
        break;
      case MachineType.Treadmill:
        icon = Icons.directions_run;
        break;
      case MachineType.Rower:
        icon = Icons.kayaking;
        break;
      case MachineType.HeartRateMonitor:
        icon = Icons.favorite;
        break;
      case MachineType.CrossTrainer:
        icon = Icons.downhill_skiing;
        break;
      case MachineType.StepClimber:
        icon = Icons.stairs;
        break;
      case MachineType.StairClimber:
        icon = Icons.stairs;
        break;
      default:
        icon = Icons.help;
    }

    return icon;
  }
}
