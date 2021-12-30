import '../../devices/gatt_constants.dart';
import '../../utils/constants.dart';
import '../../utils/machine_type.dart';

class AdvertisementDigest {
  final String id;
  final List<String> serviceUuids;
  final String manufacturer;
  final int txPower;
  final MachineType machineType;

  AdvertisementDigest({
    required this.id,
    required this.serviceUuids,
    required this.manufacturer,
    required this.txPower,
    required this.machineType,
  });

  bool isHeartRateMonitor() {
    return serviceUuids.contains(heartRateServiceUuid);
  }

  String fitnessMachineSport() {
    if (machineType == MachineType.indoorBike) {
      return ActivityType.ride;
    } else if (machineType == MachineType.treadmill) {
      return ActivityType.run;
    } else if (machineType == MachineType.rower) {
      return ActivityType.kayaking;
    } else if (machineType == MachineType.crossTrainer) {
      return ActivityType.elliptical;
    }

    return ActivityType.ride;
  }
}
