import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/device_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_descriptors/internal_sensor_descriptor.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

void main() {
  test('InternalSensorDescriptor generic properties', () {
    final descriptor = InternalSensorDescriptor();
    expect(descriptor.fourCC, internalMotionSensorFourCC);
    expect(descriptor.deviceCategory, DeviceCategory.primarySensor);
    expect(descriptor.canMeasureCalories, false);
    expect(descriptor.doNotReadManufacturerName, true);
    expect(descriptor.isFitnessMachine, false);
    expect(descriptor.sport, ActivityType.ride);
  });

  test('InternalSensorDescriptor methods do not crash', () async {
    final descriptor = InternalSensorDescriptor();
    // executeControlOperation should be safe
    await descriptor.executeControlOperation(null, false, 0, 0);
    // stopWorkout should be safe
    descriptor.stopWorkout();
    // methods from DataHandler
    expect(descriptor.isDataProcessable([]), false);
    expect(descriptor.isFlagValid(0), false);
    expect(descriptor.stubRecord([]), null);
    expect(descriptor.clone(), isA<InternalSensorDescriptor>());
  });
}
