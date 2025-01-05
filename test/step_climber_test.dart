import 'package:flutter_test/flutter_test.dart';
import 'package:track_my_indoor_exercise/devices/device_factory.dart';
import 'package:track_my_indoor_exercise/devices/device_fourcc.dart';
import 'package:track_my_indoor_exercise/persistence/record.dart';
import 'package:track_my_indoor_exercise/utils/constants.dart';

class TestPair {
  final List<int> data;
  final RecordWithSport record;

  const TestPair({required this.data, required this.record});
}

void main() {
  test('Step Climber Device constructor tests', () async {
    final sClimber = DeviceFactory.getGenericFTMSStepClimber();

    expect(sClimber.sport, ActivityType.stairStepper);
    expect(sClimber.fourCC, genericFTMSStepClimberFourCC);
    expect(sClimber.isMultiSport, false);
  });
}
