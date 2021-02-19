import 'package:meta/meta.dart';

import 'fitness_machine_descriptor.dart';

class RowerDeviceDescriptor extends FitnessMachineDescriptor {
  RowerDeviceDescriptor({
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
    primaryMeasurementId = "2ad1",
    canPrimaryMeasurementProcessed,
    cadenceMeasurementServiceId,
    cadenceMeasurementId,
    canCadenceMeasurementProcessed,
    heartRate,
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
    // KayakPro Compact:
    // 44 00101100 (stroke rate, stroke count), total distance, instant pace, instant power
    //  9 00001001 expanded energy, (heart rate), elapsed time
    // Two flag bytes
    byteCounter = 2;
    // negated bit!
    flag = processStrokeRateFlag(flag, true);
    flag = processAverageStrokeRateFlag(flag);
    flag = processTotalDistanceFlag(flag);
    flag = processPaceFlag(flag); // Instant
    flag = processPaceFlag(flag); // Average (fallback)
    flag = processPowerFlag(flag); // Instant
    flag = processPowerFlag(flag); // Average (fallback)
    flag = processResistanceLevelFlag(flag);
    flag = processExpandedEnergyFlag(flag);
    flag = processHeartRateFlag(flag);
    flag = processMetabolicEquivalentFlag(flag);
    flag = processElapsedTimeFlag(flag);
    flag = processRemainingTimeFlag(flag);
  }
}
