import 'package:isar/isar.dart';

part 'floor_record_migration.g.dart';

@Collection(inheritance: false)
class FloorRecordMigration {
  Id id;
  @Index()
  final int activityId;
  final int floorId;
  final int isarId;

  FloorRecordMigration({
    this.id = Isar.autoIncrement,
    required this.activityId,
    required this.floorId,
    required this.isarId,
  });
}
