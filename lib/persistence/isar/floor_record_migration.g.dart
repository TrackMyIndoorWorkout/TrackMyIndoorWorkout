// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floor_record_migration.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFloorRecordMigrationCollection on Isar {
  IsarCollection<FloorRecordMigration> get floorRecordMigrations => this.collection();
}

const FloorRecordMigrationSchema = CollectionSchema(
  name: r'FloorRecordMigration',
  id: 6360508109021040471,
  properties: {
    r'activityId': PropertySchema(
      id: 0,
      name: r'activityId',
      type: IsarType.long,
    ),
    r'floorId': PropertySchema(
      id: 1,
      name: r'floorId',
      type: IsarType.long,
    ),
    r'isarId': PropertySchema(
      id: 2,
      name: r'isarId',
      type: IsarType.long,
    )
  },
  estimateSize: _floorRecordMigrationEstimateSize,
  serialize: _floorRecordMigrationSerialize,
  deserialize: _floorRecordMigrationDeserialize,
  deserializeProp: _floorRecordMigrationDeserializeProp,
  idName: r'id',
  indexes: {
    r'activityId': IndexSchema(
      id: 8968520805042838249,
      name: r'activityId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'activityId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _floorRecordMigrationGetId,
  getLinks: _floorRecordMigrationGetLinks,
  attach: _floorRecordMigrationAttach,
  version: '3.1.8',
);

int _floorRecordMigrationEstimateSize(
  FloorRecordMigration object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _floorRecordMigrationSerialize(
  FloorRecordMigration object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.activityId);
  writer.writeLong(offsets[1], object.floorId);
  writer.writeLong(offsets[2], object.isarId);
}

FloorRecordMigration _floorRecordMigrationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FloorRecordMigration(
    activityId: reader.readLong(offsets[0]),
    floorId: reader.readLong(offsets[1]),
    id: id,
    isarId: reader.readLong(offsets[2]),
  );
  return object;
}

P _floorRecordMigrationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _floorRecordMigrationGetId(FloorRecordMigration object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _floorRecordMigrationGetLinks(FloorRecordMigration object) {
  return [];
}

void _floorRecordMigrationAttach(IsarCollection<dynamic> col, Id id, FloorRecordMigration object) {
  object.id = id;
}

extension FloorRecordMigrationQueryWhereSort
    on QueryBuilder<FloorRecordMigration, FloorRecordMigration, QWhere> {
  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhere> anyActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'activityId'),
      );
    });
  }
}

extension FloorRecordMigrationQueryWhere
    on QueryBuilder<FloorRecordMigration, FloorRecordMigration, QWhereClause> {
  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhereClause> activityIdEqualTo(
      int activityId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'activityId',
        value: [activityId],
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhereClause> activityIdNotEqualTo(
      int activityId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityId',
              lower: [],
              upper: [activityId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityId',
              lower: [activityId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityId',
              lower: [activityId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'activityId',
              lower: [],
              upper: [activityId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhereClause> activityIdGreaterThan(
    int activityId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activityId',
        lower: [activityId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhereClause> activityIdLessThan(
    int activityId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activityId',
        lower: [],
        upper: [activityId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterWhereClause> activityIdBetween(
    int lowerActivityId,
    int upperActivityId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'activityId',
        lower: [lowerActivityId],
        includeLower: includeLower,
        upper: [upperActivityId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FloorRecordMigrationQueryFilter
    on QueryBuilder<FloorRecordMigration, FloorRecordMigration, QFilterCondition> {
  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> activityIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityId',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition>
      activityIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityId',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition>
      activityIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityId',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> activityIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> floorIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'floorId',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition>
      floorIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'floorId',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> floorIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'floorId',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> floorIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'floorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> isarIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> isarIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> isarIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterFilterCondition> isarIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FloorRecordMigrationQueryObject
    on QueryBuilder<FloorRecordMigration, FloorRecordMigration, QFilterCondition> {}

extension FloorRecordMigrationQueryLinks
    on QueryBuilder<FloorRecordMigration, FloorRecordMigration, QFilterCondition> {}

extension FloorRecordMigrationQuerySortBy
    on QueryBuilder<FloorRecordMigration, FloorRecordMigration, QSortBy> {
  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> sortByActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.asc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> sortByActivityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.desc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> sortByFloorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'floorId', Sort.asc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> sortByFloorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'floorId', Sort.desc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> sortByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> sortByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }
}

extension FloorRecordMigrationQuerySortThenBy
    on QueryBuilder<FloorRecordMigration, FloorRecordMigration, QSortThenBy> {
  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> thenByActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.asc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> thenByActivityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityId', Sort.desc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> thenByFloorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'floorId', Sort.asc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> thenByFloorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'floorId', Sort.desc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }
}

extension FloorRecordMigrationQueryWhereDistinct
    on QueryBuilder<FloorRecordMigration, FloorRecordMigration, QDistinct> {
  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QDistinct> distinctByActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityId');
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QDistinct> distinctByFloorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'floorId');
    });
  }

  QueryBuilder<FloorRecordMigration, FloorRecordMigration, QDistinct> distinctByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isarId');
    });
  }
}

extension FloorRecordMigrationQueryProperty
    on QueryBuilder<FloorRecordMigration, FloorRecordMigration, QQueryProperty> {
  QueryBuilder<FloorRecordMigration, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FloorRecordMigration, int, QQueryOperations> activityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityId');
    });
  }

  QueryBuilder<FloorRecordMigration, int, QQueryOperations> floorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'floorId');
    });
  }

  QueryBuilder<FloorRecordMigration, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }
}
