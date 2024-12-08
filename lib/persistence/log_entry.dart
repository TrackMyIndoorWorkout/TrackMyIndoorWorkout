import 'package:isar/isar.dart';

part 'log_entry.g.dart';

@Collection(inheritance: false)
class LogEntry {
  Id id;
  @Index()
  final DateTime timeStamp;
  final String level;
  final String tag;
  final String subTag;
  final String message;
  int counter;

  LogEntry({
    this.id = Isar.autoIncrement,
    required this.timeStamp,
    required this.level,
    required this.tag,
    required this.subTag,
    required this.message,
    this.counter = 0,
  });

  void incrementCounter() {
    counter += 1;
  }
}
