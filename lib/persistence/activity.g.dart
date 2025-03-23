// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetActivityCollection on Isar {
  IsarCollection<Activity> get activitys => this.collection();
}

const ActivitySchema = CollectionSchema(
  name: r'Activity',
  id: -6099828696840999229,
  properties: {
    r'calorieFactor': PropertySchema(id: 0, name: r'calorieFactor', type: IsarType.double),
    r'calories': PropertySchema(id: 1, name: r'calories', type: IsarType.long),
    r'deviceId': PropertySchema(id: 2, name: r'deviceId', type: IsarType.string),
    r'deviceName': PropertySchema(id: 3, name: r'deviceName', type: IsarType.string),
    r'distance': PropertySchema(id: 4, name: r'distance', type: IsarType.double),
    r'elapsed': PropertySchema(id: 5, name: r'elapsed', type: IsarType.long),
    r'elapsedString': PropertySchema(id: 6, name: r'elapsedString', type: IsarType.string),
    r'end': PropertySchema(id: 7, name: r'end', type: IsarType.dateTime),
    r'fourCC': PropertySchema(id: 8, name: r'fourCC', type: IsarType.string),
    r'hrBasedCalories': PropertySchema(id: 9, name: r'hrBasedCalories', type: IsarType.bool),
    r'hrCalorieFactor': PropertySchema(id: 10, name: r'hrCalorieFactor', type: IsarType.double),
    r'hrmCalorieFactor': PropertySchema(id: 11, name: r'hrmCalorieFactor', type: IsarType.double),
    r'hrmId': PropertySchema(id: 12, name: r'hrmId', type: IsarType.string),
    r'movingTime': PropertySchema(id: 13, name: r'movingTime', type: IsarType.long),
    r'movingTimeString': PropertySchema(id: 14, name: r'movingTimeString', type: IsarType.string),
    r'powerFactor': PropertySchema(id: 15, name: r'powerFactor', type: IsarType.double),
    r'sport': PropertySchema(id: 16, name: r'sport', type: IsarType.string),
    r'start': PropertySchema(id: 17, name: r'start', type: IsarType.dateTime),
    r'stravaActivityId': PropertySchema(id: 18, name: r'stravaActivityId', type: IsarType.long),
    r'stravaId': PropertySchema(id: 19, name: r'stravaId', type: IsarType.long),
    r'strides': PropertySchema(id: 20, name: r'strides', type: IsarType.long),
    r'suuntoBlobUrl': PropertySchema(id: 21, name: r'suuntoBlobUrl', type: IsarType.string),
    r'suuntoUploadIdentifier': PropertySchema(
      id: 22,
      name: r'suuntoUploadIdentifier',
      type: IsarType.string,
    ),
    r'suuntoUploaded': PropertySchema(id: 23, name: r'suuntoUploaded', type: IsarType.bool),
    r'suuntoWorkoutUrl': PropertySchema(id: 24, name: r'suuntoWorkoutUrl', type: IsarType.string),
    r'timeZone': PropertySchema(id: 25, name: r'timeZone', type: IsarType.string),
    r'trainingPeaksFileTrackingUuid': PropertySchema(
      id: 26,
      name: r'trainingPeaksFileTrackingUuid',
      type: IsarType.string,
    ),
    r'trainingPeaksUploaded': PropertySchema(
      id: 27,
      name: r'trainingPeaksUploaded',
      type: IsarType.bool,
    ),
    r'trainingPeaksWorkoutId': PropertySchema(
      id: 28,
      name: r'trainingPeaksWorkoutId',
      type: IsarType.long,
    ),
    r'uaWorkoutId': PropertySchema(id: 29, name: r'uaWorkoutId', type: IsarType.long),
    r'underArmourUploaded': PropertySchema(
      id: 30,
      name: r'underArmourUploaded',
      type: IsarType.bool,
    ),
    r'uploaded': PropertySchema(id: 31, name: r'uploaded', type: IsarType.bool),
  },
  estimateSize: _activityEstimateSize,
  serialize: _activitySerialize,
  deserialize: _activityDeserialize,
  deserializeProp: _activityDeserializeProp,
  idName: r'id',
  indexes: {
    r'start': IndexSchema(
      id: -5775659401471708833,
      name: r'start',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(name: r'start', type: IndexType.value, caseSensitive: false),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _activityGetId,
  getLinks: _activityGetLinks,
  attach: _activityAttach,
  version: '3.1.8',
);

int _activityEstimateSize(Activity object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.deviceName.length * 3;
  bytesCount += 3 + object.elapsedString.length * 3;
  bytesCount += 3 + object.fourCC.length * 3;
  bytesCount += 3 + object.hrmId.length * 3;
  bytesCount += 3 + object.movingTimeString.length * 3;
  bytesCount += 3 + object.sport.length * 3;
  bytesCount += 3 + object.suuntoBlobUrl.length * 3;
  bytesCount += 3 + object.suuntoUploadIdentifier.length * 3;
  bytesCount += 3 + object.suuntoWorkoutUrl.length * 3;
  bytesCount += 3 + object.timeZone.length * 3;
  bytesCount += 3 + object.trainingPeaksFileTrackingUuid.length * 3;
  return bytesCount;
}

void _activitySerialize(
  Activity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.calorieFactor);
  writer.writeLong(offsets[1], object.calories);
  writer.writeString(offsets[2], object.deviceId);
  writer.writeString(offsets[3], object.deviceName);
  writer.writeDouble(offsets[4], object.distance);
  writer.writeLong(offsets[5], object.elapsed);
  writer.writeString(offsets[6], object.elapsedString);
  writer.writeDateTime(offsets[7], object.end);
  writer.writeString(offsets[8], object.fourCC);
  writer.writeBool(offsets[9], object.hrBasedCalories);
  writer.writeDouble(offsets[10], object.hrCalorieFactor);
  writer.writeDouble(offsets[11], object.hrmCalorieFactor);
  writer.writeString(offsets[12], object.hrmId);
  writer.writeLong(offsets[13], object.movingTime);
  writer.writeString(offsets[14], object.movingTimeString);
  writer.writeDouble(offsets[15], object.powerFactor);
  writer.writeString(offsets[16], object.sport);
  writer.writeDateTime(offsets[17], object.start);
  writer.writeLong(offsets[18], object.stravaActivityId);
  writer.writeLong(offsets[19], object.stravaId);
  writer.writeLong(offsets[20], object.strides);
  writer.writeString(offsets[21], object.suuntoBlobUrl);
  writer.writeString(offsets[22], object.suuntoUploadIdentifier);
  writer.writeBool(offsets[23], object.suuntoUploaded);
  writer.writeString(offsets[24], object.suuntoWorkoutUrl);
  writer.writeString(offsets[25], object.timeZone);
  writer.writeString(offsets[26], object.trainingPeaksFileTrackingUuid);
  writer.writeBool(offsets[27], object.trainingPeaksUploaded);
  writer.writeLong(offsets[28], object.trainingPeaksWorkoutId);
  writer.writeLong(offsets[29], object.uaWorkoutId);
  writer.writeBool(offsets[30], object.underArmourUploaded);
  writer.writeBool(offsets[31], object.uploaded);
}

Activity _activityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Activity(
    calorieFactor: reader.readDouble(offsets[0]),
    calories: reader.readLongOrNull(offsets[1]) ?? 0,
    deviceId: reader.readString(offsets[2]),
    deviceName: reader.readString(offsets[3]),
    distance: reader.readDoubleOrNull(offsets[4]) ?? 0.0,
    elapsed: reader.readLongOrNull(offsets[5]) ?? 0,
    end: reader.readDateTimeOrNull(offsets[7]),
    fourCC: reader.readString(offsets[8]),
    hrBasedCalories: reader.readBool(offsets[9]),
    hrCalorieFactor: reader.readDouble(offsets[10]),
    hrmCalorieFactor: reader.readDouble(offsets[11]),
    hrmId: reader.readString(offsets[12]),
    id: id,
    movingTime: reader.readLongOrNull(offsets[13]) ?? 0,
    powerFactor: reader.readDouble(offsets[15]),
    sport: reader.readString(offsets[16]),
    start: reader.readDateTime(offsets[17]),
    stravaActivityId: reader.readLongOrNull(offsets[18]) ?? 0,
    stravaId: reader.readLongOrNull(offsets[19]) ?? 0,
    strides: reader.readLongOrNull(offsets[20]) ?? 0,
    suuntoBlobUrl: reader.readStringOrNull(offsets[21]) ?? "",
    suuntoUploadIdentifier: reader.readStringOrNull(offsets[22]) ?? "",
    suuntoUploaded: reader.readBoolOrNull(offsets[23]) ?? false,
    suuntoWorkoutUrl: reader.readStringOrNull(offsets[24]) ?? "",
    timeZone: reader.readString(offsets[25]),
    trainingPeaksFileTrackingUuid: reader.readStringOrNull(offsets[26]) ?? "",
    trainingPeaksUploaded: reader.readBoolOrNull(offsets[27]) ?? false,
    trainingPeaksWorkoutId: reader.readLongOrNull(offsets[28]) ?? 0,
    uaWorkoutId: reader.readLongOrNull(offsets[29]) ?? 0,
    underArmourUploaded: reader.readBoolOrNull(offsets[30]) ?? false,
    uploaded: reader.readBoolOrNull(offsets[31]) ?? false,
  );
  return object;
}

