import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/models/record.dart';
import '../../preferences/log_level.dart';
import '../../utils/logging.dart';
import '../gatt/ftms.dart';
import '../gatt/kayak_first.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import '../device_fourcc.dart';
import 'device_descriptor.dart';

class KayakFirstDescriptor extends DeviceDescriptor {
  static const dataStreamFlag = 0x36; // ASCII 6
  static const separator = 0x3B; // ASCII ;
  static const startCommand = "9;1";
  static const stopCommand = "9;3";
  static const reset1Command = "1";
  static const reset2Command = "2";
  static const pollDataCommand = "6";

  KayakFirstDescriptor()
      : super(
          sport: deviceSportDescriptors[kayakFirstFourCC]!.defaultSport,
          isMultiSport: deviceSportDescriptors[kayakFirstFourCC]!.isMultiSport,
          fourCC: kayakFirstFourCC,
          vendorName: "Kayak First",
          modelName: "Kayak First Ergometer",
          manufacturerNamePart: "Manufacturer Name",
          manufacturerFitId: stravaFitId,
          model: "Model",
          deviceCategory: DeviceCategory.smartDevice,
          isPolling: true,
          fragmentedPackets: true,
          dataServiceId: kayakFirstServiceUuid,
          dataCharacteristicId: kayakFirstAllAroundUuid,
          controlCharacteristicId: "",
          statusCharacteristicId: "",
          listenOnControl: false,
          hasFeatureFlags: true,
          flagByteSize: 1,
          heartRateByteIndex: -1,
          timeMetric: ShortMetricDescriptor(lsb: 0, msb: 0), // dummy
          caloriesMetric: ShortMetricDescriptor(lsb: 0, msb: 0), // dummy
          speedMetric: ShortMetricDescriptor(lsb: 0, msb: 0), // dummy
          powerMetric: ShortMetricDescriptor(lsb: 0, msb: 0), // dummy
          cadenceMetric: ShortMetricDescriptor(lsb: 0, msb: 0), // dummy
          distanceMetric: ThreeByteMetricDescriptor(lsb: 0, msb: 0), // dummy
        );

  @override
  void processFlag(int flag) {
    // Empty implementation, hard coded layouts overlook flags
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    final dataString = utf8.decode(data);
    final dataParts = dataString.split(";");
    return RecordWithSport(
      distance: double.tryParse(dataParts[9]),
      elapsed: int.tryParse(dataParts[22]),
      power: int.tryParse(dataParts[21]),
      speed: double.tryParse(dataParts[11]) ?? 0.0 * DeviceDescriptor.ms2kmh,
      cadence: int.tryParse(dataParts[13]),
      sport: sport,
    );
  }

  @override
  KayakFirstDescriptor clone() => KayakFirstDescriptor();

  int separatorCount(List<int> data) {
    return data
        .map((element) => element == separator ? 1 : 0)
        .reduce((value, element) => value + element);
  }

  @override
  bool isDataProcessable(List<int> data) {
    if (data.isEmpty) return false;

    if (data[0] != dataStreamFlag) return false;

    final isClosed = data.length >= 2 && data.last == 0x0A && data[data.length - 2] == 0x0D;
    final sepCount = separatorCount(data);
    return isClosed && sepCount == 23;
  }

  @override
  bool isClosingPacket(List<int> data) {
    return data.length >= 2 && data.last == 0x0A && data[data.length - 2] == 0x0D;
  }

  @override
  bool isFlagValid(int flag) {
    return true; // flag == dataStreamFlag;
  }

  @override
  void stopWorkout() {}

  Future<void> _executeControlOperationCore(
      BluetoothCharacteristic controlPoint, String command, int logLevel) async {
    if (!command.endsWith("\r\n")) {
      command += "\r\n";
    }

    try {
      await controlPoint.write(utf8.encode(command));
      // Response could be picked up in the subscription listener
    } on PlatformException catch (e, stack) {
      Logging.log(
        logLevel,
        logLevelError,
        "KayakFirst",
        "_executeControlOperationCore",
        "${e.message}",
      );
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }
  }

  @override
  Future<void> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    Logging.log(
      logLevel,
      logLevelError,
      "KayakFirst",
      "executeControlOperation",
      "$opCode",
    );

    if (!await FlutterBluePlus.instance.isOn || controlPoint == null || opCode == requestControl) {
      return;
    }

    var command = "";
    switch (opCode) {
      case startOrResumeControl:
        command = startCommand;
        break;
      case stopOrPauseControl:
        command = stopCommand;
        break;
      default:
        break;
    }

    if (command.isEmpty && opCode != resetControl) {
      return;
    }

    if (opCode == startOrResumeControl || opCode == resetControl) {
      await _executeControlOperationCore(controlPoint, reset1Command, logLevel);
      final reset1Return = await controlPoint.read();
      debugPrint("Reset1 return: ${utf8.decode(reset1Return)}");
      await _executeControlOperationCore(controlPoint, reset2Command, logLevel);
      final reset2Return = await controlPoint.read();
      debugPrint("Reset2 return: ${utf8.decode(reset2Return)}");
    }

    if (opCode == resetControl) {
      return;
    }

    await _executeControlOperationCore(controlPoint, command, logLevel);
  }

  @override
  Future<void> pollMeasurement(BluetoothCharacteristic controlPoint, int logLevel) async {
    await _executeControlOperationCore(controlPoint, pollDataCommand, logLevel);
  }
}
