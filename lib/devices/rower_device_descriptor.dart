import 'package:meta/meta.dart';

import 'fitness_machine_descriptor.dart';
import 'gatt_constants.dart';

class RowerDeviceDescriptor extends FitnessMachineDescriptor {
  RowerDeviceDescriptor({
    @required sport,
    @required fourCC,
    @required vendorName,
    @required modelName,
    fullName = '',
    @required namePrefix,
    manufacturer,
    model,
    primaryServiceId = FITNESS_MACHINE_ID,
    primaryMeasurementId = ROWER_DEVICE_ID,
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

  // https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.rower_data.xml
  @override
  processFlag(int flag) {
    super.processFlag(flag);
    // KayakPro Compact: two flag bytes
    // 44 00101100 (stroke rate, stroke count), total distance, instant pace, instant power
    //  9 00001001 expanded energy, (heart rate), elapsed time
    // negated first bit!
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