P _activityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDouble(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readDateTime(offset)) as P;
    case 18:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 19:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 20:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 21:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 22:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 23:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 24:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset) ?? "") as P;
    case 27:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 28:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 29:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 30:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 31:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _activityGetId(Activity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _activityGetLinks(Activity object) {
  return [];
}

void _activityAttach(IsarCollection<dynamic> col, Id id, Activity object) {
  object.id = id;
}

extension ActivityQueryWhereSort on QueryBuilder<Activity, Activity, QWhere> {
  QueryBuilder<Activity, Activity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Activity, Activity, QAfterWhere> anyStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IndexWhereClause.any(indexName: r'start'));
    });
  }
}

extension ActivityQueryWhere on QueryBuilder<Activity, Activity, QWhereClause> {
  QueryBuilder<Activity, Activity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Activity, Activity, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false))
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false));
      } else {
        return query
            .addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: false))
            .addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: false));
      }
    });
  }

  QueryBuilder<Activity, Activity, QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.greaterThan(lower: id, includeLower: include));
    });
  }

  QueryBuilder<Activity, Activity, QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.lessThan(upper: id, includeUpper: include));
    });
  }

  QueryBuilder<Activity, Activity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterWhereClause> startEqualTo(DateTime start) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(indexName: r'start', value: [start]));
    });
  }

  QueryBuilder<Activity, Activity, QAfterWhereClause> startNotEqualTo(DateTime start) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'start',
                lower: [],
                upper: [start],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'start',
                lower: [start],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'start',
                lower: [start],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'start',
                lower: [],
                upper: [start],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<Activity, Activity, QAfterWhereClause> startGreaterThan(
    DateTime start, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'start',
          lower: [start],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterWhereClause> startLessThan(
    DateTime start, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'start',
          lower: [],
          upper: [start],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterWhereClause> startBetween(
    DateTime lowerStart,
    DateTime upperStart, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'start',
          lower: [lowerStart],
          includeLower: includeLower,
          upper: [upperStart],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ActivityQueryFilter on QueryBuilder<Activity, Activity, QFilterCondition> {
  QueryBuilder<Activity, Activity, QAfterFilterCondition> calorieFactorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'calorieFactor', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> calorieFactorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'calorieFactor',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> calorieFactorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'calorieFactor',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> calorieFactorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'calorieFactor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> caloriesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'calories', value: value));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> caloriesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'calories', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> caloriesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'calories', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> caloriesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'calories',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'deviceId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'deviceId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'deviceId', value: ''));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deviceName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'deviceName', value: ''));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> deviceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deviceName', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> distanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'distance', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> distanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'distance',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> distanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'distance',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> distanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'distance',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'elapsed', value: value));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'elapsed', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'elapsed', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'elapsed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedStringEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'elapsedString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedStringGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'elapsedString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedStringLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'elapsedString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedStringBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'elapsedString',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedStringStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'elapsedString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedStringEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'elapsedString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedStringContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'elapsedString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedStringMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'elapsedString',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedStringIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'elapsedString', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> elapsedStringIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'elapsedString', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> endIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(property: r'end'));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> endIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(property: r'end'));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> endEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'end', value: value));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> endGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'end', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> endLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'end', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> endBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'end',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> fourCCEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fourCC', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> fourCCGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fourCC',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> fourCCLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fourCC',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> fourCCBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fourCC',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> fourCCStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'fourCC', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> fourCCEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'fourCC', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> fourCCContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'fourCC', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> fourCCMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fourCC',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> fourCCIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'fourCC', value: ''));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> fourCCIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'fourCC', value: ''));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrBasedCaloriesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hrBasedCalories', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrCalorieFactorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hrCalorieFactor', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrCalorieFactorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hrCalorieFactor',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrCalorieFactorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hrCalorieFactor',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrCalorieFactorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hrCalorieFactor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmCalorieFactorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hrmCalorieFactor', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmCalorieFactorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hrmCalorieFactor',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmCalorieFactorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hrmCalorieFactor',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmCalorieFactorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hrmCalorieFactor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hrmId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hrmId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hrmId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hrmId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'hrmId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'hrmId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'hrmId', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'hrmId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'hrmId', value: ''));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> hrmIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'hrmId', value: ''));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'id', value: value));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'movingTime', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'movingTime', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'movingTime', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'movingTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeStringEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'movingTimeString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeStringGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'movingTimeString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeStringLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'movingTimeString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeStringBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'movingTimeString',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeStringStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'movingTimeString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeStringEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'movingTimeString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeStringContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'movingTimeString',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeStringMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'movingTimeString',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeStringIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'movingTimeString', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> movingTimeStringIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'movingTimeString', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> powerFactorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'powerFactor', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> powerFactorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'powerFactor',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> powerFactorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'powerFactor',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> powerFactorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'powerFactor',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> sportEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sport', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> sportGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sport',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> sportLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sport',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> sportBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sport',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> sportStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(property: r'sport', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> sportEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'sport', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> sportContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'sport', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> sportMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sport',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> sportIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'sport', value: ''));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> sportIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(property: r'sport', value: ''));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> startEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'start', value: value));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> startGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'start', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> startLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'start', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> startBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'start',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stravaActivityIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'stravaActivityId', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stravaActivityIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'stravaActivityId', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stravaActivityIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'stravaActivityId', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stravaActivityIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stravaActivityId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stravaIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'stravaId', value: value));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stravaIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'stravaId', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stravaIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'stravaId', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stravaIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'stravaId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stridesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'strides', value: value));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stridesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'strides', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stridesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'strides', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> stridesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'strides',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoBlobUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'suuntoBlobUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoBlobUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'suuntoBlobUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoBlobUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'suuntoBlobUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoBlobUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'suuntoBlobUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoBlobUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'suuntoBlobUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoBlobUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'suuntoBlobUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoBlobUrlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'suuntoBlobUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoBlobUrlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'suuntoBlobUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoBlobUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'suuntoBlobUrl', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoBlobUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'suuntoBlobUrl', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoUploadIdentifierEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'suuntoUploadIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoUploadIdentifierGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'suuntoUploadIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoUploadIdentifierLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'suuntoUploadIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoUploadIdentifierBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'suuntoUploadIdentifier',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoUploadIdentifierStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'suuntoUploadIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoUploadIdentifierEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'suuntoUploadIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoUploadIdentifierContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'suuntoUploadIdentifier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoUploadIdentifierMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'suuntoUploadIdentifier',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoUploadIdentifierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'suuntoUploadIdentifier', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoUploadIdentifierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'suuntoUploadIdentifier', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoUploadedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'suuntoUploaded', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoWorkoutUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'suuntoWorkoutUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoWorkoutUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'suuntoWorkoutUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoWorkoutUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'suuntoWorkoutUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoWorkoutUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'suuntoWorkoutUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoWorkoutUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'suuntoWorkoutUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoWorkoutUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'suuntoWorkoutUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoWorkoutUrlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'suuntoWorkoutUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoWorkoutUrlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'suuntoWorkoutUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoWorkoutUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'suuntoWorkoutUrl', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> suuntoWorkoutUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'suuntoWorkoutUrl', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> timeZoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timeZone', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> timeZoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timeZone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> timeZoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timeZone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> timeZoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timeZone',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> timeZoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'timeZone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> timeZoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(property: r'timeZone', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> timeZoneContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(property: r'timeZone', value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> timeZoneMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'timeZone',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> timeZoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'timeZone', value: ''));
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> timeZoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'timeZone', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksFileTrackingUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trainingPeaksFileTrackingUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksFileTrackingUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trainingPeaksFileTrackingUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksFileTrackingUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trainingPeaksFileTrackingUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksFileTrackingUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trainingPeaksFileTrackingUuid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksFileTrackingUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'trainingPeaksFileTrackingUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksFileTrackingUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'trainingPeaksFileTrackingUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksFileTrackingUuidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'trainingPeaksFileTrackingUuid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksFileTrackingUuidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'trainingPeaksFileTrackingUuid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksFileTrackingUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trainingPeaksFileTrackingUuid', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition>
  trainingPeaksFileTrackingUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'trainingPeaksFileTrackingUuid', value: ''),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksUploadedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trainingPeaksUploaded', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksWorkoutIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trainingPeaksWorkoutId', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksWorkoutIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trainingPeaksWorkoutId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksWorkoutIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trainingPeaksWorkoutId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> trainingPeaksWorkoutIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trainingPeaksWorkoutId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> uaWorkoutIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'uaWorkoutId', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> uaWorkoutIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(include: include, property: r'uaWorkoutId', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> uaWorkoutIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(include: include, property: r'uaWorkoutId', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> uaWorkoutIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'uaWorkoutId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> underArmourUploadedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'underArmourUploaded', value: value),
      );
    });
  }

  QueryBuilder<Activity, Activity, QAfterFilterCondition> uploadedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(property: r'uploaded', value: value));
    });
  }
}

