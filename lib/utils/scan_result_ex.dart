import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../devices/company_registry.dart';
import '../devices/device_fourcc.dart';
import '../devices/gatt/csc.dart';
import '../devices/gatt/concept2.dart';
import '../devices/gatt/ftms.dart';
import '../devices/gatt/hrm.dart';
import '../devices/gatt/power_meter.dart';
import '../devices/gatt/precor.dart';
import '../devices/gatt/schwinn_x70.dart';
import '../preferences/paddling_with_cycling_sensors.dart';
import 'advertisement_data_ex.dart';
import 'constants.dart';
import 'display.dart';
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

    if (advertisementData.serviceUuids.isNotEmpty) {
      final serviceUuids = advertisementData.uuids;
      if (serviceUuids.contains(fitnessMachineUuid) ||
          serviceUuids.contains(precorServiceUuid) ||
          serviceUuids.contains(schwinnX70ServiceUuid) ||
          serviceUuids.contains(cyclingPowerServiceUuid) ||
          serviceUuids.contains(cyclingCadenceServiceUuid) ||
          serviceUuids.contains(c2RowingPrimaryServiceUuid) ||
          serviceUuids.contains(heartRateServiceUuid)) {
        return true;
      }
    }

    for (MapEntry<String, List<String>> mapEntry in deviceNamePrefixes.entries) {
      for (var prefix in mapEntry.value) {
        if (device.name.toLowerCase().startsWith(prefix.toLowerCase())) {
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

  int getFtmsServiceDataMachineByte(String deviceSport) {
    for (MapEntry<String, List<int>> entry in advertisementData.serviceData.entries) {
      if (entry.key.uuidString() == fitnessMachineUuid) {
        final serviceData = entry.value;
        if (serviceData.length > 2 && serviceData[0] >= 1 && serviceData[1] > 0) {
          return serviceData[1];
        }
      }
    }

    if (deviceSport.isNotEmpty) {
      return MachineTypeEx.getMachineByteFlag(deviceSport);
    }

    return 0;
  }

  List<MachineType> getFtmsServiceDataMachineTypes(int ftmsServiceDataMachineByte) {
    List<MachineType> machineTypes = [];
    for (final machineType in MachineType.values) {
      if (machineType.bit > 0 && ftmsServiceDataMachineByte & machineType.bit >= 1) {
        machineTypes.add(machineType);
      }
    }

    return machineTypes;
  }

  MachineType getMachineType(List<MachineType> ftmsServiceDataMachineTypes, String deviceSport) {
    if (serviceUuids.contains(precorServiceUuid) ||
        serviceUuids.contains(schwinnX70ServiceUuid) ||
        serviceUuids.contains(cyclingPowerServiceUuid)) {
      return MachineType.indoorBike;
    }

    if (serviceUuids.contains(cyclingCadenceServiceUuid)) {
      final prefService = Get.find<BasePrefService>();
      final kayakingWithCyclingSensors =
          prefService.get<bool>(paddlingWithCyclingSensorsTag) ?? paddlingWithCyclingSensorsDefault;

      if (kayakingWithCyclingSensors) {
        return MachineType.rower;
      } else {
        return MachineType.indoorBike;
      }
    }

    if (serviceUuids.contains(c2RowingPrimaryServiceUuid)) {
      return MachineType.rower;
    }

    if (serviceUuids.contains(heartRateServiceUuid)) {
      return MachineType.heartRateMonitor;
    }

    if (!serviceUuids.contains(fitnessMachineUuid)) {
      return MachineType.notFitnessMachine;
    }

    if (ftmsServiceDataMachineTypes.isEmpty) {
      ftmsServiceDataMachineTypes =
          getFtmsServiceDataMachineTypes(getFtmsServiceDataMachineByte(deviceSport));
    }

    if (ftmsServiceDataMachineTypes.isEmpty) {
      return MachineType.notFitnessMachine;
    }

    if (ftmsServiceDataMachineTypes.length == 1) {
      return ftmsServiceDataMachineTypes.first;
    }

    return MachineType.multiFtms;
  }

  IconData getIcon(List<MachineType> ftmsServiceDataMachineTypes, String deviceSport) {
    for (MapEntry<String, List<String>> mapEntry in deviceNamePrefixes.entries) {
      if (multiSportFourCCs.contains(mapEntry.key)) {
        continue;
      }

      for (var prefix in mapEntry.value) {
        if (device.name.toLowerCase().startsWith(prefix.toLowerCase())) {
          return getSportIcon(deviceSportDescriptors[mapEntry.key]!.defaultSport);
        }
      }
    }

    return getMachineType(ftmsServiceDataMachineTypes, deviceSport).icon;
  }
}
