import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/isar/record.dart';
import '../../utils/bluetooth.dart';
import '../../utils/constants.dart';
import '../../utils/guid_ex.dart';
import '../../utils/logging.dart';
import '../../utils/power_speed_mixin.dart';
import '../device_fourcc.dart';
import '../gadgets/cadence_mixin.dart';
import '../gadgets/complex_sensor.dart';
import '../gadgets/schwinn_x70_hr_sensor.dart';
import '../gatt/ftms.dart';
import '../gatt/schwinn_x70.dart';
import '../metric_descriptors/byte_metric_descriptor.dart';
import '../metric_descriptors/six_byte_metric_descriptor.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import 'device_descriptor.dart';
import 'fixed_layout_device_descriptor.dart';

class SchwinnX70 extends FixedLayoutDeviceDescriptor with CadenceMixin, PowerSpeedMixin {
  static const magicNumbers = [17, 32, 0];
  static const magicFlag = 32 * 256 + 17;

  // Adapted from 
  // https://github.com/ursoft/ANT_Libraries/blob/e122c007f5e1935a9b11c05e601a71f2992bad45/ANT_DLL/WROOM_esp32/WROOM_esp32.ino#L525
  static const List<List<double>> resistancePowerCoeffs =
  [
    [-0.0014, 0.7920, -13.985 ],
    [-0.0004, 0.9991, -19.051 ],
    [ 0.0015, 0.9179, -13.745 ],
    [ 0.0040, 0.9857, -13.095 ],
    [ 0.0027, 1.3958, -22.741 ],
    [ 0.0057, 1.1586, -15.126 ],
    [-0.0013, 2.4666, -49.052 ],
    [ 0.0002, 2.6349, -52.390 ],
    [ 0.0034, 2.6240, -48.072 ],
    [ 0.0147, 1.6372, -19.653 ],
    [ 0.0062, 2.5851, -43.254 ],
    [ 0.0064, 3.2864, -59.336 ],
    [ 0.0048, 3.6734, -69.245 ],
    [ 0.0184, 2.1842, -28.936 ],
    [ 0.0052, 4.3939, -78.603 ],
    [ 0.0094, 3.8871, -65.982 ],
    [ 0.0165, 3.3074, -49.906 ],
    [ 0.0251, 3.2956, -44.436 ],
    [ 0.0281, 2.9107, -38.767 ],
    [ 0.0311, 2.9435, -35.851 ],
    [ 0.0141, 5.5646, -88.686 ],
    [ 0.0517, 1.8361, -13.777 ],
    [ 0.0467, 2.9273, -35.908 ],
    [ 0.0429, 4.1821, -50.141 ],
    [ 0.0652, 3.6670, -46.863 ]
  ];
  late double lastTime;
  late double lastCalories;
  late double lastPower;
  late DateTime lastRxTime;
  RecordWithSport? lastRecord;

  SchwinnX70()
      : super(
          sport: deviceSportDescriptors[schwinnX70BikeFourCC]!.defaultSport,
          isMultiSport: deviceSportDescriptors[schwinnX70BikeFourCC]!.isMultiSport,
          fourCC: schwinnX70BikeFourCC,
          vendorName: "Schwinn",
          modelName: "SCHWINN 170/270",
          manufacturerNamePart: "Nautilus", // "SCHWINN 170/270"
          manufacturerFitId: nautilusFitId,
          model: "",
          tag: "SCH_X70",
          dataServiceId: schwinnX70ServiceUuid,
          dataCharacteristicId: schwinnX70MeasurementUuid,
          controlCharacteristicId: schwinnX70ControlUuid,
          listenOnControl: false,
          timeMetric: ShortMetricDescriptor(lsb: 8, msb: 9, divider: 1.0),
          caloriesMetric: SixByteMetricDescriptor(lsb: 10, msb: 15, divider: 1.0),
          cadenceMetric: ThreeByteMetricDescriptor(lsb: 4, msb: 6, divider: 1.0),
        ) {
    resistanceMetric = ByteMetricDescriptor(lsb: 16);
    initCadence(3, 64, maxUint24);
    initPower2SpeedConstants();
    lastTime = -1.0;
    lastCalories = -1.0;
    lastPower = -1.0;
    lastRxTime = DateTime.now();
  }

  @override
  SchwinnX70 clone() => SchwinnX70();