extension ActivityQueryObject on QueryBuilder<Activity, Activity, QFilterCondition> {}

extension ActivityQueryLinks on QueryBuilder<Activity, Activity, QFilterCondition> {}

extension ActivityQuerySortBy on QueryBuilder<Activity, Activity, QSortBy> {
  QueryBuilder<Activity, Activity, QAfterSortBy> sortByCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByCalorieFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByElapsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsed', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByElapsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsed', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByElapsedString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedString', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByElapsedStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedString', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByFourCC() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fourCC', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByFourCCDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fourCC', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByHrBasedCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrBasedCalories', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByHrBasedCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrBasedCalories', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByHrCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrCalorieFactor', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByHrCalorieFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrCalorieFactor', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByHrmCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrmCalorieFactor', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByHrmCalorieFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrmCalorieFactor', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByHrmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrmId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByHrmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrmId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByMovingTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByMovingTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByMovingTimeString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTimeString', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByMovingTimeStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTimeString', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByPowerFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByPowerFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortBySport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sport', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortBySportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sport', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByStravaActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stravaActivityId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByStravaActivityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stravaActivityId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByStravaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stravaId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByStravaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stravaId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByStrides() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strides', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByStridesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strides', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortBySuuntoBlobUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoBlobUrl', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortBySuuntoBlobUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoBlobUrl', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortBySuuntoUploadIdentifier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoUploadIdentifier', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortBySuuntoUploadIdentifierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoUploadIdentifier', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortBySuuntoUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoUploaded', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortBySuuntoUploadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoUploaded', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortBySuuntoWorkoutUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoWorkoutUrl', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortBySuuntoWorkoutUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoWorkoutUrl', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByTimeZone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeZone', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByTimeZoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeZone', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByTrainingPeaksFileTrackingUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksFileTrackingUuid', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByTrainingPeaksFileTrackingUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksFileTrackingUuid', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByTrainingPeaksUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksUploaded', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByTrainingPeaksUploadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksUploaded', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByTrainingPeaksWorkoutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksWorkoutId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByTrainingPeaksWorkoutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksWorkoutId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByUaWorkoutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uaWorkoutId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByUaWorkoutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uaWorkoutId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByUnderArmourUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'underArmourUploaded', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByUnderArmourUploadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'underArmourUploaded', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaded', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> sortByUploadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaded', Sort.desc);
    });
  }
}

