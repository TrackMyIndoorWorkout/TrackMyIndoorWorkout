import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/isar/record.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/guid_ex.dart';
import '../../utils/logging.dart';
import '../gadgets/c2_additional_status1.dart';
import '../gadgets/c2_additional_status2.dart';
import '../gadgets/c2_additional_stroke_data.dart';
import '../gadgets/complex_sensor.dart';
import '../gatt/concept2.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import '../device_fourcc.dart';
import 'fixed_layout_device_descriptor.dart';

class Concept2Rower extends FixedLayoutDeviceDescriptor {
  static const expectedDataPacketLength = 19;
  static const distanceLsbByteIndex = 3;

  Concept2Rower()
      : super(
          sport: deviceSportDescriptors[concept2RowerFourCC]!.defaultSport,
          isMultiSport: deviceSportDescriptors[concept2RowerFourCC]!.isMultiSport,
          fourCC: concept2RowerFourCC,
          vendorName: "Concept2",
          modelName: "PM5",
          manufacturerNamePart: "Concept2",
          manufacturerFitId: concept2FitId,
          model: "PM5",
          tag: "CONCEPT2",
          dataServiceId: c2RowingPrimaryServiceUuid,
          dataCharacteristicId: c2RowingGeneralStatusUuid,
          listenOnControl: false,
          flagByteSize: 1,
          distanceMetric: ThreeByteMetricDescriptor(
            lsb: distanceLsbByteIndex,
            msb: distanceLsbByteIndex + 2,
            divider: 10.0,
          ),
        );

  @override
  Concept2Rower clone() => Concept2Rower();

  @override
  bool isDataProcessable(List<int> data) {
    return data.length == expectedDataPacketLength;
  }

  @override
  bool isFlagValid(int flag) {
    return true;
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    return RecordWithSport(
      distance: getDistance(data),
      sport: ActivityType.rowing,
    );
  }

  @override
  void stopWorkout() {}

  @override
  List<ComplexSensor> getAdditionalSensors(
      BluetoothDevice device, List<BluetoothService> services) {
    final requiredService = services.firstWhereOrNull(
        (service) => service.serviceUuid.uuidString() == c2RowingPrimaryServiceUuid);
    if (requiredService == null) {
      return [];
    }

    List<ComplexSensor> additionalSensors = [];

    final requiredCharacteristic1 = requiredService.characteristics.firstWhereOrNull(
        (ch) => ch.characteristicUuid.uuidString() == C2AdditionalStatus1.serviceUuid);
    if (requiredCharacteristic1 != null) {
      final additionalSensor = C2AdditionalStatus1(device);
      additionalSensor.services = services;
      additionalSensors.add(additionalSensor);
    }

    final requiredCharacteristic2 = requiredService.characteristics.firstWhereOrNull(
        (ch) => ch.characteristicUuid.uuidString() == C2AdditionalStatus2.serviceUuid);
    if (requiredCharacteristic2 != null) {
      final additionalSensor = C2AdditionalStatus2(device);
      additionalSensor.services = services;
      additionalSensors.add(additionalSensor);
    }

    final requiredCharacteristic3 = requiredService.characteristics.firstWhereOrNull(
        (ch) => ch.characteristicUuid.uuidString() == C2AdditionalStrokeData.serviceUuid);
    if (requiredCharacteristic3 != null) {
      final additionalSensor = C2AdditionalStrokeData(device);
      additionalSensor.services = services;
      additionalSensors.add(additionalSensor);
    }

    return additionalSensors;
  }

  @override
  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    Logging().log(logLevel, logLevelError, tag, "executeControlOperation", "Not implemented!");
  }
}
