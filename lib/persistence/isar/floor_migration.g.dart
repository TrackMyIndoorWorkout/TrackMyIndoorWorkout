// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'floor_migration.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFloorMigrationCollection on Isar {
  IsarCollection<FloorMigration> get floorMigrations => this.collection();
}

const FloorMigrationSchema = CollectionSchema(
  name: r'FloorMigration',
  id: -4687933030746928507,
  properties: {
    r'entityName': PropertySchema(
      id: 0,
      name: r'entityName',
      type: IsarType.string,
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
  estimateSize: _floorMigrationEstimateSize,
  serialize: _floorMigrationSerialize,
  deserialize: _floorMigrationDeserialize,
  deserializeProp: _floorMigrationDeserializeProp,
  idName: r'id',
  indexes: {
    r'entityName': IndexSchema(
      id: -1749110902930819992,
      name: r'entityName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entityName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _floorMigrationGetId,
  getLinks: _floorMigrationGetLinks,
  attach: _floorMigrationAttach,
  version: '3.1.0+1',
);

int _floorMigrationEstimateSize(
  FloorMigration object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entityName.length * 3;
  return bytesCount;
}

void _floorMigrationSerialize(
  FloorMigration object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.entityName);
  writer.writeLong(offsets[1], object.floorId);
  writer.writeLong(offsets[2], object.isarId);
}

FloorMigration _floorMigrationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FloorMigration(
    entityName: reader.readString(offsets[0]),
    floorId: reader.readLong(offsets[1]),
    id: id,
    isarId: reader.readLong(offsets[2]),
  );
  return object;
}

P _floorMigrationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _floorMigrationGetId(FloorMigration object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _floorMigrationGetLinks(FloorMigration object) {
  return [];
}

void _floorMigrationAttach(IsarCollection<dynamic> col, Id id, FloorMigration object) {
  object.id = id;
}

extension FloorMigrationQueryWhereSort on QueryBuilder<FloorMigration, FloorMigration, QWhere> {
  QueryBuilder<FloorMigration, FloorMigration, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FloorMigrationQueryWhere on QueryBuilder<FloorMigration, FloorMigration, QWhereClause> {
  QueryBuilder<FloorMigration, FloorMigration, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<FloorMigration, FloorMigration, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterWhereClause> idBetween(
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

  QueryBuilder<FloorMigration, FloorMigration, QAfterWhereClause> entityNameEqualTo(
      String entityName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entityName',
        value: [entityName],
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterWhereClause> entityNameNotEqualTo(
      String entityName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityName',
              lower: [],
              upper: [entityName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityName',
              lower: [entityName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityName',
              lower: [entityName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityName',
              lower: [],
              upper: [entityName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension FloorMigrationQueryFilter
    on QueryBuilder<FloorMigration, FloorMigration, QFilterCondition> {
  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> entityNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> entityNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> entityNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> entityNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> entityNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> entityNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> entityNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> entityNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> entityNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityName',
        value: '',
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> entityNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityName',
        value: '',
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> floorIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'floorId',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> floorIdGreaterThan(
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

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> floorIdLessThan(
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

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> floorIdBetween(
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

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> isarIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<FloorMigration, FloorMigration, QAfterFilterCondition> isarIdBetween(
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

extension FloorMigrationQueryObject
    on QueryBuilder<FloorMigration, FloorMigration, QFilterCondition> {}

extension FloorMigrationQueryLinks
    on QueryBuilder<FloorMigration, FloorMigration, QFilterCondition> {}

extension FloorMigrationQuerySortBy on QueryBuilder<FloorMigration, FloorMigration, QSortBy> {
  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> sortByEntityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.asc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> sortByEntityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.desc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> sortByFloorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'floorId', Sort.asc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> sortByFloorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'floorId', Sort.desc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> sortByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> sortByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }
}

extension FloorMigrationQuerySortThenBy
    on QueryBuilder<FloorMigration, FloorMigration, QSortThenBy> {
  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> thenByEntityName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.asc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> thenByEntityNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityName', Sort.desc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> thenByFloorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'floorId', Sort.asc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> thenByFloorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'floorId', Sort.desc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }
}

extension FloorMigrationQueryWhereDistinct
    on QueryBuilder<FloorMigration, FloorMigration, QDistinct> {
  QueryBuilder<FloorMigration, FloorMigration, QDistinct> distinctByEntityName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QDistinct> distinctByFloorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'floorId');
    });
  }

  QueryBuilder<FloorMigration, FloorMigration, QDistinct> distinctByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isarId');
    });
  }
}

extension FloorMigrationQueryProperty
    on QueryBuilder<FloorMigration, FloorMigration, QQueryProperty> {
  QueryBuilder<FloorMigration, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FloorMigration, String, QQueryOperations> entityNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityName');
    });
  }

  QueryBuilder<FloorMigration, int, QQueryOperations> floorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'floorId');
    });
  }

  QueryBuilder<FloorMigration, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }
}