extension ActivityQuerySortThenBy on QueryBuilder<Activity, Activity, QSortThenBy> {
  QueryBuilder<Activity, Activity, QAfterSortBy> thenByCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByCalorieFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieFactor', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByDeviceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByDeviceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceName', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByElapsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsed', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByElapsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsed', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByElapsedString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedString', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByElapsedStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedString', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'end', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByFourCC() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fourCC', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByFourCCDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fourCC', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByHrBasedCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrBasedCalories', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByHrBasedCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrBasedCalories', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByHrCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrCalorieFactor', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByHrCalorieFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrCalorieFactor', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByHrmCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrmCalorieFactor', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByHrmCalorieFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrmCalorieFactor', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByHrmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrmId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByHrmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrmId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByMovingTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByMovingTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByMovingTimeString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTimeString', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByMovingTimeStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTimeString', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByPowerFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByPowerFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'powerFactor', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenBySport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sport', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenBySportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sport', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'start', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByStravaActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stravaActivityId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByStravaActivityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stravaActivityId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByStravaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stravaId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByStravaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stravaId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByStrides() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strides', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByStridesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strides', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenBySuuntoBlobUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoBlobUrl', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenBySuuntoBlobUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoBlobUrl', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenBySuuntoUploadIdentifier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoUploadIdentifier', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenBySuuntoUploadIdentifierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoUploadIdentifier', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenBySuuntoUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoUploaded', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenBySuuntoUploadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoUploaded', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenBySuuntoWorkoutUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoWorkoutUrl', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenBySuuntoWorkoutUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'suuntoWorkoutUrl', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByTimeZone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeZone', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByTimeZoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeZone', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByTrainingPeaksFileTrackingUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksFileTrackingUuid', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByTrainingPeaksFileTrackingUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksFileTrackingUuid', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByTrainingPeaksUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksUploaded', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByTrainingPeaksUploadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksUploaded', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByTrainingPeaksWorkoutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksWorkoutId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByTrainingPeaksWorkoutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trainingPeaksWorkoutId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByUaWorkoutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uaWorkoutId', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByUaWorkoutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uaWorkoutId', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByUnderArmourUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'underArmourUploaded', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByUnderArmourUploadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'underArmourUploaded', Sort.desc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaded', Sort.asc);
    });
  }

  QueryBuilder<Activity, Activity, QAfterSortBy> thenByUploadedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploaded', Sort.desc);
    });
  }
}

