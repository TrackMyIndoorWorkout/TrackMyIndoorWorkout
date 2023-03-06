// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_summary.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters

extension GetWorkoutSummaryCollection on Isar {
  IsarCollection<WorkoutSummary> get workoutSummarys => this.collection();
}

const WorkoutSummarySchema = CollectionSchema(
  name: r'WorkoutSummary',
  id: -4926515236964493839,
  properties: {
    r'calorieFactor': PropertySchema(
      id: 0,
      name: r'calorieFactor',
      type: IsarType.double,
    ),
    r'deviceId': PropertySchema(
      id: 1,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'deviceName': PropertySchema(
      id: 2,
      name: r'deviceName',
      type: IsarType.string,
    ),
    r'distance': PropertySchema(
      id: 3,
      name: r'distance',
      type: IsarType.double,
    ),
    r'elapsed': PropertySchema(
      id: 4,
      name: r'elapsed',
      type: IsarType.long,
    ),
    r'elapsedString': PropertySchema(
      id: 5,
      name: r'elapsedString',
      type: IsarType.string,
    ),
    r'isPacer': PropertySchema(
      id: 6,
      name: r'isPacer',
      type: IsarType.bool,
    ),
    r'manufacturer': PropertySchema(
      id: 7,
      name: r'manufacturer',
      type: IsarType.string,
    ),
    r'movingTime': PropertySchema(
      id: 8,
      name: r'movingTime',
      type: IsarType.long,
    ),
    r'movingTimeString': PropertySchema(
      id: 9,
      name: r'movingTimeString',
      type: IsarType.string,
    ),
    r'powerFactor': PropertySchema(
      id: 10,
      name: r'powerFactor',
      type: IsarType.double,
    ),
    r'speed': PropertySchema(
      id: 11,
      name: r'speed',
      type: IsarType.double,
    ),
    r'sport': PropertySchema(
      id: 12,
      name: r'sport',
      type: IsarType.string,
    ),
    r'start': PropertySchema(
      id: 13,
      name: r'start',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _workoutSummaryEstimateSize,
  serialize: _workoutSummarySerialize,
  deserialize: _workoutSummaryDeserialize,
  deserializeProp: _workoutSummaryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _workoutSummaryGetId,
  getLinks: _workoutSummaryGetLinks,
  attach: _workoutSummaryAttach,
  version: '3.0.5',
);

int _workoutSummaryEstimateSize(
  WorkoutSummary object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.deviceName.length * 3;
  bytesCount += 3 + object.elapsedString.length * 3;
  bytesCount += 3 + object.manufacturer.length * 3;
  bytesCount += 3 + object.movingTimeString.length * 3;
  bytesCount += 3 + object.sport.length * 3;
  return bytesCount;
}

void _workoutSummarySerialize(
  WorkoutSummary object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.calorieFactor);
  writer.writeString(offsets[1], object.deviceId);
  writer.writeString(offsets[2], object.deviceName);
  writer.writeDouble(offsets[3], object.distance);
  writer.writeLong(offsets[4], object.elapsed);
  writer.writeString(offsets[5], object.elapsedString);
  writer.writeBool(offsets[6], object.isPacer);
  writer.writeString(offsets[7], object.manufacturer);
  writer.writeLong(offsets[8], object.movingTime);
  writer.writeString(offsets[9], object.movingTimeString);
  writer.writeDouble(offsets[10], object.powerFactor);
  writer.writeDouble(offsets[11], object.speed);
  writer.writeString(offsets[12], object.sport);
  writer.writeDateTime(offsets[13], object.start);
}

WorkoutSummary _workoutSummaryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutSummary(
    calorieFactor: reader.readDoubleOrNull(offsets[0]) ?? 1.0,
    deviceId: reader.readString(offsets[1]),
    deviceName: reader.readString(offsets[2]),
    distance: reader.readDouble(offsets[3]),
    elapsed: reader.readLong(offsets[4]),
    id: id,
    manufacturer: reader.readString(offsets[7]),
    movingTime: reader.readLong(offsets[8]),
    powerFactor: reader.readDoubleOrNull(offsets[10]) ?? 1.0,
    sport: reader.readString(offsets[12]),
    start: reader.readDateTime(offsets[13]),
  );
  object.speed = reader.readDouble(offsets[11]);
  return object;
}

P _workoutSummaryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset) ?? 1.0) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset) ?? 1.0) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutSummaryGetId(WorkoutSummary object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutSummaryGetLinks(WorkoutSummary object) {
  return [];
}

void _workoutSummaryAttach(IsarCollection<dynamic> col, Id id, WorkoutSummary object) {
  object.id = id;
}

extension WorkoutSummaryQueryWhereSort on QueryBuilder<WorkoutSummary, WorkoutSummary, QWhere> {
  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WorkoutSummaryQueryWhere on QueryBuilder<WorkoutSummary, WorkoutSummary, QWhereClause> {
  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterWhereClause> idBetween(
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
}

extension WorkoutSummaryQueryFilter
    on QueryBuilder<WorkoutSummary, WorkoutSummary, QFilterCondition> {
  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> calorieFactorEqualTo(
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> calorieFactorGreaterThan(
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> calorieFactorLessThan(
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> calorieFactorBetween(
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceIdContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> deviceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> distanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> distanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> distanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> distanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'distance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'elapsed',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'elapsed',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'elapsed',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'elapsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedStringEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'elapsedString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedStringGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'elapsedString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedStringLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'elapsedString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedStringBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'elapsedString',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedStringStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'elapsedString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedStringEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'elapsedString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedStringContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'elapsedString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedStringMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'elapsedString',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedStringIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'elapsedString',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> elapsedStringIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'elapsedString',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> isPacerEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPacer',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> manufacturerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'manufacturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> manufacturerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'manufacturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> manufacturerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'manufacturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> manufacturerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'manufacturer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> manufacturerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'manufacturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> manufacturerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'manufacturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> manufacturerContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'manufacturer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> manufacturerMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'manufacturer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> manufacturerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'manufacturer',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> manufacturerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'manufacturer',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movingTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movingTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movingTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movingTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeStringEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movingTimeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeStringGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movingTimeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeStringLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movingTimeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeStringBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movingTimeString',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeStringStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'movingTimeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeStringEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'movingTimeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeStringContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'movingTimeString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeStringMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'movingTimeString',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeStringIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movingTimeString',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> movingTimeStringIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'movingTimeString',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> powerFactorEqualTo(
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> powerFactorGreaterThan(
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> powerFactorLessThan(
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> powerFactorBetween(
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

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> speedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> speedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> speedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> speedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> sportEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> sportGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> sportLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> sportBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sport',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> sportStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> sportEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> sportContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sport',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> sportMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sport',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> sportIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sport',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> sportIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sport',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> startEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> startGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> startLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'start',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterFilterCondition> startBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'start',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutSummaryQueryObject
    on QueryBuilder<WorkoutSummary, WorkoutSummary, QFilterCondition> {}

extension WorkoutSummaryQueryLinks
    on QueryBuilder<WorkoutSummary, WorkoutSummary, QFilterCondition> {}

extension WorkoutSummaryQuerySortBy on QueryBuilder<WorkoutSummary, WorkoutSummary, QSortBy> {
  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByCalorieFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByElapsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsed', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByElapsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsed', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByElapsedString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedString', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByElapsedStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedString', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByIsPacer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPacer', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByIsPacerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPacer', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByManufacturer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manufacturer', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByManufacturerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manufacturer', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByMovingTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByMovingTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByMovingTimeString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTimeString', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByMovingTimeStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTimeString', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByPowerFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByPowerFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortBySport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sport', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortBySportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sport', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> sortByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }
}

extension WorkoutSummaryQuerySortThenBy
    on QueryBuilder<WorkoutSummary, WorkoutSummary, QSortThenBy> {
  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByCalorieFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByElapsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsed', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByElapsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsed', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByElapsedString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedString', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByElapsedStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedString', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByIsPacer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPacer', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByIsPacerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPacer', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByManufacturer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manufacturer', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByManufacturerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'manufacturer', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByMovingTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByMovingTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByMovingTimeString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTimeString', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByMovingTimeStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTimeString', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByPowerFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByPowerFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenBySport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sport', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenBySportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sport', Sort.desc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QAfterSortBy> thenByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }
}

extension WorkoutSummaryQueryWhereDistinct
    on QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> {
  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calorieFactor');
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByDeviceName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distance');
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByElapsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elapsed');
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByElapsedString(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elapsedString', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByIsPacer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPacer');
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByManufacturer(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'manufacturer', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByMovingTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movingTime');
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByMovingTimeString(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movingTimeString', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByPowerFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'powerFactor');
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speed');
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctBySport(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sport', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutSummary, WorkoutSummary, QDistinct> distinctByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'start');
    });
  }
}

extension WorkoutSummaryQueryProperty
    on QueryBuilder<WorkoutSummary, WorkoutSummary, QQueryProperty> {
  QueryBuilder<WorkoutSummary, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkoutSummary, double, QQueryOperations> calorieFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calorieFactor');
    });
  }

  QueryBuilder<WorkoutSummary, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<WorkoutSummary, String, QQueryOperations> deviceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceName');
    });
  }

  QueryBuilder<WorkoutSummary, double, QQueryOperations> distanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distance');
    });
  }

  QueryBuilder<WorkoutSummary, int, QQueryOperations> elapsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elapsed');
    });
  }

  QueryBuilder<WorkoutSummary, String, QQueryOperations> elapsedStringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elapsedString');
    });
  }

  QueryBuilder<WorkoutSummary, bool, QQueryOperations> isPacerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPacer');
    });
  }

  QueryBuilder<WorkoutSummary, String, QQueryOperations> manufacturerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'manufacturer');
    });
  }

  QueryBuilder<WorkoutSummary, int, QQueryOperations> movingTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movingTime');
    });
  }

  QueryBuilder<WorkoutSummary, String, QQueryOperations> movingTimeStringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movingTimeString');
    });
  }

  QueryBuilder<WorkoutSummary, double, QQueryOperations> powerFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'powerFactor');
    });
  }

  QueryBuilder<WorkoutSummary, double, QQueryOperations> speedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speed');
    });
  }

  QueryBuilder<WorkoutSummary, String, QQueryOperations> sportProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sport');
    });
  }

  QueryBuilder<WorkoutSummary, DateTime, QQueryOperations> startProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'start');
    });
  }
}
