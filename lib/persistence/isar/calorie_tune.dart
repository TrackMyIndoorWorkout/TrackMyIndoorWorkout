import 'package:isar/isar.dart';

part 'calorie_tune.g.dart';

@Collection(inheritance: false)
class CalorieTune {
  Id id;
  @Index()
  final String mac;
  double calorieFactor;
  bool hrBased;
  @Index()
  DateTime time;

  CalorieTune({
    this.id = Isar.autoIncrement,
    required this.mac,
    required this.calorieFactor,
    required this.hrBased,
    required this.time,
  });
}
