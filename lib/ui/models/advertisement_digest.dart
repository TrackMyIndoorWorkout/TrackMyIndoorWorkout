import '../../devices/company_registry.dart';
import '../../utils/machine_type.dart';

class AdvertisementDigest {
  final String id;
  final List<String> serviceUuids;
  final List<int> companyIds;
  final String manufacturers;
  late final String loweredManufacturers;
  final int txPower;
  final int machineTypesByte;
  final MachineType machineType;
  final List<MachineType> machineTypes;

  AdvertisementDigest({
    required this.id,
    required this.serviceUuids,
    required this.companyIds,
    required this.manufacturers,
    required this.txPower,
    required this.machineTypesByte,
    required this.machineType,
    required this.machineTypes,
  }) {
    loweredManufacturers = manufacturers.toLowerCase();
  }

  // #239 SOLE E25 elliptical: Treadmill, Indoor Bike, Cross Trainer
  bool isMultiFtms() => machineTypes.where((element) => element.isSpecificFtms).length > 1;

  bool needsMatrixSpecialTreatment() {
    return companyIds.contains(CompanyRegistry.johnsonHealthTechKey);
    // companyIds.contains(CompanyRegistry.matrixIncKey) is hopefully not needed
  }

  bool mayNeedTechnogymSpecialTreatment() {
    return companyIds.contains(CompanyRegistry.technogymSpaKey);
  }
}
