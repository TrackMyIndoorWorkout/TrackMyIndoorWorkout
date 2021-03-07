import 'package:meta/meta.dart';

import 'fitness_machine_descriptor.dart';
import 'gatt_constants.dart';

class IndoorBikeDeviceDescriptor extends FitnessMachineDescriptor {
  IndoorBikeDeviceDescriptor({
    @required sport,
    @required fourCC,
    @required vendorName,
    @required modelName,
    fullName = '',
    @required namePrefix,
    nameStart,
    manufacturer,
    model,
    primaryServiceId = FITNESS_MACHINE_ID,
    primaryMeasurementId = INDOOR_BIKE_ID,
    canPrimaryMeasurementProcessed,
    canMeasureHeartRate = true,
    heartRateByteIndex,
    calorieFactor = 1.0,
    distanceFactor = 1.0,
  }) : super(
          sport: sport,
          fourCC: fourCC,
          vendorName: vendorName,
          modelName: modelName,
          fullName: fullName,
          namePrefix: namePrefix,
          nameStart: nameStart,
          manufacturer: manufacturer,
          model: model,
          primaryServiceId: primaryServiceId,
          primaryMeasurementId: primaryMeasurementId,
          canPrimaryMeasurementProcessed: canPrimaryMeasurementProcessed,
          canMeasureHeartRate: canMeasureHeartRate,
          heartRateByteIndex: heartRateByteIndex,
          calorieFactor: calorieFactor,
          distanceFactor: distanceFactor,
        );

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.indoor_bike_data.xml
  @override
  processFlag(int flag) {
    super.processFlag(flag);
    // Schwinn IC4, two flag bytes
    // 68 01000100 instant cadence, instant power
    //  2 00000010 heart rate
    // negated first bit!
    flag = processSpeedFlag(flag, true); // Instant
    flag = processSpeedFlag(flag, false); // Average (fallback)
    flag = processCadenceFlag(flag); // Instant
    flag = processCadenceFlag(flag); // Average (fallback)
    flag = processTotalDistanceFlag(flag);
    flag = processResistanceLevelFlag(flag);
    flag = processPowerFlag(flag); // Instant
    flag = processPowerFlag(flag); // Average (fallback)
    flag = processExpandedEnergyFlag(flag);
    flag = processHeartRateFlag(flag);
    flag = processMetabolicEquivalentFlag(flag);
    flag = processElapsedTimeFlag(flag);
    flag = processRemainingTimeFlag(flag);
  }
}
