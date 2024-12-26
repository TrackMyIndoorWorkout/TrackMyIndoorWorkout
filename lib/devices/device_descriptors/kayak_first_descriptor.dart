import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:pref/pref.dart';

import '../../export/fit/fit_manufacturer.dart';
import '../../persistence/record.dart';
import '../../preferences/athlete_body_weight.dart';
import '../../preferences/block_signal_start_stop.dart';
import '../../preferences/kayak_first_display_configuration.dart';
import '../../preferences/log_level.dart';
import '../../ui/models/progress_state.dart';
import '../../ui/parts/pre_measurement_progress.dart';
import '../../utils/constants.dart';
import '../../utils/logging.dart';
import '../device_fourcc.dart';
import '../gatt/ftms.dart';
import '../gatt/kayak_first.dart';
import '../metric_descriptors/short_metric_descriptor.dart';
import '../metric_descriptors/three_byte_metric_descriptor.dart';
import 'device_descriptor.dart';

class KayakFirstDescriptor extends DeviceDescriptor {
  static const mtuSize = 20;
  static const dataStreamFlag = 0x36; // ASCII 6
  static const separator = 0x3B; // ASCII ;
  static const resetCommand = "1";
  static const resetByte = 0x31;
  static const handshakeCommand = "2";
  static const handshakeByte = 0x32;
  static const newHandshakeCommand = "${handshakeCommand}1";
  static const configurationCommand = "3";
  static const configurationByte = 0x33;
  static const displayConfigurationCommand = "5";
  static const displayConfigurationByte = 0x35;
  static const pollDataCommand = "6";
  static const parametersCommand = "8";
  static const startCommand = "9;1";
  static const stopCommand = "9;3";
  static const startStopByte = 0x39;
  static const crLf = "\r\n";
  static const boatWeightDefault = 12;
  static const responseQueueSize = 10;
  static const responseWatchDelayMs = 50; // ms
  static const responseWatchDelay = Duration(milliseconds: responseWatchDelayMs);
  static const responseWatchTimeoutMs = 3000; // ms
  static const responseWatchTimeoutGuard = Duration(milliseconds: responseWatchTimeoutMs + 250);
  static const commandShortDelayMs = 500; // ms
  static const commandShortDelay = Duration(milliseconds: commandShortDelayMs);
  static const commandLongDelayMs = 1000; // ms
  static const commandLongDelay = Duration(milliseconds: commandLongDelayMs);
  static const commandExtraLongDelayMs = 5000; // ms
  static const commandExtraLongDelay = Duration(milliseconds: commandExtraLongDelayMs);
  static const commandExtraLongTimeoutGuard = Duration(milliseconds: commandExtraLongDelayMs + 250);
  static const progressBarCompletionTime = 6000; // ms
  static const maxWaitIterations = 3;
  static const List<int> validFlags = [
    resetByte + 0x0D * 256,
    resetByte + separator * 256,
    resetByte + 1 * 256,
    handshakeByte + separator * 256,
    configurationByte + separator * 256,
    displayConfigurationByte + separator * 256,
    dataStreamFlag + separator * 256,
    startStopByte + separator * 256
  ];
  ListQueue<int> responses = ListQueue<int>();
  List<int> currentResponses = [];
  bool initializedConsole = false;

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
          tag: "KAYAK_FIRST_DESCRIPTOR",
          isPolling: true,
          fragmentedPackets: true,
          dataServiceId: kayakFirstServiceUuid,
          dataCharacteristicId: kayakFirstAllAroundUuid,
          controlCharacteristicId: "",
          statusCharacteristicId: "",
          listenOnControl: false,
          hasFeatureFlags: true,
          flagByteSize: 2,
          heartRateByteIndex: -1,
          timeMetric: ShortMetricDescriptor(lsb: 0, msb: 0), // dummy
          caloriesMetric: ShortMetricDescriptor(lsb: 0, msb: 0), // dummy
          speedMetric: ShortMetricDescriptor(lsb: 0, msb: 0), // dummy
          powerMetric: ShortMetricDescriptor(lsb: 0, msb: 0), // dummy
          cadenceMetric: ShortMetricDescriptor(lsb: 0, msb: 0), // dummy
          distanceMetric: ThreeByteMetricDescriptor(lsb: 0, msb: 0), // dummy
        ) {
    responses.add(separator);
  }

  @override
  void processFlag(int flag, int dataLength) {
    // Empty implementation, hard coded layouts overlook flags
  }

  @override
  RecordWithSport? stubRecord(List<int> data) {
    if (data[0] != dataStreamFlag) {
      return null;
    }

    final dataString = utf8.decode(data);
    final dataParts = dataString.split(";");
    if (dataParts.length < 24) {
      debugPrint("Partial fragment");
      return null;
    }

    return RecordWithSport(
      distance: double.tryParse(dataParts.elementAtOrNull(9) ?? ""),
      elapsed: int.tryParse(dataParts.elementAtOrNull(22) ?? ""),
      power: int.tryParse(dataParts.elementAtOrNull(21) ?? ""),
      speed:
          (double.tryParse(dataParts.elementAtOrNull(11) ?? "") ?? 0.0) * DeviceDescriptor.ms2kmh,
      cadence: int.tryParse(dataParts.elementAtOrNull(13) ?? ""),
      sport: sport,
    );
  }

  @override
  KayakFirstDescriptor clone() => KayakFirstDescriptor();

  @override
  bool isDataProcessable(List<int> data) {
    return data.isNotEmpty;
  }

  @override
  bool isWholePacket(List<int> data) {
    return data.length >= 2 && data.last == 0x0A && data[data.length - 2] == 0x0D ||
        data.length == 2 && data.first == resetByte && data.last == 1;
  }

  @override
  bool skipPacket(List<int> data) {
    return data.length == 3 &&
            data.first == dataStreamFlag &&
            data.last == 0x0A &&
            data[1] == 0x0D ||
        data.isNotEmpty && data.map((e) => e == 0 || e == 1).every((p) => p);
  }

  @override
  bool isFlagValid(int flag) {
    return validFlags.contains(flag);
  }

  @override
  void stopWorkout() {}

  Future<bool> _executeControlOperationCore(
      BluetoothCharacteristic controlPoint, String command, int logLevel) async {
    if (!command.endsWith(crLf)) {
      command += crLf;
    }

    Logging().log(logLevel, logLevelInfo, tag, "_executeControlOperationCore command", command);

    final commandBytes = utf8.encode(command);
    int chunkBeginning = 0;
    int retryCount = 0;
    while (chunkBeginning < commandBytes.length && retryCount <= maxWaitIterations) {
      try {
        final chunk = commandBytes.skip(chunkBeginning).take(mtuSize).toList(growable: false);
        await controlPoint.write(chunk);
        // Response could be picked up in the subscription listener
        chunkBeginning += mtuSize;
        retryCount = 0;
      } on Exception catch (e, stack) {
        retryCount += 1;
        Logging().logException(
            logLevel, tag, "_executeControlOperationCore", "controlPoint.write", e, stack);
        await Future.delayed(responseWatchDelay);
      }
    }

    return retryCount <= maxWaitIterations;
  }

  @override
  Future<bool> executeControlOperation(
      BluetoothCharacteristic? controlPoint, bool blockSignalStartStop, int logLevel, int opCode,
      {int? controlInfo}) async {
    Logging().log(logLevel, logLevelInfo, tag, "executeControlOperation", "$opCode");

    if (controlPoint == null || opCode == requestControl) {
      return false;
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
      return false;
    }

    return await _executeControlOperationCore(controlPoint, command, logLevel);
  }

  @override
  Future<bool> pollMeasurement(BluetoothCharacteristic controlPoint, int logLevel) async {
    return await _executeControlOperationCore(controlPoint, pollDataCommand, logLevel);
  }

  Future<bool> handshake(BluetoothCharacteristic? controlPoint, bool isNew, int logLevel) async {
    if (controlPoint == null) {
      return false;
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

    return await _executeControlOperationCore(controlPoint, fullCommand, logLevel);
  }

  Future<bool> configureDisplay(BluetoothCharacteristic? controlPoint, int logLevel) async {
    if (controlPoint == null || initializedConsole) {
      return false;
    }

    String command = displayConfigurationCommand;
    final prefService = Get.find<BasePrefService>();

    for (final displaySlot in kayakFirstDisplaySlots) {
      final slotChoice = prefService.get<int>(displaySlot.item2) ?? displaySlot.item4;
      command += ";$slotChoice";
    }

    return await _executeControlOperationCore(controlPoint, command, logLevel);
  }

  @override
  Future<void> postPumpStart(BluetoothCharacteristic? controlPoint, int logLevel) async {
    if (controlPoint == null) {
      return;
    }

    progressBottomSheet("Initializing 1...", progressBarCompletionTime);
    await Future.delayed(responseWatchDelay);
    final prefService = Get.find<BasePrefService>();
    final blockSignalStartStop =
        testing || (prefService.get<bool>(blockSignalStartStopTag) ?? blockSignalStartStopDefault);
    // 1.1 Reset
    bool seenIt = false;
    int iterationCount = 0;
    currentResponses.clear();
    while (!seenIt && iterationCount < maxWaitIterations) {
      await executeControlOperation(controlPoint, blockSignalStartStop, logLevel, resetControl);
      seenIt = await _waitForResponse(resetByte, commandExtraLongDelayMs, logLevel, true)
          .timeout(responseWatchTimeoutGuard, onTimeout: () => false);
      await Future.delayed(commandLongDelay);
      iterationCount++;
    }

    await Future.delayed(commandLongDelay);
    ProgressState.optionallyCloseProgress();
    await Future.delayed(responseWatchDelay);
    // 1.2 Reset
    seenIt = false;
    iterationCount = 0;
    currentResponses.clear();
    progressBottomSheet("Initializing 2...", progressBarCompletionTime);
    while (!seenIt && iterationCount < maxWaitIterations) {
      await executeControlOperation(controlPoint, blockSignalStartStop, logLevel, resetControl);
      seenIt = await _waitForResponse(resetByte, commandExtraLongDelayMs, logLevel, true)
          .timeout(responseWatchTimeoutGuard, onTimeout: () => false);
      await Future.delayed(commandLongDelay);
      iterationCount++;
    }

    await Future.delayed(commandExtraLongDelay);
    ProgressState.optionallyCloseProgress();
    await Future.delayed(responseWatchDelay);
    // 2. Handshake
    seenIt = false;
    iterationCount = 0;
    currentResponses.clear();
    progressBottomSheet("Handshake...", progressBarCompletionTime);
    while (!seenIt && iterationCount < maxWaitIterations) {
      await handshake(controlPoint, false, logLevel);
      seenIt = await _waitForResponse(handshakeByte, commandExtraLongDelayMs, logLevel, true)
          .timeout(responseWatchTimeoutGuard, onTimeout: () => false);
      await Future.delayed(commandLongDelay);
      iterationCount++;
    }

    await Future.delayed(commandExtraLongDelay);
    ProgressState.optionallyCloseProgress();
    await Future.delayed(responseWatchDelay);
    // 3. Display Configuration
    seenIt = false;
    iterationCount = 0;
    currentResponses.clear();
    progressBottomSheet("Configuration...", progressBarCompletionTime);
    while (!seenIt && iterationCount < maxWaitIterations) {
      await configureDisplay(controlPoint, logLevel);
      seenIt =
          await _waitForResponse(displayConfigurationByte, commandExtraLongDelayMs, logLevel, true)
              .timeout(commandExtraLongTimeoutGuard, onTimeout: () => false);
      await Future.delayed(commandLongDelay);
      iterationCount++;
    }

    await Future.delayed(commandExtraLongDelay);
    ProgressState.optionallyCloseProgress();
    await Future.delayed(responseWatchDelay);
    initializedConsole = true;
  }

  Future<bool> _waitForResponse(int responseByte, int timeout, int logLevel, bool withEcho) async {
    final iterationCount = timeout ~/ responseWatchDelayMs;
    int i = 0;
    bool seenEcho = !withEcho;
    if (withEcho) {
      for (; i < iterationCount && !currentResponses.contains(responseByte); i++) {
        await Future.delayed(responseWatchDelay);
      }

      final seenEcho = currentResponses.contains(responseByte);
      Logging().log(logLevel, logLevelInfo, tag, "_waitForResponse echo", "$seenEcho");

      currentResponses.clear();
    }

    i = 0;
    for (; i < iterationCount && !currentResponses.contains(responseByte); i++) {
      await Future.delayed(responseWatchDelay);
    }

    final seenIt = currentResponses.contains(responseByte);
    Logging().log(logLevel, logLevelInfo, tag, "_waitForResponse", "$seenIt");
    return seenIt || seenEcho;
  }

  @override
  void registerResponse(int key, int logLevel) {
    currentResponses.add(key);

    if (responses.last != key) {
      responses.add(key);

      if (responses.length > responseQueueSize) {
        responses.removeFirst();
      }

      Logging().log(logLevel, logLevelInfo, tag, "registerResponse", "$responses");
    }
  }
}
