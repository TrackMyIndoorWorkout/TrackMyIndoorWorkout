import 'package:isar/isar.dart';

part 'calorie_tune.g.dart';

@Collection(inheritance: false)
class CalorieTune {
  Id id;
  @Index()
  final String mac;
  double calorieFactor;
  bool hrBased;
  int time; // ms since epoch

  CalorieTune({
    this.id = Isar.autoIncrement,
    required this.mac,
    required this.calorieFactor,
    required this.hrBased,
    required this.time,
  });

  DateTime get timeStamp => DateTime.fromMillisecondsSinceEpoch(time);
}
