import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/models/record.dart';
import '../../preferences/athlete_body_weight.dart';
import '../../preferences/block_signal_start_stop.dart';
import '../../preferences/kayak_first_display_configuration.dart';
import '../../preferences/log_level.dart';
import '../../utils/constants.dart';
import '../../utils/delays.dart';
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
  static const resetCommand = "1";
  static const handshakeCommand = "2";
  static const newHandshakeCommand = "${handshakeCommand}1";
  static const configurationCommand = "3";
  static const displayConfigurationCommand = "5";
  static const pollDataCommand = "6";
  static const parametersCommand = "8";
  static const startCommand = "9;1";
  static const stopCommand = "9;3";
  static const crLf = "\r\n";
  static const responseChunkSize = 20;
  static const boatWeightDefault = 12;

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
    return data.isNotEmpty;
  }

  @override
  bool isClosingPacket(List<int> data) {
    return data.length >= 2 && data.last == 0x0A && data[data.length - 2] == 0x0D ||
        data.length < responseChunkSize;
  }

  @override
  bool isFlagValid(int flag) {
    return flag == dataStreamFlag;
  }

  @override
  void stopWorkout() {}

  Future<void> _executeControlOperationCore(
      BluetoothCharacteristic controlPoint, String command, int logLevel) async {
    if (!command.endsWith(crLf)) {
      command += crLf;
    }

    Logging.log(
      logLevel,
      logLevelInfo,
      "KayakFirst",
      "_executeControlOperationCore command",
      command,
    );

    try {
      await controlPoint.write(utf8.encode(command));
      // Response could be picked up in the subscription listener
    } on PlatformException catch (e, stack) {
      Logging.logException(
        logLevel,
        "KayakFirst",
        "_executeControlOperationCore",
        "${e.message}",
        e,
        stack,
      );
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
      case resetControl:
        command = resetCommand;
        break;
      case startOrResumeControl:
        command = startCommand;
        break;
      case stopOrPauseControl:
        command = stopCommand;
        break;
      default:
        break;
    }

    if (command.isEmpty) {
      return;
    }

    await _executeControlOperationCore(controlPoint, command, logLevel);
  }

  @override
  Future<void> pollMeasurement(BluetoothCharacteristic controlPoint, int logLevel) async {
    await _executeControlOperationCore(controlPoint, pollDataCommand, logLevel);
  }

  Future<void> handshake(BluetoothCharacteristic? controlPoint, bool isNew, int logLevel) async {
    if (!await FlutterBluePlus.instance.isOn || controlPoint == null) {
      return;
    }

    final prefService = Get.find<BasePrefService>();
    final athleteWeight = prefService.get<int>(athleteBodyWeightIntTag) ?? athleteBodyWeightDefault;
    final now = DateTime.now();
    final unixEpoch = now.millisecondsSinceEpoch ~/ 1000;
    final timeZoneOffset = now.timeZoneOffset.inMinutes;
    String commandPrefix = isNew ? newHandshakeCommand : handshakeCommand;
    String fullCommand = "$commandPrefix;$unixEpoch;$timeZoneOffset;$athleteWeight;";

    if (commandPrefix == handshakeCommand) {
      fullCommand += sport == ActivityType.kayaking ? "1" : "2";
    } else {
      fullCommand += boatWeightDefault.toString();
    }

    await _executeControlOperationCore(controlPoint, fullCommand, logLevel);
  }

  Future<void> configureDisplay(BluetoothCharacteristic? controlPoint, int logLevel) async {
    if (!await FlutterBluePlus.instance.isOn || controlPoint == null) {
      return;
    }

    String command = displayConfigurationCommand;
    final prefService = Get.find<BasePrefService>();

    for (final displaySlot in kayakFirstDisplaySlots) {
      final slotChoice = prefService.get<int>(displaySlot.item2) ?? displaySlot.item4;
      command += ";$slotChoice";
    }

    await _executeControlOperationCore(controlPoint, command, logLevel);
  }

  @override
  Future<void> postPumpStart(BluetoothCharacteristic? controlPoint, int logLevel) async {
    if (!await FlutterBluePlus.instance.isOn || controlPoint == null) {
      return;
    }

    const smallDelay = Duration(milliseconds: uiIntermittentDelay);
    await Future.delayed(smallDelay);
    final prefService = Get.find<BasePrefService>();
    final blockSignalStartStop =
        testing || (prefService.get<bool>(blockSignalStartStopTag) ?? blockSignalStartStopDefault);
    // 1. Reset
    await executeControlOperation(controlPoint, blockSignalStartStop, logLevel, resetControl);
    await Future.delayed(smallDelay);
    // 2. Handshake
    await handshake(controlPoint, false, logLevel);
    await Future.delayed(smallDelay);
    // 3. Display Configuration
    await configureDisplay(controlPoint, logLevel);
    await Future.delayed(smallDelay);
  }
}
