import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import '../persistence/isar/log_entry.dart';
import '../preferences/log_level.dart';
import '../utils/constants.dart';

class Logging {
  static Map<int, String> levelToDescription = {
    logLevelNone: logLevelNoneDescription,
    logLevelError: logLevelErrorDescription,
    logLevelWarning: logLevelWarningDescription,
    logLevelInfo: logLevelInfoDescription,
  };

  late final Isar database;

  Logging() {
    database = Get.find<Isar>();
  }

  void log(
    int logLevelThreshold,
    int logLevel,
    String tag,
    String subTag,
    String message,
  ) {
    if (kDebugMode) {
      debugPrint("$tag | $subTag | $message");
    }

    if (logLevelThreshold == logLevelNone || testing) {
      return;
    }

    if (logLevelThreshold >= logLevelInfo && logLevel >= logLevelInfo) {
      _logCore(logLevelInfo, tag, subTag, message);
    } else if (logLevelThreshold >= logLevelWarning && logLevel >= logLevelWarning) {
      _logCore(logLevelWarning, tag, subTag, message);
    } else {
      _logCore(logLevelError, tag, subTag, message);
    }
  }

  void logException(
    int logLevelThreshold,
    String tag,
    String subTag,
    String message,
    Exception e,
    StackTrace stack,
  ) {
    if (kDebugMode) {
      debugPrint("$e");
      debugPrintStack(stackTrace: stack, label: "trace:");
    }

    if (logLevelThreshold == logLevelNone) {
      return;
    }

    _logCore(logLevelError, tag, subTag, "$message; $e; $stack");
  }

  void _logCore(
    int logLevel,
    String tag,
    String subTag,
    String message,
  ) {
    database.writeTxnSync(() {
      database.logEntrys.putSync(
        LogEntry(
          timeStamp: DateTime.now(),
          level: levelToDescription[logLevel] ?? "UNK",
          tag: tag,
          subTag: subTag,
          message: message,
        ),
      );
    });
  }

  void logVersion(PackageInfo packageInfo) {
    log(
      Get.find<BasePrefService>().get<int>(logLevelTag) ?? logLevelDefault,
      logLevelError,
      "logVersion",
      "version",
      "${packageInfo.version} build ${packageInfo.buildNumber}",
    );
  }

  bool hasLogs() {
    return database.logEntrys.countSync() > 0;
  }

  void clearLogs() {
    database.writeTxnSync(() {
      database.logEntrys.clearSync();
    });
  }

  Future<List<int>> exportLogs() async {
    final sb = StringBuffer();

    sb.writeln("timeStamp,level,tag,subTag,message");
    for (final logEntry in await database.logEntrys.where().sortByTimeStamp().findAll()) {
      sb.writeln(
          "${logEntry.timeStamp},${logEntry.level},${logEntry.tag},${logEntry.subTag},${logEntry.message}");
    }

    return GZipCodec(gzip: true).encode(utf8.encode(sb.toString()));
  }
}
