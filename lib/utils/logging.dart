import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';

import '../persistence/log_entry.dart';
import '../preferences/log_level.dart';
import '../utils/constants.dart';

class Logging {
  static Map<int, String> levelToDescription = {
    logLevelNone: logLevelNoneDescription,
    logLevelError: logLevelErrorDescription,
    logLevelWarning: logLevelWarningDescription,
    logLevelInfo: logLevelInfoDescription,
  };

  static LogEntry? lastEntry;
  static int lastEntryId = -1;

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
    final level = levelToDescription[logLevel] ?? "UNK";
    // Check last entry if it's identical to prevent flooding
    if (lastEntry != null &&
        lastEntryId > 0 &&
        lastEntry?.level == level &&
        lastEntry?.tag == tag &&
        lastEntry?.subTag == subTag &&
        lastEntry?.message == message) {
      lastEntry = database.logEntrys.getSync(lastEntryId);
      if (lastEntry != null) {
        lastEntry?.incrementCounter();
        database.writeTxnSync(() {
          lastEntryId = database.logEntrys.putSync(lastEntry!);
        });
        return;
      }
    }

    lastEntry = LogEntry(
      timeStamp: DateTime.now(),
      level: level,
      tag: tag,
      subTag: subTag,
      message: message,
    );
    database.writeTxnSync(() {
      lastEntryId = database.logEntrys.putSync(lastEntry!);
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

  Future<void> exportLogs(File logFile) async {
    await logFile.writeAsString("timeStamp,level,tag,subTag,message\n", mode: FileMode.write);
    for (final logEntry in await database.logEntrys.where().sortByTimeStamp().findAll()) {
      await logFile.writeAsString(
        "${logEntry.timeStamp},${logEntry.level},${logEntry.tag},${logEntry.subTag},${logEntry.message}\n",
        mode: FileMode.append,
      );
    }

    await logFile.writeAsString("\n", mode: FileMode.append, flush: true);
  }
}
