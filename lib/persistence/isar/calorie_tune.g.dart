// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calorie_tune.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetCalorieTuneCollection on Isar {
  IsarCollection<CalorieTune> get calorieTunes => this.collection();
}

const CalorieTuneSchema = CollectionSchema(
  name: r'CalorieTune',
  id: -3959865530402248089,
  properties: {
    r'calorieFactor': PropertySchema(
      id: 0,
      name: r'calorieFactor',
      type: IsarType.double,
    ),
    r'hrBased': PropertySchema(
      id: 1,
      name: r'hrBased',
      type: IsarType.bool,
    ),
    r'mac': PropertySchema(
      id: 2,
      name: r'mac',
      type: IsarType.string,
    ),
    r'time': PropertySchema(
      id: 3,
      name: r'time',
      type: IsarType.long,
    ),
    r'timeStamp': PropertySchema(
      id: 4,
      name: r'timeStamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _calorieTuneEstimateSize,
  serialize: _calorieTuneSerialize,
  deserialize: _calorieTuneDeserialize,
  deserializeProp: _calorieTuneDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _calorieTuneGetId,
  getLinks: _calorieTuneGetLinks,
  attach: _calorieTuneAttach,
  version: '3.0.5',
);

int _calorieTuneEstimateSize(
  CalorieTune object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mac.length * 3;
  return bytesCount;
}

void _calorieTuneSerialize(
  CalorieTune object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.calorieFactor);
  writer.writeBool(offsets[1], object.hrBased);
  writer.writeString(offsets[2], object.mac);
  writer.writeLong(offsets[3], object.time);
  writer.writeDateTime(offsets[4], object.timeStamp);
}

CalorieTune _calorieTuneDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CalorieTune(
    calorieFactor: reader.readDouble(offsets[0]),
    hrBased: reader.readBool(offsets[1]),
    id: id,
    mac: reader.readString(offsets[2]),
    time: reader.readLong(offsets[3]),
  );
  return object;
}

P _calorieTuneDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _calorieTuneGetId(CalorieTune object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _calorieTuneGetLinks(CalorieTune object) {
  return [];
}

void _calorieTuneAttach(IsarCollection<dynamic> col, Id id, CalorieTune object) {
  object.id = id;
}

extension CalorieTuneQueryWhereSort on QueryBuilder<CalorieTune, CalorieTune, QWhere> {
  QueryBuilder<CalorieTune, CalorieTune, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CalorieTuneQueryWhere on QueryBuilder<CalorieTune, CalorieTune, QWhereClause> {
  QueryBuilder<CalorieTune, CalorieTune, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterWhereClause> idBetween(
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterWhereClause> macEqualTo(String mac) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mac',
        value: [mac],
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterWhereClause> macNotEqualTo(String mac) {
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
}

extension CalorieTuneQueryFilter on QueryBuilder<CalorieTune, CalorieTune, QFilterCondition> {
  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> calorieFactorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calorieFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> calorieFactorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calorieFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> calorieFactorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calorieFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> calorieFactorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calorieFactor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> hrBasedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hrBased',
        value: value,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> macEqualTo(
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> macGreaterThan(
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> macLessThan(
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> macBetween(
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> macStartsWith(
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> macEndsWith(
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> macContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mac',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> macMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mac',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> macIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mac',
        value: '',
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> macIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mac',
        value: '',
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> timeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'time',
        value: value,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> timeGreaterThan(
    int value, {
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> timeLessThan(
    int value, {
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> timeBetween(
    int lower,
    int upper, {
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

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> timeStampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeStamp',
        value: value,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> timeStampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeStamp',
        value: value,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> timeStampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeStamp',
        value: value,
      ));
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterFilterCondition> timeStampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeStamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CalorieTuneQueryObject on QueryBuilder<CalorieTune, CalorieTune, QFilterCondition> {}

extension CalorieTuneQueryLinks on QueryBuilder<CalorieTune, CalorieTune, QFilterCondition> {}

extension CalorieTuneQuerySortBy on QueryBuilder<CalorieTune, CalorieTune, QSortBy> {
  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> sortByCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.asc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> sortByCalorieFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.desc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> sortByHrBased() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrBased', Sort.asc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> sortByHrBasedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrBased', Sort.desc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> sortByMac() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mac', Sort.asc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> sortByMacDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mac', Sort.desc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> sortByTimeStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.asc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> sortByTimeStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.desc);
    });
  }
}

extension CalorieTuneQuerySortThenBy on QueryBuilder<CalorieTune, CalorieTune, QSortThenBy> {
  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenByCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.asc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenByCalorieFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.desc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenByHrBased() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrBased', Sort.asc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenByHrBasedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrBased', Sort.desc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenByMac() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mac', Sort.asc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenByMacDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mac', Sort.desc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenByTimeStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.asc);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QAfterSortBy> thenByTimeStampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeStamp', Sort.desc);
    });
  }
}

extension CalorieTuneQueryWhereDistinct on QueryBuilder<CalorieTune, CalorieTune, QDistinct> {
  QueryBuilder<CalorieTune, CalorieTune, QDistinct> distinctByCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calorieFactor');
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QDistinct> distinctByHrBased() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hrBased');
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QDistinct> distinctByMac({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mac', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QDistinct> distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }

  QueryBuilder<CalorieTune, CalorieTune, QDistinct> distinctByTimeStamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeStamp');
    });
  }
}

extension CalorieTuneQueryProperty on QueryBuilder<CalorieTune, CalorieTune, QQueryProperty> {
  QueryBuilder<CalorieTune, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CalorieTune, double, QQueryOperations> calorieFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calorieFactor');
    });
  }

  QueryBuilder<CalorieTune, bool, QQueryOperations> hrBasedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hrBased');
    });
  }

  QueryBuilder<CalorieTune, String, QQueryOperations> macProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mac');
    });
  }

  QueryBuilder<CalorieTune, int, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }

  QueryBuilder<CalorieTune, DateTime, QQueryOperations> timeStampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeStamp');
    });
  }
}
