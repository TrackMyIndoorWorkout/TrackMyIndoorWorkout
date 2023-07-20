import 'package:isar/isar.dart';

part 'log_entry.g.dart';

@Collection(inheritance: false)
class LogEntry {
  Id id;
  @Index()
  late final DateTime timeStamp;
  final String level;
  final String tag;
  final String subTag;
  final String message;

  LogEntry({
    this.id = Isar.autoIncrement,
    required this.level,
    required this.tag,
    required this.subTag,
    required this.message,
  }) {
    timeStamp = DateTime.now();
  }
}