extension ActivityQueryWhereDistinct on QueryBuilder<Activity, Activity, QDistinct> {
  QueryBuilder<Activity, Activity, QDistinct> distinctByCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calorieFactor');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calories');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByDeviceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distance');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByElapsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elapsed');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByElapsedString({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elapsedString', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'end');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByFourCC({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fourCC', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByHrBasedCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hrBasedCalories');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByHrCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hrCalorieFactor');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByHrmCalorieFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hrmCalorieFactor');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByHrmId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hrmId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByMovingTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movingTime');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByMovingTimeString({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movingTimeString', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByPowerFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'powerFactor');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctBySport({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sport', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'start');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByStravaActivityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stravaActivityId');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByStravaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stravaId');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByStrides() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'strides');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctBySuuntoBlobUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suuntoBlobUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctBySuuntoUploadIdentifier({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suuntoUploadIdentifier', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctBySuuntoUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suuntoUploaded');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctBySuuntoWorkoutUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'suuntoWorkoutUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByTimeZone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeZone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByTrainingPeaksFileTrackingUuid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trainingPeaksFileTrackingUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByTrainingPeaksUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trainingPeaksUploaded');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByTrainingPeaksWorkoutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trainingPeaksWorkoutId');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByUaWorkoutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uaWorkoutId');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByUnderArmourUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'underArmourUploaded');
    });
  }

  QueryBuilder<Activity, Activity, QDistinct> distinctByUploaded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploaded');
    });
  }
}

