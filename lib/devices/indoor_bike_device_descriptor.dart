import 'package:meta/meta.dart';

import 'fitness_machine_descriptor.dart';

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
    primaryMeasurementServiceId = "1826",
    primaryMeasurementId = "2ad2",
    canPrimaryMeasurementProcessed,
    cadenceMeasurementServiceId,
    cadenceMeasurementId,
    canCadenceMeasurementProcessed,
    heartRate,
    calorieFactor,
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
          primaryMeasurementServiceId: primaryMeasurementServiceId,
          primaryMeasurementId: primaryMeasurementId,
          canPrimaryMeasurementProcessed: canPrimaryMeasurementProcessed,
          cadenceMeasurementServiceId: cadenceMeasurementServiceId,
          cadenceMeasurementId: cadenceMeasurementId,
          canCadenceMeasurementProcessed: canCadenceMeasurementProcessed,
          heartRate: heartRate,
          calorieFactor: calorieFactor,
          distanceFactor: distanceFactor,
        );

  @override
  processFlag(int flag) {
    clearMetrics();
    // Schwinn IC4:
    // 68 01000100 instant cadence, instant power
    //  2 00000010 heart rate
    // Two flag bytes
    byteCounter = 2;
    // negated bit!
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
