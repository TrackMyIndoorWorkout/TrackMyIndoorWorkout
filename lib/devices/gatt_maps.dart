import '../utils/constants.dart';
import 'gatt/ftms.dart';

const Map<String, String> uuidToSport = {
  crossTrainerUuid: ActivityType.elliptical,
  indoorBikeUuid: ActivityType.ride,
  rowerDeviceUuid: ActivityType.rowing,
  stairClimberUuid: ActivityType.rockClimbing,
  stepClimberUuid: ActivityType.rockClimbing,
  treadmillUuid: ActivityType.run,
};

const Map<String, String> sportToUuid = {
  ActivityType.canoeing: rowerDeviceUuid,
  ActivityType.elliptical: crossTrainerUuid,
  ActivityType.kayaking: rowerDeviceUuid,
  ActivityType.nordicSki: rowerDeviceUuid,
  ActivityType.ride: indoorBikeUuid,
  ActivityType.rockClimbing: stairClimberUuid,
  ActivityType.run: treadmillUuid,
  ActivityType.rowing: rowerDeviceUuid,
  ActivityType.swim: rowerDeviceUuid,
};
