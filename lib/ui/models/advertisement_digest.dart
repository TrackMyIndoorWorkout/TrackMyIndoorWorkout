import '../../devices/company_registry.dart';
import '../../utils/machine_type.dart';

class AdvertisementDigest {
  final String id;
  final List<String> serviceUuids;
  final List<int> companyIds;
  final String manufacturer;
  final int txPower;
  final int machineTypesByte;
  final MachineType machineType;
  final List<MachineType> machineTypes;

  AdvertisementDigest({
    required this.id,
    required this.serviceUuids,
    required this.companyIds,
    required this.manufacturer,
    required this.txPower,
    required this.machineTypesByte,
    required this.machineType,
    required this.machineTypes,
  });

  // #239 SOLE E25 elliptical: Treadmill, Indoor Bike, Cross Trainer
  bool isMultiFtms() => machineTypes.where((element) => element.isFtms).length > 1;

  bool needsMatrixSpecialTreatment() {
    return companyIds.contains(CompanyRegistry.johnsonHealthTechKey);
    // companyIds.contains(CompanyRegistry.matrixIncKey) is hopefully not needed
  }
}
