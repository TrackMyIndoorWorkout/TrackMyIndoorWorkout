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
    return serviceUuids.contains(HEART_RATE_SERVICE_ID);
  }

  String fitnessMachineSport() {
    if (machineType == MachineType.IndoorBike) {
      return ActivityType.Ride;
    } else if (machineType == MachineType.Treadmill) {
      return ActivityType.Run;
    } else if (machineType == MachineType.Rower) {
      return ActivityType.Kayaking;
    } else if (machineType == MachineType.CrossTrainer) {
      return ActivityType.Elliptical;
    }

    return ActivityType.Ride;
  }
}
