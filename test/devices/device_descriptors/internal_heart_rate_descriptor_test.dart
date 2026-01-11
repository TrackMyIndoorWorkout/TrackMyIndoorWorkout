import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/internal_heart_rate_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/export/fit/fit_manufacturer.dart';

void main() {
  test('InternalHeartRateDescriptor generic properties', () {
    final descriptor = InternalHeartRateDescriptor();
    expect(descriptor.fourCC, internalHeartRateMonitorFourCC);
    expect(descriptor.vendorName, "Device Internal");
    expect(descriptor.modelName, "Heart Rate Monitor");
    expect(descriptor.manufacturerNamePart, "Unknown");
    expect(descriptor.manufacturerFitId, stravaFitId);
    expect(descriptor.deviceCategory, DeviceCategory.primarySensor);
    expect(descriptor.isFitnessMachine, false);
  });

  test('clone returns new instance', () {
    final descriptor = InternalHeartRateDescriptor();
    final clone = descriptor.clone();
    expect(clone, isA<InternalHeartRateDescriptor>());
    expect(clone.fourCC, descriptor.fourCC);
  });

  test('InternalHeartRateDescriptor methods do not crash', () async {
    final descriptor = InternalHeartRateDescriptor();
    // executeControlOperation should be safe
    await descriptor.executeControlOperation(null, false, 0, 0);
    // stopWorkout should be safe
    descriptor.stopWorkout();
    // methods from DataHandler
    expect(descriptor.isDataProcessable([]), false);
    expect(descriptor.isFlagValid(0), false);
    // processFlag returns void, verify it doesn't throw
    expect(() => descriptor.processFlag(0, 0), returnsNormally);

    expect(descriptor.stubRecord([]), null);
  });
}