extension ActivityQueryProperty on QueryBuilder<Activity, Activity, QQueryProperty> {
  QueryBuilder<Activity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Activity, double, QQueryOperations> calorieFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calorieFactor');
    });
  }

  QueryBuilder<Activity, int, QQueryOperations> caloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calories');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> deviceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceName');
    });
  }

  QueryBuilder<Activity, double, QQueryOperations> distanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distance');
    });
  }

  QueryBuilder<Activity, int, QQueryOperations> elapsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elapsed');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> elapsedStringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elapsedString');
    });
  }

  QueryBuilder<Activity, DateTime?, QQueryOperations> endProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'end');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> fourCCProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fourCC');
    });
  }

  QueryBuilder<Activity, bool, QQueryOperations> hrBasedCaloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hrBasedCalories');
    });
  }

  QueryBuilder<Activity, double, QQueryOperations> hrCalorieFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hrCalorieFactor');
    });
  }

  QueryBuilder<Activity, double, QQueryOperations> hrmCalorieFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hrmCalorieFactor');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> hrmIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hrmId');
    });
  }

  QueryBuilder<Activity, int, QQueryOperations> movingTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movingTime');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> movingTimeStringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movingTimeString');
    });
  }

  QueryBuilder<Activity, double, QQueryOperations> powerFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'powerFactor');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> sportProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sport');
    });
  }

  QueryBuilder<Activity, DateTime, QQueryOperations> startProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'start');
    });
  }

  QueryBuilder<Activity, int, QQueryOperations> stravaActivityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stravaActivityId');
    });
  }

  QueryBuilder<Activity, int, QQueryOperations> stravaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stravaId');
    });
  }

  QueryBuilder<Activity, int, QQueryOperations> stridesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'strides');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> suuntoBlobUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suuntoBlobUrl');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> suuntoUploadIdentifierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suuntoUploadIdentifier');
    });
  }

  QueryBuilder<Activity, bool, QQueryOperations> suuntoUploadedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suuntoUploaded');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> suuntoWorkoutUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'suuntoWorkoutUrl');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> timeZoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeZone');
    });
  }

  QueryBuilder<Activity, String, QQueryOperations> trainingPeaksFileTrackingUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trainingPeaksFileTrackingUuid');
    });
  }

  QueryBuilder<Activity, bool, QQueryOperations> trainingPeaksUploadedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trainingPeaksUploaded');
    });
  }

  QueryBuilder<Activity, int, QQueryOperations> trainingPeaksWorkoutIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trainingPeaksWorkoutId');
    });
  }

  QueryBuilder<Activity, int, QQueryOperations> uaWorkoutIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uaWorkoutId');
    });
  }

  QueryBuilder<Activity, bool, QQueryOperations> underArmourUploadedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'underArmourUploaded');
    });
  }

  QueryBuilder<Activity, bool, QQueryOperations> uploadedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploaded');
    });
  }
}
