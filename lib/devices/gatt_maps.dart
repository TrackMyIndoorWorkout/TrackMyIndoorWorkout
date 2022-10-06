import '../utils/constants.dart';
import 'gatt/gatt_constants.dart';

const Map<String, String> uuidToSport = {
  treadmillUuid: ActivityType.run,
  indoorBikeUuid: ActivityType.ride,
  rowerDeviceUuid: ActivityType.rowing,
  crossTrainerUuid: ActivityType.elliptical,
  stepClimberUuid: ActivityType.run,
  stairClimberUuid: ActivityType.run,
};

const Map<String, String> sportToUuid = {
  ActivityType.run: treadmillUuid,
  ActivityType.ride: indoorBikeUuid,
  ActivityType.kayaking: rowerDeviceUuid,
  ActivityType.rowing: rowerDeviceUuid,
  ActivityType.canoeing: rowerDeviceUuid,
  ActivityType.swim: rowerDeviceUuid,
  ActivityType.elliptical: crossTrainerUuid,
};
