// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'power_tune.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPowerTuneCollection on Isar {
  IsarCollection<PowerTune> get powerTunes => this.collection();
}

const PowerTuneSchema = CollectionSchema(
  name: r'PowerTune',
  id: -53467010452562818,
  properties: {
    r'mac': PropertySchema(
      id: 0,
      name: r'mac',
      type: IsarType.string,
    ),
    r'powerFactor': PropertySchema(
      id: 1,
      name: r'powerFactor',
      type: IsarType.double,
    ),
    r'time': PropertySchema(
      id: 2,
      name: r'time',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _powerTuneEstimateSize,
  serialize: _powerTuneSerialize,
  deserialize: _powerTuneDeserialize,
  deserializeProp: _powerTuneDeserializeProp,
  idName: r'id',
  indexes: {
    r'mac': IndexSchema(
      id: 3561895766210558431,
      name: r'mac',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'mac',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'time': IndexSchema(
      id: -2250472054110640942,
      name: r'time',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'time',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _powerTuneGetId,
  getLinks: _powerTuneGetLinks,
  attach: _powerTuneAttach,
  version: '3.1.0+1',
);

int _powerTuneEstimateSize(
  PowerTune object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mac.length * 3;
  return bytesCount;
}

void _powerTuneSerialize(
  PowerTune object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.mac);
  writer.writeDouble(offsets[1], object.powerFactor);
  writer.writeDateTime(offsets[2], object.time);
}

PowerTune _powerTuneDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PowerTune(
    id: id,
    mac: reader.readString(offsets[0]),
    powerFactor: reader.readDouble(offsets[1]),
    time: reader.readDateTime(offsets[2]),
  );
  return object;
}

P _powerTuneDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _powerTuneGetId(PowerTune object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _powerTuneGetLinks(PowerTune object) {
  return [];
}

void _powerTuneAttach(IsarCollection<dynamic> col, Id id, PowerTune object) {
  object.id = id;
}

extension PowerTuneQueryWhereSort on QueryBuilder<PowerTune, PowerTune, QWhere> {
  QueryBuilder<PowerTune, PowerTune, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterWhere> anyTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'time'),
      );
    });
  }
}

extension PowerTuneQueryWhere on QueryBuilder<PowerTune, PowerTune, QWhereClause> {
  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> idBetween(
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

  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> macEqualTo(String mac) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mac',
        value: [mac],
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> macNotEqualTo(String mac) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mac',
              lower: [],
              upper: [mac],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mac',
              lower: [mac],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mac',
              lower: [mac],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mac',
              lower: [],
              upper: [mac],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> timeEqualTo(DateTime time) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'time',
        value: [time],
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> timeNotEqualTo(DateTime time) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'time',
              lower: [],
              upper: [time],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'time',
              lower: [time],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'time',
              lower: [time],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'time',
              lower: [],
              upper: [time],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> timeGreaterThan(
    DateTime time, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'time',
        lower: [time],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> timeLessThan(
    DateTime time, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'time',
        lower: [],
        upper: [time],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterWhereClause> timeBetween(
    DateTime lowerTime,
    DateTime upperTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'time',
        lower: [lowerTime],
        includeLower: includeLower,
        upper: [upperTime],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PowerTuneQueryFilter on QueryBuilder<PowerTune, PowerTune, QFilterCondition> {
  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> macEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mac',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> macGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mac',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> macLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mac',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> macBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mac',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> macStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mac',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> macEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mac',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> macContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mac',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> macMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mac',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> macIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mac',
        value: '',
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> macIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mac',
        value: '',
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> powerFactorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'powerFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> powerFactorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'powerFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> powerFactorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'powerFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> powerFactorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'powerFactor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> timeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> timeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> timeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterFilterCondition> timeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'time',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PowerTuneQueryObject on QueryBuilder<PowerTune, PowerTune, QFilterCondition> {}

extension PowerTuneQueryLinks on QueryBuilder<PowerTune, PowerTune, QFilterCondition> {}

extension PowerTuneQuerySortBy on QueryBuilder<PowerTune, PowerTune, QSortBy> {
  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> sortByMac() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mac', Sort.asc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> sortByMacDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mac', Sort.desc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> sortByPowerFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.asc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> sortByPowerFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.desc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }
}

extension PowerTuneQuerySortThenBy on QueryBuilder<PowerTune, PowerTune, QSortThenBy> {
  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> thenByMac() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mac', Sort.asc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> thenByMacDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mac', Sort.desc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> thenByPowerFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.asc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> thenByPowerFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.desc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QAfterSortBy> thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }
}

extension PowerTuneQueryWhereDistinct on QueryBuilder<PowerTune, PowerTune, QDistinct> {
  QueryBuilder<PowerTune, PowerTune, QDistinct> distinctByMac({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mac', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PowerTune, PowerTune, QDistinct> distinctByPowerFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'powerFactor');
    });
  }

  QueryBuilder<PowerTune, PowerTune, QDistinct> distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }
}

extension PowerTuneQueryProperty on QueryBuilder<PowerTune, PowerTune, QQueryProperty> {
  QueryBuilder<PowerTune, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PowerTune, String, QQueryOperations> macProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mac');
    });
  }

  QueryBuilder<PowerTune, double, QQueryOperations> powerFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'powerFactor');
    });
  }

  QueryBuilder<PowerTune, DateTime, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }
}
