import 'package:isar/isar.dart';

part 'power_tune.g.dart';

@Collection(inheritance: false)
class PowerTune {
  Id id;
  @Index()
  final String mac;
  double powerFactor;
  @Index()
  DateTime time;

  PowerTune({
    this.id = Isar.autoIncrement,
    required this.mac,
    required this.powerFactor,
    required this.time,
  });
}
