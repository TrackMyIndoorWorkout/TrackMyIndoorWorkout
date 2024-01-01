import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/isar/record.dart';
import '../../preferences/log_level.dart';
// import '../../utils/constants.dart';
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

class Concept2Erg extends FixedLayoutDeviceDescriptor {
  static const expectedDataPacketLength = 19;
  static const distanceLsbByteIndex = 3;

  Concept2Erg(String defaultSport, bool isMultiSport, String fourCC)
      : super(
          sport: defaultSport,
          isMultiSport: isMultiSport,
          fourCC: fourCC,
          vendorName: "Concept2",
          modelName: "PM5",
          manufacturerNamePart: "Concept2",
          manufacturerFitId: concept2FitId,
          model: "PM5",
          tag: "CONCEPT2",
          dataServiceId: c2ErgPrimaryServiceUuid,
          dataCharacteristicId: c2ErgGeneralStatusUuid,
          listenOnControl: false,
          flagByteSize: 1,
          distanceMetric: ThreeByteMetricDescriptor(
            lsb: distanceLsbByteIndex,
            msb: distanceLsbByteIndex + 2,
            divider: 10.0,
          ),
        );

  @override
  Concept2Erg clone() => Concept2Erg(
        deviceSportDescriptors[concept2ErgFourCC]!.defaultSport,
        deviceSportDescriptors[concept2ErgFourCC]!.isMultiSport,
        concept2ErgFourCC,
      );

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
      sport: sport,
    );
  }

  @override
  void stopWorkout() {}

  @override
  List<ComplexSensor> getAdditionalSensors(
      BluetoothDevice device, List<BluetoothService> services) {
    final requiredService = services
        .firstWhereOrNull((service) => service.serviceUuid.uuidString() == c2ErgPrimaryServiceUuid);
    if (requiredService == null) {
      return [];
    }

    List<ComplexSensor> additionalSensors = [];

    final requiredCharacteristic1 = requiredService.characteristics.firstWhereOrNull(
        (ch) => ch.characteristicUuid.uuidString() == C2AdditionalStatus1.characteristicUuid);
    if (requiredCharacteristic1 != null) {
      final additionalSensor = C2AdditionalStatus1(device);
      additionalSensor.services = services;
      additionalSensors.add(additionalSensor);
    }

    final requiredCharacteristic2 = requiredService.characteristics.firstWhereOrNull(
        (ch) => ch.characteristicUuid.uuidString() == C2AdditionalStatus2.characteristicUuid);
    if (requiredCharacteristic2 != null) {
      final additionalSensor = C2AdditionalStatus2(device);
      additionalSensor.services = services;
      additionalSensors.add(additionalSensor);
    }

    final requiredCharacteristic3 = requiredService.characteristics.firstWhereOrNull(
        (ch) => ch.characteristicUuid.uuidString() == C2AdditionalStrokeData.characteristicUuid);
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
