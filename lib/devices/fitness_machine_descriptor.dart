import 'dart:collection';

import 'package:meta/meta.dart';

import 'cadence_data.dart';
import 'device_descriptor.dart';

abstract class FitnessMachineDescriptor extends DeviceDescriptor {
  // Primary metrics
  int featuresFlag;

  // Secondary (Crank cadence) metrics
  int cadenceFlag;

  ListQueue<CadenceData> cadenceData;
  static const int REVOLUTION_SLIDING_WINDOW = 15; // Seconds
  static const int EVENT_TIME_OVERFLOW = 64; // Overflows every 64 seconds
  double residueCalories;

  FitnessMachineDescriptor({
    @required sport,
    @required fourCC,
    @required vendorName,
    @required modelName,
    fullName = '',
    @required namePrefix,
    nameStart,
    manufacturer,
    model,
    primaryMeasurementServiceId,
    primaryMeasurementId,
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
        ) {
    cadenceData = ListQueue<CadenceData>();
    featuresFlag = 0;
    cadenceFlag = 0;
    residueCalories = 0;
  }

  processFlag(int flag);
}