  @override
  bool isDataProcessable(List<int> data) {
    if (data.length != 17) return false;

    const measurementPrefix = magicNumbers;
    for (int i = 0; i < measurementPrefix.length; i++) {
      if (data[i] != measurementPrefix[i]) return false;
    }

    return true;
  }

  @override
  bool isFlagValid(int flag) {
    return flag == magicFlag;
  }

  @override
  void stopWorkout() {
    clearCadenceData();
  }

  // Adapted from 
  // https://github.com/ursoft/ANT_Libraries/blob/e122c007f5e1935a9b11c05e601a71f2992bad45/ANT_DLL/WROOM_esp32/WROOM_esp32.ino#L525
  double powerFromCadenceResistance(int cadence, int resistance) {
    final int idx = (resistance - 1) % 25;
    final double ret = resistancePowerCoeffs[idx][0] * cadence * cadence + resistancePowerCoeffs[idx][1] * cadence + resistancePowerCoeffs[idx][2];
    return ret > 0.0 ? ret : 0.0;
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    final time = getTime(data);
    final calories = getCalories(data);
    final rxTime = DateTime.now();
    final duration = rxTime.difference(lastRxTime);
    lastRxTime = rxTime;
    if (lastTime < 0 || duration.inSeconds > 63) {
      lastTime = time!;
      lastCalories = calories!;
      lastPower = 0.0;
      lastRecord = null;
      return RecordWithSport(sport: sport);
    } else if (time == lastTime) {
      return lastRecord ?? RecordWithSport(sport: sport);
    }

    final deltaCalories = max(calories! - lastCalories, 0);
    lastCalories = calories;
    var deltaTime = time! - lastTime;
    lastTime = time!;
    if (deltaTime < 0) {
      deltaTime += 65536;
    }

    addCadenceData(time! / 1024, getCadence(data));
    final cadence = min(computeCadence().toInt(), maxByte);
    // the minimum legal value for resistance is 1
    final resistance = max((getResistance(data)?.toInt() ?? 1), 1);
    final power = powerFromCadenceResistance(cadence, resistance);
    if (lastPower == -1.0 || (lastPower - power).abs() < 400.0) {
      lastPower = power;
    } else {
      lastPower += (power - lastPower) / 2.0;
    }
    if (lastPower < 0) {
      lastPower = 1.0;
    }

    final integerPower = lastPower.toInt();
    final speed = velocityForPowerCardano(integerPower) * DeviceDescriptor.ms2kmh;
    final record = RecordWithSport(
      distance: null,
      elapsed: testing ? time ~/ 1024 : null,
      calories: calories ~/ 2097152,
      power: integerPower,
      speed: speed,
      cadence: cadence,
      heartRate: null,
      resistance: resistance.toDouble(),
      sport: sport,
    );
    if (testing) {
      record.elapsedMillis = time ~/ 1.024;
    }

    lastRecord = record;

    return record;
  }

  @override
  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    if (!(await isBluetoothOn())) {
      return;
    }

    if (controlPoint == null || blockSignalStartStop) {
      return;
    }

    if (opCode == startOrResumeControl /* requestControl */ || opCode == stopOrPauseControl) {
      return;
    }

    if (opCode == requestControl /* startOrResumeControl */) {
      List<int> startHrStreamCommand = [
        0x05 /* length */,
        0x03 /* seq-с ceiling */,
        0xD9 /* crc = sum to 0 */,
        0x00,
        0x1F /* command */
      ];

      try {
        await controlPoint.write(startHrStreamCommand);
      } on Exception catch (e, stack) {
        Logging()
            .logException(logLevel, tag, "executeControlOperation", "controlPoint.write", e, stack);
      }
    }
  }

  @override
  List<ComplexSensor> getAdditionalSensors(
      BluetoothDevice device, List<BluetoothService> services) {
    final requiredService = services.firstWhereOrNull(
        (service) => service.serviceUuid.uuidString() == SchwinnX70HrSensor.serviceUuid);
    if (requiredService == null) {
      return [];
    }

    final requiredCharacteristic = requiredService.characteristics.firstWhereOrNull(
        (ch) => ch.characteristicUuid.uuidString() == SchwinnX70HrSensor.characteristicUuid);
    if (requiredCharacteristic == null) {
      return [];
    }

    final additionalSensor = SchwinnX70HrSensor(device);
    additionalSensor.services = services;
    return [additionalSensor];
  }

  @override
  void trimQueues() {
    trimQueue();
  }
}
