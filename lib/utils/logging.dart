import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_logs/flutter_logs.dart';
import '../preferences/log_level.dart';

class Logging {
  static bool initialized = false;
  static String fileName = "DebugLog";
  static Completer completer = Completer<String>();

  static Future<void> init(int logLevelThreshold) async {
    if (initialized) {
      return;
    }

    initialized = true;
    // We don't want to debug FlutterLogs itself
    // the system default is 2 (=all). 0 means none
    if (!kDebugMode) {
      FlutterLogs.setDebugLevel(0);
    }

    final List<LogLevel> logLevels = logLevelThreshold == logLevelNone
        ? []
        : [LogLevel.INFO, LogLevel.WARNING, LogLevel.ERROR, LogLevel.SEVERE];
    await FlutterLogs.initLogs(
      logLevelsEnabled: logLevels,
      timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
      directoryStructure: DirectoryStructure.FOR_DATE,
      logTypesEnabled: [fileName],
      logFileExtension: LogFileExtension.TXT,
      logsWriteDirectoryName: "Logs",
      logsExportDirectoryName: "Exported",
      logsExportZipFileName: "LogExport",
      debugFileOperations: kDebugMode,
      isDebuggable: kDebugMode,
    );

    FlutterLogs.channel.setMethodCallHandler((call) async {
      if (call.method == "logsExported") {
        completer.complete(call.arguments.toString());
      }
    });
  }

  static void log(
    int logLevelThreshold,
    int logLevel,
    String tag,
    String subTag,
    String logMessage,
  ) {
    if (!initialized || logLevelThreshold == logLevelNone) {
      return;
    }

    if (logLevelThreshold >= logLevelInfo && logLevel >= logLevelInfo) {
      FlutterLogs.logInfo(tag, subTag, logMessage);
    } else if (logLevelThreshold >= logLevelWarning && logLevel >= logLevelWarning) {
      FlutterLogs.logWarn(tag, subTag, logMessage);
    } else {
      FlutterLogs.logError(tag, subTag, logMessage);
    }
  }

  static void logException(
    int logLevelThreshold,
    String tag,
    String subTag,
    String logMessage,
    Exception e,
    StackTrace stack,
  ) {
    if (!initialized || logLevelThreshold == logLevelNone) {
      return;
    }

    FlutterLogs.logError(tag, subTag, "$logMessage; $e; $stack");
  }
}
