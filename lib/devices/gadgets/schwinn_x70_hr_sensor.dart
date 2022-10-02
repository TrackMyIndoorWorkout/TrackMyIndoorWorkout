import '../../persistence/models/record.dart';
import '../../utils/constants.dart';
import '../gatt_constants.dart';
import 'complex_sensor.dart';

class SchwinnX70HrSensor extends ComplexSensor {
  static const serviceUuid = schwinnX70ServiceUuid;
  static const characteristicUuid = schwinnX70ExtraMeasurementUuid;

  static const expectedPacketLength = 20;
  static const dataMarkerByteIndex = 15;
  static const dataMarkerByteValue = 0x5a;
  static const heartRateByteIndex = 16;

  SchwinnX70HrSensor(device) : super(serviceUuid, characteristicUuid, device);

  @override
  void processFlag(int flag) {}

  // https://github.com/ursoft/ANT_Libraries/blob/e122c007f5e1935a9b11c05e601a71f2992bad45/ANT_DLL/WROOM_esp32/WROOM_esp32.ino#L865
  @override
  bool canMeasurementProcessed(List<int> data) {
    if (data.length != expectedPacketLength) return false;

    return data[dataMarkerByteIndex] == dataMarkerByteValue;
  }

  @override
  RecordWithSport processMeasurement(List<int> data) {
    if (!canMeasurementProcessed(data)) {
      return RecordWithSport(sport: ActivityType.ride);
    }

    return RecordWithSport(
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      heartRate: data[heartRateByteIndex],
      sport: ActivityType.ride,
    );
  }

  @override
  void clearMetrics() {}
}
